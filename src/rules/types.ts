export interface Issue {
    rule: string;
    file: string;
    line?: number;
    message: string;
  }

export interface Operation {
  id: string;
  backendOperationId: string;
  backendId: string;
}
  
export type Rule = (cst: any, file: string, context?: any) => Issue[];