interface RateLimitConfig {
  windowMs: number;
  maxRequests: number;
}

const store = new Map<string, { count: number; resetAt: number }>();

export function rateLimit(config: RateLimitConfig) {
  return (req: any, res: any, next: any) => {
    const key = req.ip || "unknown";
    const now = Date.now();
    const entry = store.get(key);

    if (!entry || now > entry.resetAt) {
      store.set(key, { count: 1, resetAt: now + config.windowMs });
      return next();
    }

    if (entry.count >= config.maxRequests) {
      return res.status(429).json({ error: "Too many requests" });
    }

    entry.count++;
    next();
  };
}
