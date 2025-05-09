import express, { Request, Response, NextFunction, ErrorRequestHandler } from 'express';
import multer from 'multer';
import unzipper from 'unzipper';
import fs from 'fs-extra';
import path from 'path';
import { parse } from 'java-parser';
import { globSync } from 'glob';
import { rimraf } from 'rimraf';
import { analyzeJavaFile, analyzeExcelFile, analyzeJavaFileConstants } from './analyzer';
import { Issue } from './rules/types';
import { v4 as uuidv4 } from 'uuid';
import { extractConstantsFromCst, finalizeUnusedConstants, kebabToLowerCamelCase } from './commons/utils';
import { validatePomData } from './rules/validatePomData';
import { parseStringPromise } from 'xml2js';


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

      const directory = await unzipper.Open.file(zipPath);
      await directory.extract({ path: extractPath });

    } catch (unzipError) {
      throw new Error('Failed to unzip project. Make sure it is a valid .zip file.');
    }

    // Step 3: Analyze Java files
    const javaFiles = globSync('**/*.java', {
      cwd: extractPath,
      absolute: true,
      ignore: ['**/target/**']
    });

    // Step 4: Analyze Constants
    const constantsFilePath = javaFiles.find(p => p.endsWith('Constants.java'));
    let globalConstants: { name: string; line: number }[] = [];
    const javaIssues: Issue[] = [];

    if (constantsFilePath) {
      const constantsCode = await fs.readFile(constantsFilePath, 'utf8');
      const constantsCst = parse(constantsCode); // using java-parser
      globalConstants = extractConstantsFromCst(constantsCst, javaIssues); // <-- your util function
    }

    // Step 5: Analyze pom.xml
    const pomPath = globSync('**/pom.xml', {
      cwd: extractPath,
      absolute: true,
    })[0]; // get the first (and likely only) one

    if (!pomPath) {
      console.warn('⚠️ No pom.xml found in the extracted project.');
    } else {
      const xmlContent = await fs.promises.readFile(pomPath, 'utf8');
      const parsed = await parseStringPromise(xmlContent);
      const pomIssues = validatePomData(null, parsed?.project, operationsData);
      javaIssues.push(...pomIssues); // reuse javaIssues to return them together
    }



    let globalUsedConstants = new Set<string>();


    for (const filePath of javaFiles) {
      try {
        const code = await fs.readFile(filePath, 'utf8');
        const issues = analyzeJavaFile(code, path.relative(extractPath, filePath), operationsData);
        globalUsedConstants = analyzeJavaFileConstants(code, globalUsedConstants, path.relative(extractPath, filePath));
        javaIssues.push(...issues);
      } catch (err) {
        console.error(`Failed to parse ${filePath}:`, (err as Error).message);
      }
    }

    javaIssues.push(...finalizeUnusedConstants(globalConstants, globalUsedConstants));


    // ✅ Return final response
    res.json({
      javaIssues
    });

  } catch (err) {
    console.error('Error:', err);
    res.status(500).json({ error: 'Failed to analyze project', details: (err as Error).message });
    return;
  } finally {
    // ✅ Always cleanup uploaded files
    try {
      if (zipPath) await fs.remove(zipPath);
      if (xlsxFile?.path) await fs.remove(xlsxFile.path);

      // Small wait for streams to close
      await new Promise((resolve) => setTimeout(resolve, 300));

      if (extractPath) await rimraf(extractPath);
      // <- use rimraf
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
