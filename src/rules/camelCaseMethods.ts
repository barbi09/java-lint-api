import { Issue, Rule } from './types';

function isLowerCamelCase(name: string): boolean {
  return /^[a-z][a-zA-Z0-9]*$/.test(name);
}

export const camelCaseMethods: Rule = (cst: any, file: string): Issue[] => {
  const issues: Issue[] = [];

  function walk(node: any) {
    if (!node || typeof node !== 'object') return;
  
    if (node.name === 'methodDeclaration') {
      const methodName = node.children?.methodHeader?.[0]
        ?.children?.methodDeclarator?.[0]
        ?.children?.Identifier?.[0]?.image;
      const line = node.location?.startLine;
      if (methodName && !isLowerCamelCase(methodName)) {
        issues.push({
          file,
          line,
          message: `Method "${methodName}" should be lowerCamelCase.`,
        });
      }
    }
  
    // Walk into all children
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



