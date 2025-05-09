import { Rule, Issue, Operation } from './types';

export const validatePomData: Rule = (_: any, file: any, operationsData: Operation[]): Issue[] => {
  const issues: Issue[] = [];
  const rule: string = 'Validate Pom Data';  
  const artifactId = operationsData[0].nameMS;
  const properties = file?.properties?.[0] || {};

  const yamlFile = properties['openapi.yaml.file']?.[0];
  const modelPackage = properties['openapi.model.package']?.[0];

  const expectedYamlFile = `\${project.basedir}/src/main/resources/app-${artifactId?.toLowerCase()}-generate-dto.yaml`;
  const expectedModelPackage = artifactId;

  if (yamlFile !== expectedYamlFile) {
    issues.push({
      rule,
      file: 'pom.xml',
      line: 1,
      message: `Invalid <openapi.yaml.file>. Expected "${expectedYamlFile}", found "${yamlFile}"`,
    });
  }

  if (modelPackage !== expectedModelPackage) {
    issues.push({
      rule,
      file: 'pom.xml',
      line: 1,
      message: `Invalid <openapi.model.package>. Expected "${expectedModelPackage}", found "${modelPackage}"`,
    });
  }

  return issues;
};
