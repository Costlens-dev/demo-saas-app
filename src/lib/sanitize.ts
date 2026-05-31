const UNSAFE: Record<string, string> = { "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;" };

export function sanitize(input: string): string {
  return input.replace(/[&<>"]/g, (c) => UNSAFE[c] || c);
}
