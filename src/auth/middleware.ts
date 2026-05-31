/**
 * Authentication Middleware
 * Validates JWT tokens and attaches user context to requests
 */
import { Request, Response, NextFunction } from "express";
import { jwtService } from "./jwt";

export function authMiddleware(req: Request, res: Response, next: NextFunction) {
  const authHeader = req.headers.authorization;
  if (!authHeader || !authHeader.startsWith("Bearer ")) {
    return res.status(401).json({ error: "Missing or invalid authorization header" });
  }

  const token = authHeader.substring(7);
  try {
    const payload = jwtService.verifyAccessToken(token);
    (req as any).user = payload;
    next();
  } catch (error) {
    return res.status(401).json({ error: "Invalid or expired token" });
  }
}

export function optionalAuth(req: Request, res: Response, next: NextFunction) {
  const authHeader = req.headers.authorization;
  if (!authHeader) return next();
  
  try {
    const token = authHeader.substring(7);
    const payload = jwtService.verifyAccessToken(token);
    (req as any).user = payload;
  } catch {}
  next();
}
