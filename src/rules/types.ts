export interface Issue {
    file: string;
    line?: number;
    message: string;
  }

export interface Operation {
  id: string;
  backendOperationId: string;
}
  
  export type Rule = (ast: any, file: string) => Issue[];