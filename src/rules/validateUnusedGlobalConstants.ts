import { Issue, Rule } from "./types";

export const validateUnusedGlobalConstants: Rule = (cst, file, globalConstants) => {
    const issues: Issue[] = [];

    const usedIdentifiers = new Set<string>();
    console.log("globalConstants", globalConstants);
    function walk(node: any) {
        if (!node || typeof node !== 'object') return;

        // ✅ Detect Constants.XYZ usage
        if (node.name === 'expression') {
            const primary = node.children?.primary?.[0];
            const identifier = primary?.children?.Identifier;

            if (Array.isArray(identifier) && identifier[0]?.image === 'Constants') {
                const suffix = primary.children?.fieldAccess?.[0]?.children?.Identifier?.[0]?.image;
                if (suffix) {
                    console.log("suffix", suffix);
                    usedIdentifiers.add(suffix);
                }
            }
        }

        // Recurse
        for (const key of Object.keys(node.children || {})) {
            const children = node.children[key];
            if (Array.isArray(children)) {
                children.forEach(walk);
            }
        }
    }


    walk(cst);

    // Check globalConstants declared in Constants.java
    for (const constant of globalConstants || []) {
        if (!usedIdentifiers.has(constant.name)) {
            issues.push({
                rule: 'Unused Global Constants',
                file: 'Constants.java',
                line: constant.line,
                message: `Constant "${constant.name}" is declared but not used in the project.`
            });
        }
    }

    return issues;
};
