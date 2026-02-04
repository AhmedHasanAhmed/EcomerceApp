import mongoose from 'mongoose';
import dotenv from 'dotenv';
import path from 'path';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

dotenv.config({ path: path.join(__dirname, '.env') });

const url = process.env.mongo_url;
console.log('Attempting to connect to:', url);

try {
    await mongoose.connect(url);
    console.log('Connected successfully!');
    process.exit(0);
} catch (err) {
    console.error('Connection failed:', err);
    process.exit(1);
}
