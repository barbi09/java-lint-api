import { Rule, Issue } from './types';

export const validateUnusedImportsAndMethods: Rule = (cst: any, file: string): Issue[] => {
  const rule = 'Validate Unused Imports and Private Methods';
  const issues: Issue[] = [];
  const importNames: { name: string; fullPath: string; line: number }[] = [];
  const declaredConstants: { name: string; line: number }[] = [];
  const declaredMethods: { name: string; line: number }[] = [];
  const usedIdentifiers = new Set<string>();

  let insideImportDeclaration = false;

  function walk(node: any) {
    if (!node || typeof node !== 'object') return;

    if (node.name === 'importDeclaration') {
      insideImportDeclaration = true;

      const importPath = node.children?.packageOrTypeName?.[0]?.children?.Identifier;
      // ✅ Explicit check for wildcard (*)
      const hasWildcard = 'Star' in (node.children || {});
      if (!hasWildcard && Array.isArray(importPath)) {
        const lastPart = importPath[importPath.length - 1]?.image;
        const fullPath = importPath.map(p => p.image).join('.');
        const line = node.location?.startLine || 1;

        if (lastPart) {
          importNames.push({ name: lastPart, fullPath, line });
        }
      }
    }

    // 🔍 Collect private method declarations
    if (node.name === 'methodDeclaration') {
      const modifiers = node.children?.modifier || [];
      const isPrivate = modifiers.some((m: any) => m.children?.PRIVATE);

      const name = node.children?.methodHeader?.[0]
        ?.children?.methodDeclarator?.[0]
        ?.children?.Identifier?.[0]?.image;

      const line = node.location?.startLine || 1;

      if (isPrivate && name) {
        declaredMethods.push({ name, line });
      }
    }

    // 🔍 Track all used identifiers (except in import section)
    if (typeof node.image === 'string' && !insideImportDeclaration) {
      usedIdentifiers.add(node.image);
    }

    // Recurse
    for (const key of Object.keys(node.children || {})) {
      const children = node.children[key];
      if (Array.isArray(children)) {
        children.forEach(walk);
      }
    }

    // Reset after import section
    if (node.name === 'importDeclaration') {
      insideImportDeclaration = false;
    }
  }


  walk(cst);

  // ❌ Report unused imports
  for (const imported of importNames) {
    if (!usedIdentifiers.has(imported.name)) {
      issues.push({
        rule,
        file,
        line: imported.line,
        message: `Unused import: ${imported.fullPath}`,
      });
    }
  }

  // ❌ Report unused private methods
  for (const method of declaredMethods) {
    if (!usedIdentifiers.has(method.name)) {
      issues.push({
        rule,
        file,
        line: method.line,
        message: `Unused private method: "${method.name}"`,
      });
    }
  }


  return issues;
};
