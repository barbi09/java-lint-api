import { Rule } from './types';
import { validateNameMethods } from './validateNameMethods';
import { validateUnusedGlobalConstants } from './validateUnusedGlobalConstants';
import { validateUnusedImportsAndMethods } from './validateUnusedImportsAndMethods';
// import other rules here

export const rules: Rule[] = [
  validateNameMethods,
  validateUnusedImportsAndMethods,
  validateUnusedGlobalConstants
  // other rules go here
];