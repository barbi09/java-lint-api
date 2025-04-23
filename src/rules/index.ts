import { Rule } from './types';
import { validateNameMethods } from './validateNameMethods';
// import other rules here

export const rules: Rule[] = [
  validateNameMethods,
  // other rules go here
];