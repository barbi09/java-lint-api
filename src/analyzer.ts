import { parse } from 'java-parser';
import { rules } from './rules';
import { Issue, Operation } from './rules/types';
import XLSX from 'xlsx';

export function analyzeJavaFile(code: string, file: string): Issue[] {
    const cst = parse(code);
    const issues: Issue[] = [];

    for (const rule of rules) {
        issues.push(...rule(cst, file));
    }
  
    return issues;
}

export function analyzeExcelFile(xlsxFile: any): Operation[] {
    const workbook = XLSX.readFile(xlsxFile.path);
    const operations: Operation[] = [];
      
      workbook.SheetNames.forEach((sheetName) => {
        const lowerName = sheetName.toLowerCase();
        if (lowerName.startsWith('get-') || lowerName.startsWith('post-') ||
            lowerName.startsWith('put-') || lowerName.startsWith('delete-') ||
            lowerName.startsWith('patch-')) {
  
          const sheet = workbook.Sheets[sheetName];
          const backendOperationIdCell = sheet['C14'];
  
          operations.push({
            id: sheetName,
            backendOperationId: backendOperationIdCell ? backendOperationIdCell.v : null
          });
        }
      });
    
    return operations;
}