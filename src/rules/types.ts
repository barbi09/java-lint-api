export interface Issue {
    file: string;
    line?: number;
    message: string;
  }
  
  export type Rule = (ast: any, file: string) => Issue[];