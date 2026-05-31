import { AppError } from "./index";

export function errorHandler(err: Error, req: any, res: any, next: any) {
  if (err instanceof AppError) {
    return res.status(err.statusCode).json({ error: err.message, statusCode: err.statusCode });
  }
  console.error("Unhandled error:", err);
  return res.status(500).json({ error: "Internal server error", statusCode: 500 });
}
