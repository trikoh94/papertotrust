import formidable from 'formidable';
import fs from 'fs';
import FormData from 'form-data';

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

    const cloudName = 'dabc12345'; // Cloudinary 대시보드에서 확인
    const uploadPreset = 'my_unsigned_preset'; // Cloudinary에서 만든 unsigned preset 이름

    const formData = new FormData();
    formData.append('file', fs.createReadStream(file.filepath));
    formData.append('upload_preset', uploadPreset);

    const response = await fetch(`https://api.cloudinary.com/v1_1/${cloudName}/image/upload`, {
      method: 'POST',
      body: formData,
    });

    if (!response.ok) {
      return res.status(500).json({ error: 'Cloudinary upload failed' });
    }

    const data = await response.json();
    return res.status(200).json({ url: data.secure_url });
  });
}
