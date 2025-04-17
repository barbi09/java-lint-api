import express, { Request, Response, NextFunction, ErrorRequestHandler } from 'express';
import multer from 'multer';
import unzipper from 'unzipper';
import fs from 'fs-extra';
import path from 'path';
import { globSync } from 'glob';
import { parse } from 'java-parser';

import { analyzeJavaFile, analyzeExcelFile } from './analyzer';
import { Issue } from './rules/types';
import { v4 as uuidv4 } from 'uuid';

const app = express();
const PORT = 3000;

const upload = multer({
  dest: 'uploads/',
  fileFilter: (req, file, cb) => {
    if (file.fieldname === 'zip') {
      if (!file.originalname.endsWith('.zip')) {
        return cb(new Error('Uploaded project must be a .zip file'));
      }
    }
    if (file.fieldname === 'xlsx') {
      if (!file.originalname.endsWith('.xlsx')) {
        return cb(new Error('Uploaded specification must be a .xlsx file'));
      }
    }
    cb(null, true);
  }
});


app.post('/analyze', upload.fields([{ name: 'zip' }, { name: 'xlsx' }]), async (req: Request, res: Response): Promise<void> => {
  const zipFile = req.files && (req.files as any).zip?.[0];
  const xlsxFile = req.files && (req.files as any).xlsx?.[0];

  if (!zipFile || !xlsxFile) {
    res.status(400).json({ error: 'Both zip and xlsx files must be provided.' });
    return;
  }

  const zipPath = zipFile.path;
  const extractPath = path.join('tmp', uuidv4()); 
 
  try {

    // Step 1: Analyze XLSX file
   const operationsData = analyzeExcelFile(xlsxFile);

    // Step 2: Unzip project
    await fs.mkdir(extractPath, { recursive: true });
    try {
      await fs.createReadStream(zipPath)
        .pipe(unzipper.Extract({ path: extractPath }))
        .promise();
    } catch (unzipError) {
      throw new Error('Failed to unzip project. Make sure it is a valid .zip file.');
    }

    // Step 3: Analyze Java files
    const javaFiles = globSync('**/*.java', { cwd: extractPath, absolute: true });
    const javaIssues: Issue[] = [];

    for (const filePath of javaFiles) {
      try {
        const code = await fs.readFile(filePath, 'utf8');
        const issues = analyzeJavaFile(code, path.relative(extractPath, filePath));
        javaIssues.push(...issues);
      } catch (err) {
        console.error(`Failed to parse ${filePath}:`, (err as Error).message);
      }
    }    

    // ✅ Return final response
    res.json({
      javaIssues,
      operationsData
    });

  } catch (err) {
    console.error('Error:', err);
    res.status(500).json({ error: 'Failed to analyze project', details: (err as Error).message });
    return;
  } finally {
    // ✅ Always cleanup uploaded files
    try {
      try {
        if (zipPath) await fs.remove(zipPath);
        if (xlsxFile?.path) await fs.remove(xlsxFile.path);
    
        // Small delay to let Windows release file locks
        await new Promise((resolve) => setTimeout(resolve, 200));
    
        if (extractPath) await fs.remove(extractPath);
      } catch (cleanupError) {
        console.error('Failed to clean up files:', cleanupError);
      }
    } catch (cleanupError) {
      console.error('Failed to clean up files:', cleanupError);
    }
  }
});


const errorHandler: ErrorRequestHandler = (err, req, res, next) => {
  if (err.code === 'LIMIT_UNEXPECTED_FILE') {
    res.status(400).json({
      error: 'Unexpected field in form-data',
      details: err.field
    });
    return; // <- Optionally you can still add a plain `return;` to finish execution
  }

  if (err instanceof multer.MulterError) {
    res.status(400).json({
      error: 'Multer error',
      details: err.message
    });
    return;
  }

  res.status(500).json({
    error: 'Internal server error',
    details: err.message
  });
};

app.use(errorHandler);




app.listen(PORT, () => {
  console.log(`📦 Java analyzer listening on http://localhost:${PORT}`);
});
