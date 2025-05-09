import { Response, Request } from 'express';
import path from 'path';
import { v4 as uuidv4 } from 'uuid';
import fs from 'fs-extra';
import unzipper from 'unzipper';
import { parse } from 'java-parser';
import { globSync } from 'glob';
import { rimraf } from 'rimraf';
import { analyzeJavaFile, analyzeExcelFile, analyzeJavaFileConstants } from '../analyzer';
import { Issue } from '../rules/types';
import { extractConstantsFromCst, finalizeUnusedConstants } from '../commons/utils';
import { validatePomData } from '../rules/validatePomData';
import { parseStringPromise } from 'xml2js';

export default class AnalyzerController {

    public async post(req: Request, res: Response): Promise<void> {
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
    }



}