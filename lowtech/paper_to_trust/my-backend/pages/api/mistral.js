import formidable from 'formidable';
import fs from 'fs';
import os from 'os';
import FormData from 'form-data';
import axios from 'axios';
import PDFDocument from 'pdfkit';

export const config = {
  api: {
    bodyParser: false,
    externalResolver: true,
  },
  runtime: 'nodejs',
};

// Cloudinary raw upload endpoint for PDF files
const CLOUDINARY_UPLOAD_URL = 'https://api.cloudinary.com/v1_1/dj1wdo0uh/raw/upload';
const CLOUDINARY_UPLOAD_PRESET = 'papertrust';

// Helper function to convert image to PDF
async function convertImageToPDF(imagePath) {
  return new Promise((resolve, reject) => {
    const pdfPath = `${os.tmpdir()}/${Date.now()}.pdf`;
    const doc = new PDFDocument({
      size: 'A4',
      margin: 0
    });
    const writeStream = fs.createWriteStream(pdfPath);

    doc.pipe(writeStream);
    
    // 이미지 크기 조정 및 품질 설정
    doc.image(imagePath, {
      fit: [595.28, 841.89], // A4 size
      align: 'center',
      valign: 'center',
      quality: 1.0
    });
    
    doc.end();

    writeStream.on('finish', () => {
      console.log('PDF conversion completed:', pdfPath);
      resolve(pdfPath);
    });

    writeStream.on('error', (err) => {
      console.error('PDF conversion error:', err);
      reject(err);
    });
  });
}

export default async function handler(req, res) {
  // 환경 변수 디버깅 - 더 자세한 정보
  console.log('Environment check:', {
    MISTRAL_API_KEY: process.env.MISTRAL_API_KEY ? 'exists' : 'missing',
    MISTRAL_API_KEY_LENGTH: process.env.MISTRAL_API_KEY?.length || 0,
    NODE_ENV: process.env.NODE_ENV,
    VERCEL_ENV: process.env.VERCEL_ENV,
    VERCEL_URL: process.env.VERCEL_URL,
  });

  // CORS 헤더 추가 - 프로덕션과 개발 환경 모두 허용
  const allowedOrigins = [
    /^http:\/\/localhost:\d+$/,  // localhost의 모든 포트 허용
    'https://papertotrust.web.app'
  ];
  const origin = req.headers.origin;
  
  if (origin) {
    const isAllowed = allowedOrigins.some(allowed => 
      typeof allowed === 'string' 
        ? allowed === origin 
        : allowed.test(origin)
    );
    
    if (isAllowed) {
      res.setHeader('Access-Control-Allow-Origin', origin);
    }
  }
  
  res.setHeader('Access-Control-Allow-Methods', 'POST, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type, Authorization');
  res.setHeader('Access-Control-Allow-Credentials', 'true');

  if (req.method === 'OPTIONS') {
    // Preflight 요청에 대한 응답
    return res.status(200).end();
  }

  if (req.method !== 'POST') {
    return res.status(405).json({ error: 'Method not allowed' });
  }

  try {
    const form = formidable({
      keepExtensions: true,
      multiples: false,
      uploadDir: os.tmpdir(),
    });

    form.parse(req, async (err, fields, files) => {
      if (err) {
        console.error('Form parse error:', err);
        return res.status(500).json({ error: err.message });
      }
      const file = files.file?.[0] || files.file;
      if (!file) {
        return res.status(400).json({ error: 'No file uploaded' });
      }

      const filePath = file.filepath;
      if (!filePath) {
        console.log('File object:', file);
        return res.status(500).json({ error: 'File path is undefined', file });
      }

      try {
        console.log('Starting PDF conversion for file:', filePath);
        // Convert image to PDF
        const pdfPath = await convertImageToPDF(filePath);
        console.log('PDF created at:', pdfPath);
        
        // Upload PDF to Cloudinary using raw upload
        const formData = new FormData();
        formData.append('file', fs.createReadStream(pdfPath));
        formData.append('upload_preset', CLOUDINARY_UPLOAD_PRESET);
        formData.append('resource_type', 'raw'); // Specify that this is a raw file (PDF)

        console.log('Uploading PDF to Cloudinary...');
        const cloudinaryRes = await axios.post(CLOUDINARY_UPLOAD_URL, formData, {
          headers: {
            ...formData.getHeaders(),
            'Content-Type': 'multipart/form-data'
          },
        });
        const cloudinaryUrl = cloudinaryRes.data.secure_url;
        console.log('Cloudinary upload successful:', cloudinaryUrl);

        // Clean up temporary files
        fs.unlinkSync(filePath);
        fs.unlinkSync(pdfPath);
        console.log('Temporary files cleaned up');

        // Call Mistral OCR API with PDF URL
        console.log('Calling Mistral OCR API...');
        const mistralRes = await fetch('https://api.mistral.ai/v1/ocr', {
          method: 'POST',
          headers: {
            'Authorization': `Bearer ${process.env.MISTRAL_API_KEY}`,
            'Content-Type': 'application/json',
          },
          body: JSON.stringify({
            model: 'mistral-ocr-latest',
            document: {
              type: 'document_url',
              document_url: cloudinaryUrl,
            },
          }),
        });

        if (!mistralRes.ok) {
          const errorText = await mistralRes.text();
          console.error('Mistral OCR API error:', {
            status: mistralRes.status,
            statusText: mistralRes.statusText,
            headers: Object.fromEntries(mistralRes.headers.entries()),
            body: errorText,
            cloudinaryUrl: cloudinaryUrl
          });
          return res.status(500).json({ 
            error: 'Mistral OCR API error', 
            details: errorText,
            cloudinaryUrl: cloudinaryUrl
          });
        }

        const mistralData = await mistralRes.json();
        console.log('Mistral OCR API response:', mistralData);

        // Check Cloudinary URL access
        try {
          const headRes = await axios.head(cloudinaryUrl);
          console.log('Cloudinary URL HEAD response:', headRes.status);
          // 200이면 접근 가능, 400/401/403/404 등은 접근 불가
        } catch (err) {
          console.error('Cloudinary URL HEAD error:', err.response?.status, err.message);
        }

        return res.status(200).json({ result: mistralData });
      } catch (error) {
        console.error('Error processing file:', error);
        return res.status(500).json({ 
          error: error.message,
          stack: error.stack
        });
      }
    });
  } catch (error) {
    console.error('Error processing file:', error);
    return res.status(500).json({ 
      error: error.message,
      stack: error.stack
    });
  }
}