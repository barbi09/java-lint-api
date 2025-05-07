import { Issue, Operation, Rule } from './types';
import { CONTROLLER_SERVICES_CLASSES, WEB_CLIENT_CLASSES, METHODS_EXCLUDED, RESPONSE_HANDLER_CLASSES, RESPONSE_MAPPER_CLASSES } from '../commons/constants';
import { kebabToLowerCamelCase, isLowerCamelCase } from '../commons/utils';

export const validateNameMethods: Rule = (cst: any, file: string,  operations: Operation[] ): Issue[] => {
  const issues: Issue[] = [];
  const rule: string = 'Validate Name Methods';  

  function walk(node: any) {
    if (!node || typeof node !== 'object') return;

    const isMethodNode = node.name === 'methodDeclaration' || node.name === 'interfaceMethodDeclaration';

    if (isMethodNode) {
      const methodName = node.children?.methodHeader?.[0]
        ?.children?.methodDeclarator?.[0]
        ?.children?.Identifier?.[0]?.image;
      const line = node.location?.startLine;

      if (methodName) {
        validateControllerServiceMethodName(methodName, file, line, operations, issues);
        validateWebClientBackendsMethodName(methodName, file, line, operations, issues);
        validateAppResponseHandlerMethodName(methodName, file, line, operations, issues);
        validateAppResponseMapperMethodName(methodName, file, line, operations, issues);
      }
    }

    // Walk children
    if (node.children) {
      for (const key of Object.keys(node.children)) {
        const children = node.children[key];
        if (Array.isArray(children)) {
          children.forEach(walk);
        }
      }
    }
  }

  function validateControllerServiceMethodName(methodName: any, file: string, line: number, operations: Operation[], issues: Issue[] ): void {
    const classNames = CONTROLLER_SERVICES_CLASSES.some(className => file.includes(className));
    const validOperations = operations.map(op => kebabToLowerCamelCase(op.id)) || [];
 
    if (classNames && !validOperations.includes(methodName)) {
      issues.push({
        rule,
        file,
        line,
        message: `Method "${methodName}" does not match any expected operationId from Excel. Expected one of: ${validOperations.join(', ')}.`,
      });
    }
  }

  function validateWebClientBackendsMethodName(methodName: any, file: string, line: number, operations: Operation[], issues: Issue[] ): void {

    const classNames = WEB_CLIENT_CLASSES.some(className => file.includes(className));
    const isExcludedMethod = METHODS_EXCLUDED.some(prefix => methodName.startsWith(prefix));
    const validOperations = operations.flatMap(({ backendId, backendOperationId }) => {
      const operationId = kebabToLowerCamelCase(backendOperationId);
    
      const variants = [
        `${backendId}_${operationId}`,
        `backend_${backendId}_${operationId}`
      ];
    
      return variants;
    });    

    if (classNames && !validOperations.includes(methodName) && !isExcludedMethod) {
      issues.push({
        rule,
        file,
        line,
        message: `Method "${methodName}" does not match any expected WebClientBackends method naming convention. Expected one of: ${validOperations.join(', ')}.`,
      });
    }else if( classNames && isExcludedMethod && !isLowerCamelCase(methodName)){
      issues.push({
        rule,
        file,
        line,
        message: `Method "${methodName}" should be in lowerCamelCase format.`,
      });
    }
  }

  function validateAppResponseHandlerMethodName(methodName: any, file: string, line: number, operations: Operation[], issues: Issue[] ): void {

    const classNames = RESPONSE_HANDLER_CLASSES.some(className => file.includes(className));
    const isExcludedMethod = METHODS_EXCLUDED.some(prefix => methodName.startsWith(prefix));
    const validOperations = operations.flatMap(({ backendId, backendOperationId }) => {
      return `handleResponse_${backendId}_${kebabToLowerCamelCase(backendOperationId)}`;
    });    

    if (classNames && !validOperations.includes(methodName) && !isExcludedMethod) {
      issues.push({
        rule,
        file,
        line,
        message: `Method "${methodName}" does not match any expected AppResponseHandler method naming convention. Expected one of: ${validOperations.join(', ')}.`,
      });
    }else if( classNames && isExcludedMethod && !isLowerCamelCase(methodName)){
      issues.push({
        rule,
        file,
        line,
        message: `Method "${methodName}" should be in lowerCamelCase format.`,
      });
    }
  }

  function validateAppResponseMapperMethodName(methodName: any, file: string, line: number, operations: Operation[], issues: Issue[] ): void {

    const classNames = RESPONSE_MAPPER_CLASSES.some(className => file.includes(className));
    const isExcludedMethod = METHODS_EXCLUDED.some(prefix => methodName.startsWith(prefix));
    const validOperations = operations.map(op => `map_${kebabToLowerCamelCase(op.id)}Response`) || [];

    if (classNames && !validOperations.includes(methodName) && !isExcludedMethod) {
      issues.push({
        rule,
        file,
        line,
        message: `Method "${methodName}" does not match any expected AppResponseMapper method naming convention. Expected one of: ${validOperations.join(', ')}.`,
      });
    }else if( classNames && isExcludedMethod && !isLowerCamelCase(methodName)){
      issues.push({
        rule,
        file,
        line,
        message: `Method "${methodName}" should be in lowerCamelCase format.`,
      });
    }
  }

  walk(cst);
  return issues;
};
