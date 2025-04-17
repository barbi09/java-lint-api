import { parse } from 'java-parser';
import { rules } from './rules';
import { Issue, Operation } from './rules/types';
import XLSX from 'xlsx';
import { BACKEND_OPERATION_ID_CELL, HTTP_METHOD_PREFIXES } from './utils/constants';


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
        if (HTTP_METHOD_PREFIXES.some(prefix => lowerName.startsWith(prefix))) {
  
          const sheet = workbook.Sheets[sheetName];
          const backendOperationIdCell = sheet[BACKEND_OPERATION_ID_CELL];
  
          operations.push({
            id: sheetName,
            backendOperationId: backendOperationIdCell ? backendOperationIdCell.v : null
          });
        }
      });
    
    return operations;
}