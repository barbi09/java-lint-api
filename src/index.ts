import express from 'express';
import fs from 'fs-extra';
import path from 'path';
import multer from 'multer';
import unzipper from 'unzipper';
import { globSync } from 'glob';
import { Issue } from './rules/types';
import { v4 as uuidv4 } from 'uuid';
import { analyzeJavaFile } from './analyzer';

const app = express();
const PORT = 3000;

const upload = multer({ dest: 'uploads/' });

app.post('/analyze', upload.single('zip'), async (req, res): Promise<void> => {
    if (!req.file) {
      res.status(400).json({ error: 'No zip file provided' });
      return;
    }
  
    const zipPath = req.file.path;
    const extractPath = path.join('tmp', uuidv4());

  try {
    // 1. Extract ZIP
    await fs.mkdir(extractPath, { recursive: true });
    await fs.createReadStream(zipPath)
      .pipe(unzipper.Extract({ path: extractPath }))
      .promise();

    // 2. Find and analyze all .java files
    const javaFiles = globSync('**/*.java', { cwd: extractPath, absolute: true });
    const allIssues: Issue[] = [];

    for (const filePath of javaFiles) {
        try {
          const code = await fs.readFile(filePath, 'utf8');
          const issues = analyzeJavaFile(code, path.relative(extractPath, filePath));
          allIssues.push(...issues);
        } catch (err) {
          console.error(`Failed to parse ${filePath}:`, (err as Error).message);
        }
      }

    res.json({ issues: allIssues });
  } catch (err) {
    res.status(500).json({ error: 'Failed to analyze project', details: (err as Error).message });
  } finally {
    await fs.remove(zipPath); // cleanup uploaded zip
    await fs.remove(extractPath); // cleanup extracted project
  }
});

app.listen(PORT, () => {
  console.log(`📦 Java project analyzer listening on http://localhost:${PORT}`);
});