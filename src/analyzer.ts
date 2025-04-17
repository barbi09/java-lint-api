import { parse } from 'java-parser';
import { rules } from './rules';
import { Issue } from './rules/types';

export function analyzeJavaFile(code: string, file: string): Issue[] {
    const cst = parse(code);
    const issues: Issue[] = [];

    for (const rule of rules) {
        issues.push(...rule(cst, file));
    }
  
    return issues;
  }