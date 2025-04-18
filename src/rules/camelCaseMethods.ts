import { OPERATION_ID_METHODS_CLASSES } from '../commons/constants';
import { Issue, Operation, Rule } from './types';


function isLowerCamelCase(name: string): boolean {
  return /^[a-z][a-zA-Z0-9]*$/.test(name);
}

export const camelCaseMethods: Rule = (cst: any, file: string, operationsData?: { operations: Operation[] }): Issue[] => {
  const issues: Issue[] = [];

  const shouldValidateAgainstExcel = OPERATION_ID_METHODS_CLASSES.some((className: string) => file.includes(className));
  const validOperations = operationsData?.operations || [];

  function walk(node: any) {
    if (!node || typeof node !== 'object') return;
    
    if (node.name === 'methodDeclaration') {
      const methodName = node.children?.methodHeader?.[0]
        ?.children?.methodDeclarator?.[0]
        ?.children?.Identifier?.[0]?.image;
      const line = node.location?.startLine;
      
      if (methodName) {
        console.log("methodName", methodName)
        // Only validate operationId matching if this is a Controller/Service file
        if (shouldValidateAgainstExcel && !validOperations.includes(methodName)) {
          issues.push({
            file,
            line,
            message: `Method "${methodName}" does not match any expected operationId from Excel. Expected one of: ${validOperations.join(', ')}.`,
          });
        }
      }
    }

    // Walk recursively into all child nodes
    if (node.children) {
      for (const key of Object.keys(node.children)) {
        const children = node.children[key];
        if (Array.isArray(children)) {
          children.forEach(walk);
        }
      }
    }
  }

  walk(cst);
  return issues;
};




