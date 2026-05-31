import { jwtService } from "./jwt";

export function authMiddleware(req: any, res: any, next: any) {
  const authHeader = req.headers.authorization;
  if (!authHeader?.startsWith("Bearer ")) {
    return res.status(401).json({ error: "Unauthorized" });
  }
  const token = authHeader.substring(7);
  try {
    const payload = jwtService.verifyAccessToken(token);
    if (!payload || !payload.userId) {
      return res.status(401).json({ error: "Invalid token payload" });
    }
    req.user = payload;
    next();
  } catch {
    return res.status(401).json({ error: "Token expired or invalid" });
  }
}

export function optionalAuth(req: any, res: any, next: any) {
  const authHeader = req.headers.authorization;
  if (!authHeader) return next();
  try {
    req.user = jwtService.verifyAccessToken(authHeader.substring(7));
  } catch {}
  next();
}
