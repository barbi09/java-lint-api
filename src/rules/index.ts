import { Rule } from './types';
import { validateDtoAnnotations } from './validateDtoAnnotations';
import { validateDtoPropertiesName } from './validateDtoPropertiesName';
import { validateNameMethods } from './validateNameMethods';
import { validateUnusedImportsAndMethods } from './validateUnusedImportsAndMethods';
// import other rules here

export const rules: Rule[] = [
  validateNameMethods,
  validateUnusedImportsAndMethods,
  validateDtoAnnotations,
  validateDtoPropertiesName
  // other rules go here
];