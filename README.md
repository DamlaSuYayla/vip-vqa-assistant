# VIP VQA Assistant

A Flutter web app that helps visually impaired people ask questions about their surroundings. The user takes a photo, asks a question by voice or text, and hears the answer spoken aloud. It runs entirely in the browser and is designed to open straight from a QR code, with nothing to install.

## How it works

The app uses a hybrid edge–cloud design. Most work happens on-device in the browser: capturing the photo, checking its quality, speech input/output, and all the interface logic. Two small Netlify Functions run server-side, one for the model call and one for text-to-speech, so the access keys they need stay off the browser. Apart from those, the app calls three outside services:

- **Cloud VQA model** — a fine-tuned Qwen2.5-VL-3B-Instruct on a Hugging Face Inference Endpoint, which reads the photo and question and returns an answer.
- **MyMemory** — translates questions to English and answers back to the user's language.
- **ElevenLabs** — turns the answer into natural speech.

Photos never leave the browser's memory except to be processed, and aren't stored anywhere.

A typical request: the user picks a language (remembered for next time), takes a photo, and (unless evaluation mode is on) the photo passes a quality check before anything is sent out. If it passes, the user asks their question. Non-English questions are translated to English, sent to the model with the photo, and the answer comes back, gets translated if needed, and is read aloud.

## Features

- Web-only, using GetX for routing and state.
- First-launch language choice — English, Spanish, or French — kept across sessions.
- Photos from camera or gallery.
- On-device quality gate that catches dark, bright, or blurry photos before any cloud call, with an evaluation-mode toggle to turn it off for testing.
- Typed or spoken questions (spoken input via the Web Speech API where supported).
- Translation via MyMemory (no API key needed).
- Spoken answers via ElevenLabs, with automatic fallback to the browser's built-in speech.
- Accessible throughout: dark high-contrast theme, large touch targets, screen-reader labels, and spoken cues at each screen change.

In-app voice input depends on the browser. The app's own speech recognition (Web Speech API) works on browsers that support it, such as Chrome for Android. On browsers without it, such as Safari on iOS, the user can still dictate by using the microphone key on their keyboard, or type instead.

## Quality gate

Runs fully in the browser, off the main thread, before any network call. Each photo is resized to 640 px on its longest side and converted to grayscale (matching the calibration preprocessing). Then three checks run, and the photo is rejected if any one fails:

- **Too dark** — mean grayscale brightness below 34.0
- **Too bright** — more than 23.12% of pixels at intensity 245 or above
- **Too blurry** — Laplacian variance below 100.0

Thresholds were calibrated against the VizWiz-QualityIssues dataset (see the dissertation). A failed photo sends the user to a retake screen with a spoken prompt, so recovery doesn't rely on sight. Evaluation mode skips the gate entirely. This enables the gate-enabled vs gate-disabled comparison in the dissertation.

## Cloud VQA endpoint

The model runs on a Hugging Face Inference Endpoint. The endpoint URL is a compiled-in constant in `lib/constants.dart`, but the app never calls it directly from the browser; the call goes through a Netlify Function (`netlify/functions/vqa.js`) that adds the access token server-side.

- **Access** — the model is private and the endpoint is authenticated, so requests need a Hugging Face token. The token is never in the client; the function reads it from a server-side environment variable (`HF_TOKEN`). Any valid Hugging Face account token works, so anyone running the code locally can use a token from their own account.
- **Request** — the client sends `{ image, question }` to `/.netlify/functions/vqa`; the function forwards it to the endpoint in the shape it expects.
- **Timeout** — 90 seconds.
- **Response** — JSON with an answer string and optional confidence; a missing or malformed answer raises an error shown to the user.

This is an *ephemeral* endpoint; if it's paused or its URL changes, it must be redeployed and `kHfEndpointUrl` updated.

The fine-tuned model is private, so its Hugging Face page isn't publicly viewable.

## Text-to-speech

ElevenLabs (`eleven_multilingual_v2`) is used for its consistent voice across all three languages. Instead of calling it from the browser, the app routes through a Netlify Function (`netlify/functions/tts.js`) so the API key stays server-side and never reaches the browser. The client sends `{ text, lang }` to `/.netlify/functions/tts`; the function calls ElevenLabs and returns base64 MP3. If it fails for any reason, the app falls back to the Web Speech API.

## Configuration

Two keys are read server-side by the Netlify Functions, never compiled into the client bundle. To run the app locally, put them in a `.env` file (see the next section).

- `HF_TOKEN` — a Hugging Face access token, used by `vqa.js` to call the authenticated model endpoint. Any valid Hugging Face account token works.
- `ELEVENLABS_API_KEY` — used by tts.js for speech. Recommended for the natural, consistent voice across all three languages; without it, text-to-speech falls back to the browser's Web Speech API.

## Using the app

**Run it locally** — run the code with your own keys.

You'll need three things installed first:

- Flutter SDK (Dart >=3.4.0 <4.0.0) with web support — see flutter.dev/get-started
- Node.js (provides npm) — see nodejs.org
- Netlify CLI — install with `npm install -g netlify-cli`

Both the model call and text-to-speech go through Netlify Functions, so a plain `flutter run` can't reach them. Use `netlify dev`, which serves the app and the functions together.

Steps:

1. Run all commands in PowerShell from inside the `VIP_Assistant` folder (where `pubspec.yaml` lives), not a parent folder.

2. Create a `.env` file in the project root (it's gitignored) with your own keys:

```bash
HF_TOKEN=your_hugging_face_token
ELEVENLABS_API_KEY=your_elevenlabs_key

```
- `HF_TOKEN`: Generate a Hugging Face token at `https://huggingface.co/settings/tokens` — any valid account token works. 
- `ELEVENLABS_API_KEY`: Used by tts.js for speech. Recommended for the natural, consistent voice across all three languages; get one at `https://elevenlabs.io/app/developers/api-keys`. Without it, text-to-speech falls back to the browser's Web Speech API.

3. Install dependencies and run:

```bash
flutter pub get
flutter build web
netlify dev
```
On first use, `netlify dev` may prompt you to run `netlify login`.

`netlify dev` reads the `.env` automatically and opens the app in your browser.

Note: Getting a full VQA answer also requires the Hugging Face Inference Endpoint to be running. The endpoint is ephemeral — if it's paused, model responses won't return until it's redeployed. 

> How this was deployed: The site is deployed to Netlify (kept private) with `flutter build web` followed by `netlify deploy --dir=build/web --prod`, and the two keys set as environment variables in the Netlify dashboard.

## Project structure

```
lib/
  app/               # GetX routes + dark high-contrast theme
  controllers/       # capture, gate, language, question, settings, vqa
  models/            # gate result, VQA answer
  screens/           # language select, home, processing, retake, answer, settings
  services/
    quality_gate_service.dart  # on-device blur/dark/bright checks
    speech_service.dart        # Web Speech API (speech-to-text)
    translation_service.dart   # MyMemory client
    tts_service.dart           # ElevenLabs + Web Speech fallback
    vqa_api_service.dart       # calls the VQA function
  constants.dart     # constants, thresholds, localized strings
  main.dart          # entry point + dependency injection
web/
  index.html         # JS interop: speech recognition, TTS, audio unlock
  manifest.json      # PWA manifest
netlify/
  functions/
    vqa.js           # proxies the Hugging Face model, keeps the token server-side
    tts.js           # proxies ElevenLabs, keeps the key server-side
netlify.toml         # Netlify build/publish/functions config
```

## Ethics and privacy

Photos live only in browser memory for the length of a session; nothing is written to disk, storage, or logs. Images (and, for non-English users, question/answer text) are sent over HTTPS to the third-party services above only for processing; what they retain is governed by their own privacy policies. The app is an assistive aid, not a replacement for human judgement.