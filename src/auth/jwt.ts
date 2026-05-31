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
