#!/bin/bash
set -e

# Helper to create a PR with specific characteristics
create_pr() {
  local branch="$1" title="$2" files="$3"
  git checkout main
  git checkout -b "$branch"
  eval "$files"
  git add -A
  git commit -m "$title"
  git push -u origin "$branch"
  gh pr create --title "$title" --body "" --head "$branch"
  gh pr merge "$branch" --merge --delete-branch
  git checkout main
  git pull origin main
}

# === AI-GENERATED PRs (fast, large, boilerplate) ===

# PR 1: AI - Auth system (large, generated comments, fast)
create_pr "feat/auth-system" "feat: implement JWT authentication with refresh tokens" '
mkdir -p src/auth
cat > src/auth/jwt.ts << INNER
/**
 * JWT Authentication Module
 * Handles token generation, validation, and refresh logic
 */
import jwt from "jsonwebtoken";

interface TokenPayload {
  userId: string;
  email: string;
  role: string;
}

export class JWTService {
  private readonly secret: string;
  private readonly refreshSecret: string;
  private readonly accessTokenExpiry: string = "15m";
  private readonly refreshTokenExpiry: string = "7d";

  constructor() {
    this.secret = process.env.JWT_SECRET || "default-secret";
    this.refreshSecret = process.env.JWT_REFRESH_SECRET || "default-refresh";
  }

  generateAccessToken(payload: TokenPayload): string {
    return jwt.sign(payload, this.secret, { expiresIn: this.accessTokenExpiry });
  }

  generateRefreshToken(payload: TokenPayload): string {
    return jwt.sign(payload, this.refreshSecret, { expiresIn: this.refreshTokenExpiry });
  }

  verifyAccessToken(token: string): TokenPayload {
    return jwt.verify(token, this.secret) as TokenPayload;
  }

  verifyRefreshToken(token: string): TokenPayload {
    return jwt.verify(token, this.refreshSecret) as TokenPayload;
  }

  generateTokenPair(payload: TokenPayload) {
    return {
      accessToken: this.generateAccessToken(payload),
      refreshToken: this.generateRefreshToken(payload),
    };
  }
}

export const jwtService = new JWTService();
INNER

cat > src/auth/middleware.ts << INNER
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
INNER
'

# PR 2: AI - CRUD endpoints (repetitive, boilerplate)
create_pr "feat/user-crud" "feat: add user CRUD API endpoints with validation" '
mkdir -p src/routes src/models
cat > src/routes/users.ts << INNER
import { Router, Request, Response } from "express";
import { authMiddleware } from "../auth/middleware";

const router = Router();

interface CreateUserDTO {
  email: string;
  name: string;
  role?: string;
}

interface UpdateUserDTO {
  name?: string;
  email?: string;
  role?: string;
}

// GET /users - List all users
router.get("/", authMiddleware, async (req: Request, res: Response) => {
  try {
    const page = parseInt(req.query.page as string) || 1;
    const limit = parseInt(req.query.limit as string) || 20;
    const offset = (page - 1) * limit;
    // const users = await db.user.findMany({ skip: offset, take: limit });
    res.json({ data: [], meta: { page, limit, total: 0 } });
  } catch (error) {
    res.status(500).json({ error: "Failed to fetch users" });
  }
});

// GET /users/:id - Get user by ID
router.get("/:id", authMiddleware, async (req: Request, res: Response) => {
  try {
    const { id } = req.params;
    // const user = await db.user.findUnique({ where: { id } });
    res.json({ data: null });
  } catch (error) {
    res.status(500).json({ error: "Failed to fetch user" });
  }
});

// POST /users - Create user
router.post("/", authMiddleware, async (req: Request, res: Response) => {
  try {
    const { email, name, role }: CreateUserDTO = req.body;
    if (!email || !name) {
      return res.status(400).json({ error: "Email and name are required" });
    }
    // const user = await db.user.create({ data: { email, name, role } });
    res.status(201).json({ data: { email, name, role } });
  } catch (error) {
    res.status(500).json({ error: "Failed to create user" });
  }
});

// PUT /users/:id - Update user
router.put("/:id", authMiddleware, async (req: Request, res: Response) => {
  try {
    const { id } = req.params;
    const updates: UpdateUserDTO = req.body;
    // const user = await db.user.update({ where: { id }, data: updates });
    res.json({ data: { id, ...updates } });
  } catch (error) {
    res.status(500).json({ error: "Failed to update user" });
  }
});

// DELETE /users/:id - Delete user
router.delete("/:id", authMiddleware, async (req: Request, res: Response) => {
  try {
    const { id } = req.params;
    // await db.user.delete({ where: { id } });
    res.status(204).send();
  } catch (error) {
    res.status(500).json({ error: "Failed to delete user" });
  }
});

export default router;
INNER
'

# PR 3: AI - Database schema (generated, structured)
create_pr "feat/prisma-schema" "feat: add Prisma schema with User, Team, and Project models" '
cat > prisma/schema.prisma << INNER
generator client {
  provider = "prisma-client-js"
}

datasource db {
  provider = "postgresql"
  url      = env("DATABASE_URL")
}

model User {
  id        String   @id @default(cuid())
  email     String   @unique
  name      String
  role      String   @default("member")
  teamId    String?
  createdAt DateTime @default(now())
  updatedAt DateTime @updatedAt

  team     Team?     @relation(fields: [teamId], references: [id])
  projects Project[]

  @@index([email])
  @@index([teamId])
}

model Team {
  id        String   @id @default(cuid())
  name      String
  slug      String   @unique
  plan      String   @default("free")
  createdAt DateTime @default(now())
  updatedAt DateTime @updatedAt

  members  User[]
  projects Project[]

  @@index([slug])
}

model Project {
  id          String   @id @default(cuid())
  name        String
  description String?
  teamId      String
  ownerId     String
  status      String   @default("active")
  createdAt   DateTime @default(now())
  updatedAt   DateTime @updatedAt

  team  Team @relation(fields: [teamId], references: [id])
  owner User @relation(fields: [ownerId], references: [id])

  @@index([teamId])
  @@index([ownerId])
}
INNER
mkdir -p prisma
'

# PR 4: AI - Test suite (generated, repetitive patterns)
create_pr "feat/auth-tests" "test: add comprehensive auth test suite" '
mkdir -p tests
cat > tests/auth.test.ts << INNER
import { JWTService } from "../src/auth/jwt";

describe("JWTService", () => {
  let service: JWTService;

  beforeEach(() => {
    service = new JWTService();
  });

  describe("generateAccessToken", () => {
    it("should generate a valid access token", () => {
      const payload = { userId: "1", email: "test@test.com", role: "admin" };
      const token = service.generateAccessToken(payload);
      expect(token).toBeDefined();
      expect(typeof token).toBe("string");
    });

    it("should include payload in token", () => {
      const payload = { userId: "1", email: "test@test.com", role: "admin" };
      const token = service.generateAccessToken(payload);
      const decoded = service.verifyAccessToken(token);
      expect(decoded.userId).toBe(payload.userId);
      expect(decoded.email).toBe(payload.email);
    });
  });

  describe("generateRefreshToken", () => {
    it("should generate a valid refresh token", () => {
      const payload = { userId: "1", email: "test@test.com", role: "admin" };
      const token = service.generateRefreshToken(payload);
      expect(token).toBeDefined();
    });
  });

  describe("verifyAccessToken", () => {
    it("should throw on invalid token", () => {
      expect(() => service.verifyAccessToken("invalid")).toThrow();
    });

    it("should throw on expired token", () => {
      // Would need to mock time
      expect(true).toBe(true);
    });
  });

  describe("generateTokenPair", () => {
    it("should return both tokens", () => {
      const payload = { userId: "1", email: "test@test.com", role: "admin" };
      const pair = service.generateTokenPair(payload);
      expect(pair.accessToken).toBeDefined();
      expect(pair.refreshToken).toBeDefined();
    });
  });
});
INNER
'

# PR 5: Manual - Bug fix (small, targeted)
create_pr "fix/null-check" "fix: handle null user in auth middleware" '
cat > src/auth/middleware.ts << INNER
import { Request, Response, NextFunction } from "express";
import { jwtService } from "./jwt";

export function authMiddleware(req: Request, res: Response, next: NextFunction) {
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
    (req as any).user = payload;
    next();
  } catch {
    return res.status(401).json({ error: "Token expired or invalid" });
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
INNER
'

# PR 6: Manual - Config tweak (tiny)
create_pr "fix/env-defaults" "fix: use stricter env validation" '
cat > src/config.ts << INNER
function requireEnv(key: string): string {
  const val = process.env[key];
  if (!val) throw new Error(`Missing required env: ${key}`);
  return val;
}

export const config = {
  port: parseInt(process.env.PORT || "3000"),
  jwtSecret: requireEnv("JWT_SECRET"),
  databaseUrl: requireEnv("DATABASE_URL"),
};
INNER
'

# PR 7: AI - API docs (generated, large)
create_pr "feat/api-docs" "docs: add OpenAPI specification for all endpoints" '
cat > docs/openapi.yaml << INNER
openapi: "3.0.3"
info:
  title: Demo SaaS API
  version: "1.0.0"
  description: API documentation for the Demo SaaS application
paths:
  /auth/login:
    post:
      summary: Authenticate user
      requestBody:
        required: true
        content:
          application/json:
            schema:
              type: object
              properties:
                email:
                  type: string
                password:
                  type: string
      responses:
        "200":
          description: Successful authentication
          content:
            application/json:
              schema:
                type: object
                properties:
                  accessToken:
                    type: string
                  refreshToken:
                    type: string
  /users:
    get:
      summary: List users
      security:
        - bearerAuth: []
      parameters:
        - name: page
          in: query
          schema:
            type: integer
        - name: limit
          in: query
          schema:
            type: integer
      responses:
        "200":
          description: List of users
    post:
      summary: Create user
      security:
        - bearerAuth: []
      requestBody:
        required: true
        content:
          application/json:
            schema:
              type: object
              properties:
                email:
                  type: string
                name:
                  type: string
      responses:
        "201":
          description: User created
  /users/{id}:
    get:
      summary: Get user by ID
      security:
        - bearerAuth: []
      parameters:
        - name: id
          in: path
          required: true
          schema:
            type: string
      responses:
        "200":
          description: User details
    put:
      summary: Update user
      security:
        - bearerAuth: []
      responses:
        "200":
          description: User updated
    delete:
      summary: Delete user
      security:
        - bearerAuth: []
      responses:
        "204":
          description: User deleted
components:
  securitySchemes:
    bearerAuth:
      type: http
      scheme: bearer
      bearerFormat: JWT
INNER
mkdir -p docs
'

# PR 8: AI - Error handling (boilerplate)
create_pr "feat/error-handling" "feat: add global error handler and custom error classes" '
mkdir -p src/errors
cat > src/errors/index.ts << INNER
export class AppError extends Error {
  public readonly statusCode: number;
  public readonly isOperational: boolean;

  constructor(message: string, statusCode: number, isOperational = true) {
    super(message);
    this.statusCode = statusCode;
    this.isOperational = isOperational;
    Object.setPrototypeOf(this, AppError.prototype);
  }
}

export class NotFoundError extends AppError {
  constructor(resource: string) {
    super(\`\${resource} not found\`, 404);
  }
}

export class ValidationError extends AppError {
  constructor(message: string) {
    super(message, 400);
  }
}

export class UnauthorizedError extends AppError {
  constructor(message = "Unauthorized") {
    super(message, 401);
  }
}

export class ForbiddenError extends AppError {
  constructor(message = "Forbidden") {
    super(message, 403);
  }
}

export class ConflictError extends AppError {
  constructor(message: string) {
    super(message, 409);
  }
}
INNER

cat > src/errors/handler.ts << INNER
import { Request, Response, NextFunction } from "express";
import { AppError } from "./index";

export function errorHandler(err: Error, req: Request, res: Response, next: NextFunction) {
  if (err instanceof AppError) {
    return res.status(err.statusCode).json({
      error: err.message,
      statusCode: err.statusCode,
    });
  }

  console.error("Unhandled error:", err);
  return res.status(500).json({
    error: "Internal server error",
    statusCode: 500,
  });
}
INNER
'

# PR 9: Manual - Performance fix (small, specific)
create_pr "fix/query-perf" "perf: add database index for email lookups" '
cat > prisma/migrations/001_add_email_index.sql << INNER
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_users_email ON users (email);
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_users_team_id ON users (team_id);
INNER
mkdir -p prisma/migrations
'

# PR 10: AI - Logging (generated, structured)
create_pr "feat/logging" "feat: add structured logging with request tracing" '
mkdir -p src/lib
cat > src/lib/logger.ts << INNER
import { randomUUID } from "crypto";

type LogLevel = "debug" | "info" | "warn" | "error";

interface LogEntry {
  timestamp: string;
  level: LogLevel;
  message: string;
  traceId?: string;
  data?: Record<string, unknown>;
}

class Logger {
  private level: LogLevel = "info";
  private levels: Record<LogLevel, number> = { debug: 0, info: 1, warn: 2, error: 3 };

  setLevel(level: LogLevel) { this.level = level; }

  private shouldLog(level: LogLevel): boolean {
    return this.levels[level] >= this.levels[this.level];
  }

  private log(level: LogLevel, message: string, data?: Record<string, unknown>) {
    if (!this.shouldLog(level)) return;
    const entry: LogEntry = {
      timestamp: new Date().toISOString(),
      level,
      message,
      traceId: data?.traceId as string,
      data,
    };
    console.log(JSON.stringify(entry));
  }

  debug(msg: string, data?: Record<string, unknown>) { this.log("debug", msg, data); }
  info(msg: string, data?: Record<string, unknown>) { this.log("info", msg, data); }
  warn(msg: string, data?: Record<string, unknown>) { this.log("warn", msg, data); }
  error(msg: string, data?: Record<string, unknown>) { this.log("error", msg, data); }

  createTraceId(): string { return randomUUID(); }
}

export const logger = new Logger();
INNER
'

# PR 11: Manual - Readme update (small)
create_pr "docs/setup" "docs: add local development setup instructions" '
cat >> README.md << INNER

## Setup

1. Clone the repo
2. Copy .env.example to .env
3. Run \`npm install\`
4. Run \`npx prisma migrate dev\`
5. Run \`npm run dev\`

## Environment Variables

- DATABASE_URL - PostgreSQL connection string
- JWT_SECRET - Secret for signing tokens
- PORT - Server port (default: 3000)
INNER
'

# PR 12: AI - Rate limiting (generated)
create_pr "feat/rate-limit" "feat: implement rate limiting middleware with Redis" '
cat > src/lib/rateLimit.ts << INNER
interface RateLimitConfig {
  windowMs: number;
  maxRequests: number;
}

const store = new Map<string, { count: number; resetAt: number }>();

export function rateLimit(config: RateLimitConfig) {
  return (req: any, res: any, next: any) => {
    const key = req.ip || req.headers["x-forwarded-for"] || "unknown";
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
INNER
'

# PR 13: Manual - Security fix (small, critical)
create_pr "fix/xss-sanitize" "fix: sanitize user input to prevent XSS" '
cat > src/lib/sanitize.ts << INNER
const UNSAFE_CHARS: Record<string, string> = {
  "&": "&amp;",
  "<": "&lt;",
  ">": "&gt;",
  "\"": "&quot;",
  "'\''": "&#x27;",
};

export function sanitize(input: string): string {
  return input.replace(/[&<>"'\'']/g, (char) => UNSAFE_CHARS[char] || char);
}
INNER
'

# PR 14: AI - Email service (generated, boilerplate)
create_pr "feat/email-service" "feat: add transactional email service with templates" '
mkdir -p src/services
cat > src/services/email.ts << INNER
interface EmailOptions {
  to: string;
  subject: string;
  html: string;
}

interface EmailTemplate {
  subject: string;
  html: (data: Record<string, string>) => string;
}

const templates: Record<string, EmailTemplate> = {
  welcome: {
    subject: "Welcome to Demo SaaS",
    html: (data) => \`<h1>Welcome, \${data.name}!</h1><p>Get started by creating your first project.</p>\`,
  },
  passwordReset: {
    subject: "Reset your password",
    html: (data) => \`<p>Click <a href="\${data.resetUrl}">here</a> to reset your password.</p>\`,
  },
  teamInvite: {
    subject: "You have been invited to a team",
    html: (data) => \`<p>\${data.inviter} invited you to join \${data.teamName}. <a href="\${data.inviteUrl}">Accept</a></p>\`,
  },
};

export class EmailService {
  async send(options: EmailOptions): Promise<void> {
    console.log(\`[Email] Sending to \${options.to}: \${options.subject}\`);
    // In production: use Resend/SendGrid/SES
  }

  async sendTemplate(to: string, templateName: string, data: Record<string, string>): Promise<void> {
    const template = templates[templateName];
    if (!template) throw new Error(\`Template \${templateName} not found\`);
    await this.send({ to, subject: template.subject, html: template.html(data) });
  }
}

export const emailService = new EmailService();
INNER
'

# PR 15: Manual - Dependency bump (small)
create_pr "chore/deps" "chore: bump express to 4.19.2 for security patch" '
cat > package.json << INNER
{
  "name": "demo-saas-app",
  "version": "1.0.0",
  "dependencies": {
    "express": "^4.19.2",
    "jsonwebtoken": "^9.0.2",
    "@prisma/client": "^5.14.0"
  },
  "devDependencies": {
    "typescript": "^5.4.5",
    "jest": "^29.7.0",
    "prisma": "^5.14.0"
  }
}
INNER
'

echo "Done! All PRs created and merged."
