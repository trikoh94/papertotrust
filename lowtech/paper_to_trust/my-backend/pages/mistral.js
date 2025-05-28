import formidable from 'formidable';
import fs from 'fs';

export const config = {
  api: {
    bodyParser: false,
  },
};

export default async function handler(req, res) {
  if (req.method !== 'POST') {
    return res.status(405).json({ error: 'Method not allowed' });
  }

  const form = new formidable.IncomingForm();
  form.parse(req, async (err, fields, files) => {
    if (err) {
      return res.status(500).json({ error: 'Form parse error' });
    }
    const file = files.file;
    if (!file) {
      return res.status(400).json({ error: 'No file uploaded' });
    }

    // 파일을 base64로 인코딩
    const fileData = fs.readFileSync(file.filepath, { encoding: 'base64' });
    const mimeType = file.mimetype;

    // Mistral OCR API 호출
    const response = await fetch('https://api.mistral.ai/v1/ocr/process', {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${process.env.MISTRAL_API_KEY}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        model: 'mistral-ocr-latest',
        document: {
          type: 'image_base64',
          image_base64: `data:${mimeType};base64,${fileData}`,
        },
      }),
    });

    if (!response.ok) {
      return res.status(500).json({ error: 'Mistral OCR API error' });
    }

    const data = await response.json();
    return res.status(200).json({ result: data });
  });
}
