const HF_ENDPOINT_URL =
  process.env.HF_ENDPOINT_URL ||
  'https://x0d4be3n61mgq6b3.us-east-1.aws.endpoints.huggingface.cloud';

exports.handler = async (event) => {
  if (event.httpMethod !== 'POST') {
    return {
      statusCode: 405,
      body: JSON.stringify({ error: 'Method not allowed' }),
    };
  }

  const token = process.env.HF_TOKEN;
  if (!token) {
    return {
      statusCode: 500,
      body: JSON.stringify({ error: 'Hugging Face token is not configured' }),
    };
  }

  let image;
  let question;
  try {
    const parsed = JSON.parse(event.body || '{}');
    image = parsed.image;
    question = parsed.question;
  } catch (err) {
    return {
      statusCode: 400,
      body: JSON.stringify({ error: 'Invalid JSON body' }),
    };
  }

  if (typeof image !== 'string' || !image.trim()) {
    return {
      statusCode: 400,
      body: JSON.stringify({ error: 'Missing "image" field' }),
    };
  }

  if (typeof question !== 'string' || !question.trim()) {
    return {
      statusCode: 400,
      body: JSON.stringify({ error: 'Missing "question" field' }),
    };
  }

  try {
    const response = await fetch(HF_ENDPOINT_URL, {
      method: 'POST',
      headers: {
        Authorization: `Bearer ${token}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        inputs: {
          image,
          question,
        },
      }),
    });

    const responseText = await response.text();

    if (!response.ok) {
      return {
        statusCode: response.status,
        headers: { 'Content-Type': 'application/json' },
        body: responseText,
      };
    }

    return {
      statusCode: 200,
      headers: { 'Content-Type': 'application/json' },
      body: responseText,
    };
  } catch (err) {
    return {
      statusCode: 502,
      body: JSON.stringify({ error: 'Failed to reach Hugging Face endpoint' }),
    };
  }
};
