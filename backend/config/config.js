import dotenv from 'dotenv';
import path from 'path';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

// Ensure .env is loaded from the root of the backend folder
dotenv.config({ path: path.join(__dirname, '../.env') });

export const port = process.env.PORT || 8000;
export const dburl = process.env.mongo_url;
export const jwt_secret = process.env.jwt_secret;
export const cloudinary_name = process.env.Cloudinary_name;
export const cloudinary_api_key = process.env.Cloudinary_api_key;
export const cloudinary_api_secret = process.env.Cloudinary_api_secret;
