import { TAGS_DTO, TAGS_DTO_REQUEST, TAGS_DTO_RESPONSE } from '../commons/constants';
import { Rule, Issue } from './types';

export const validateDtoAnnotations: Rule = (cst: any, file: string): Issue[] => {
    const issues: Issue[] = [];

    const normalizedPath = file.replace(/\\/g, '/');
    const isRequestDto = /dto\/backend\/[^/]+\/request/.test(normalizedPath);
    const isResponseDto = /dto\/backend\/[^/]+\/response/.test(normalizedPath);

    if (!isRequestDto && !isResponseDto) return issues;

    const requiredAnnotations: string[] = [...TAGS_DTO];
    if (isRequestDto) requiredAnnotations.push(...TAGS_DTO_REQUEST);
    if (isResponseDto) requiredAnnotations.push(...TAGS_DTO_RESPONSE);

    let annotationsFound: string[] = [];
    let hasXmlAccessorType = false;

    function walk(node: any) {
        if (!node || typeof node !== 'object') return;

        // Class-level annotations
        if (node.name === 'classDeclaration') {
            const modifiers = node.children?.classModifier || [];
            for (const mod of modifiers) {
                const ann = mod?.children?.annotation?.[0];
                const annotationName = ann?.children?.typeName?.[0]?.children?.Identifier?.map((id: any) => id.image).join('.');
                
                if (annotationName) {
                    const formatted = '@' + annotationName;
                    annotationsFound.push(formatted);
                    if (formatted === '@XmlAccessorType') {
                        hasXmlAccessorType = true;
                    }
                }
            }
        }

        // Recurse
        for (const key of Object.keys(node.children || {})) {
            const children = node.children[key];
            if (Array.isArray(children)) children.forEach(walk);
        }
    }

    walk(cst);

    const expected = hasXmlAccessorType
        ? TAGS_DTO
        : requiredAnnotations;

    for (const annotation of expected) {
        if (!annotationsFound.includes(annotation)) {
            issues.push({
                rule: 'Validate Dto Annotations',
                file,
                line: 1,
                message: `Class is missing required annotation ${annotation}`,
            });
        }
    }

    return issues;
};
