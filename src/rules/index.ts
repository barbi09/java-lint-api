import { Rule } from './types';
import { validateNameMethods } from './validateNameMethods';
import { validateUnusedImportsAndMethods } from './validateUnusedImportsAndMethods';
// import other rules here

export const rules: Rule[] = [
  validateNameMethods,
  validateUnusedImportsAndMethods
  // other rules go here
];