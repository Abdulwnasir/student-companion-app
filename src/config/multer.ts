import multer from "multer";
import path from "path";
import fs from "fs";

const uploadDir = "uploads/";

if (!fs.existsSync(uploadDir)) {
    fs.mkdirSync(uploadDir);
}

const storage = multer.diskStorage({
    destination: (req, file, cb) => {
        cb(null, uploadDir);
    },
    filename: (req, file, cb) => {
        const uniqueSuffix = Date.now() + "-" + Math.round(Math.random() * 1e9);
        cb(null, uniqueSuffix + path.extname(file.originalname));
    },
});

// Define allowed file types more flexibly
const allowedExtensions = ['.jpg', '.jpeg', '.png', '.pdf', '.doc', '.docx', '.txt', '.ppt', '.pptx'];
const allowedMimeTypes = [
    'image/jpeg',
    'image/jpg', 
    'image/png',
    'application/pdf',
    'application/msword',
    'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
    'text/plain',
    'application/vnd.ms-powerpoint',
    'application/vnd.openxmlformats-officedocument.presentationml.presentation',
    'application/octet-stream' // Some systems send this for PPT files
];

export const upload = multer({
    storage,
    limits: {
        fileSize: 50 * 1024 * 1024, // Increased to 50MB for larger presentations
    },
    fileFilter: (req, file, cb) => {
        const ext = path.extname(file.originalname).toLowerCase();
        const mime = file.mimetype.toLowerCase();
        
        // Check if extension is allowed
        const isExtAllowed = allowedExtensions.includes(ext);
        
        // Check if MIME type is allowed
        const isMimeAllowed = allowedMimeTypes.includes(mime);
        
        // Special case: If extension is .ppt or .pptx, accept even if MIME is generic
        const isPowerPoint = ext === '.ppt' || ext === '.pptx';
        
        // Accept file if either:
        // 1. Both extension and MIME type are allowed
        // 2. It's a PowerPoint file with allowed extension
        if ((isExtAllowed && isMimeAllowed) || (isPowerPoint && isExtAllowed)) {
            return cb(null, true);
        }
        
        // Provide detailed error message
        const allowedExtList = allowedExtensions.join(', ');
        cb(new Error(`Only ${allowedExtList} files are allowed! Received: ${ext} (${mime})`));
    },
});