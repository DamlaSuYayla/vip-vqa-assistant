import base64
from io import BytesIO
import math

from PIL import Image
import torch
from transformers import AutoProcessor, Qwen2_5_VLForConditionalGeneration
from qwen_vl_utils import process_vision_info


SYSTEM_PROMPT = "You are a helpful assistant for visually impaired users. Answer the question about the image briefly and directly. Always answer in the same language as the question. If the image does not contain enough information to answer the question, reply exactly with the word: unanswerable"
LANGUAGE_NAMES = {"en": "English", "es": "Spanish", "fr": "French"}
MAX_NEW_TOKENS = 10


class EndpointHandler:
    def __init__(self, path=""):
        self.processor = AutoProcessor.from_pretrained(path, trust_remote_code=True)
        self.model = Qwen2_5_VLForConditionalGeneration.from_pretrained(
            path,
            torch_dtype=torch.float16,
            device_map="auto",
            trust_remote_code=True,
        )
        self.model.eval()

    def _device(self):
        for parameter in self.model.parameters():
            return parameter.device
        return torch.device("cuda" if torch.cuda.is_available() else "cpu")

    def _decode_image(self, image_base64):
        raw = base64.b64decode(image_base64)
        return Image.open(BytesIO(raw)).convert("RGB")

    def _build_messages(self, image, question, language):
        if language not in LANGUAGE_NAMES:
            raise ValueError(f"Unsupported language: {language}. Use one of {sorted(LANGUAGE_NAMES)}.")
        system_prompt = SYSTEM_PROMPT + f" Answer in {LANGUAGE_NAMES[language]}."
        return [
            {"role": "system", "content": [{"type": "text", "text": system_prompt}]},
            {
                "role": "user",
                "content": [
                    {"type": "image", "image": image},
                    {"type": "text", "text": question},
                ],
            },
        ]

    def _confidence_from_scores(self, scores, generated_ids):
        if not scores or generated_ids.numel() == 0:
            return 0.0
        log_probs = []
        for step_index, score_tensor in enumerate(scores):
            if step_index >= generated_ids.shape[-1]:
                break
            token_id = int(generated_ids[0, step_index].item())
            token_log_probs = torch.log_softmax(score_tensor[0].float(), dim=-1)
            log_probs.append(float(token_log_probs[token_id].detach().cpu()))
        if not log_probs:
            return 0.0
        return float(math.exp(sum(log_probs) / len(log_probs)))

    def __call__(self, data):
        payload = data.get("inputs", data)
        image = self._decode_image(payload["image"])
        question = str(payload["question"])
        language = str(payload.get("language", "en")).lower()

        messages = self._build_messages(image, question, language)
        text = self.processor.apply_chat_template(
            messages,
            tokenize=False,
            add_generation_prompt=True,
        )
        image_inputs, video_inputs = process_vision_info(messages)
        inputs = self.processor(
            text=[text],
            images=image_inputs,
            videos=video_inputs,
            padding=True,
            return_tensors="pt",
        ).to(self._device())

        with torch.no_grad():
            outputs = self.model.generate(
                **inputs,
                max_new_tokens=MAX_NEW_TOKENS,
                do_sample=False,
                num_beams=1,
                output_scores=True,
                return_dict_in_generate=True,
            )

        generated_ids = outputs.sequences[:, inputs["input_ids"].shape[1]:]
        answer = self.processor.batch_decode(
            generated_ids,
            skip_special_tokens=True,
            clean_up_tokenization_spaces=False,
        )[0].strip()
        confidence = self._confidence_from_scores(outputs.scores, generated_ids)
        return {"answer": answer, "confidence": confidence}
