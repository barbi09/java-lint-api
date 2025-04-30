export function kebabToLowerCamelCase(input: string): string {
    return input.replace(/-([a-z])/g, (_, char: string) => char.toUpperCase());
}

export function extractConstantsFromCst(cst: any): { name: string; line: number }[] {
    const constants: { name: string; line: number }[] = [];
  
    function walk(node: any) {
      if (!node || typeof node !== 'object') return;
  
      if (node.name === 'fieldDeclaration') {
        const modifiers = node.children?.fieldModifier || [];
        const isPublic = modifiers.some((m: any) => m.children?.Public);
        const isStatic = modifiers.some((m: any) => m.children?.Static);
        const isFinal = modifiers.some((m: any) => m.children?.Final);

        const nameNode = node.children?.variableDeclaratorList?.[0]
          ?.children?.variableDeclarator?.[0]
          ?.children?.variableDeclaratorId?.[0]
          ?.children?.Identifier?.[0];

        if (isPublic && isStatic && isFinal && nameNode?.image) {
          constants.push({
            name: nameNode.image,
            line: nameNode.startLine || 1
          });
        }
      }
  
      // Walk children
      for (const key of Object.keys(node.children || {})) {
        const children = node.children[key];
        if (Array.isArray(children)) {
          children.forEach(walk);
        }
      }
    }
  
    walk(cst);
    return constants;
  }
