export function kebabToLowerCamelCase(input: string): string {
    return input.replace(/-([a-z])/g, (_, char: string) => char.toUpperCase());
}
