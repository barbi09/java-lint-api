import { parse } from 'java-parser';
import { rules } from './rules';
import { Issue, Operation } from './rules/types';
import XLSX from 'xlsx';
import { BACKEND_OPERATION_ID_CELL, HTTP_METHOD_PREFIXES, BACKEND_ID_CELL } from './commons/constants';


export function analyzeJavaFile(code: string, file: string, operationsData: Operation[]): Issue[] {
    const cst = parse(code);
    const issues: Issue[] = [];
    for (const rule of rules) {
      if(rule.name === "validateUnusedGlobalConstants"){
        issues.push(...rule(cst, file, globalUsedConstants));
      }else{
        issues.push(...rule(cst, file, operationsData));
      }
    }
  
    return issues;
  }

  export function analyzeJavaFileConstants(code: string, file: string, operationsData: Operation[]) : rules[] {
    const cst = parse(code);
    let globalUsedConstants: Set<string>= new Set<string>();
    
    globalUsedConstants =  rules.name["validateUnusedGlobalConstants"](cst, file, globalUsedConstants);
  
    return globalUsedConstants;
  }

  

export function analyzeExcelFile(xlsxFile: any): Operation[] {
    const workbook = XLSX.readFile(xlsxFile.path);
    const operations: Operation[] = [];
      
      workbook.SheetNames.forEach((sheetName) => {
        const lowerName = sheetName.toLowerCase();
        if (HTTP_METHOD_PREFIXES.some(prefix => lowerName.startsWith(prefix))) {
  
          const sheet = workbook.Sheets[sheetName];
          const backendOperationIdCell = sheet[BACKEND_OPERATION_ID_CELL];
          const backendIdCell = sheet[BACKEND_ID_CELL];
  
          operations.push({
            id: sheetName,
            backendOperationId: backendOperationIdCell ? backendOperationIdCell.v : null,
            backendId: backendIdCell ? backendIdCell.v : null
          });
        }
      });
    
    return operations;
}