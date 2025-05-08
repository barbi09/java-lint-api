import { isLowerCamelCase } from '../commons/utils';
import { Rule, Issue } from './types';

export const validateDtoPropertiesName: Rule = (cst: any, file: string): Issue[] => {
  const issues: Issue[] = [];

  const normalizedPath = file.replace(/\\/g, '/');
  const isDtoBackend = /dto\/backend/.test(normalizedPath);

  if (!isDtoBackend) return issues;
  function walk(node: any) {
    if (!node || typeof node !== 'object') return;
    // Look for field declarations
    if (node.name === 'fieldDeclaration') {
      const declarator = node.children.variableDeclaratorList?.[0]?.children.variableDeclarator?.[0];
      const idNode = declarator?.children?.variableDeclaratorId?.[0]?.children?.Identifier?.[0];
      const fieldName = idNode?.image;
      const line = idNode?.startLine || 1;

      if (fieldName && !isLowerCamelCase(fieldName)) {
        issues.push({
          rule: 'Validate Dto Field Naming',
          file,
          line,
          message: `Field "${fieldName}" must be in lowerCamelCase.`,
        });
      }
    }

    // Recurse
    for (const key of Object.keys(node.children || {})) {
      const children = node.children[key];
      if (Array.isArray(children)) children.forEach(walk);
    }
  }

  walk(cst);
  return issues;
};
