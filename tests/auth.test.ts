import { JWTService } from "../src/auth/jwt";

describe("JWTService", () => {
  let service: JWTService;
  beforeEach(() => { service = new JWTService(); });

  describe("generateAccessToken", () => {
    it("should generate a valid access token", () => {
      const token = service.generateAccessToken({ userId: "1", email: "t@t.com", role: "admin" });
      expect(token).toBeDefined();
      expect(typeof token).toBe("string");
    });

    it("should include payload in token", () => {
      const payload = { userId: "1", email: "t@t.com", role: "admin" };
      const token = service.generateAccessToken(payload);
      const decoded = service.verifyAccessToken(token);
      expect(decoded.userId).toBe(payload.userId);
    });
  });

  describe("generateRefreshToken", () => {
    it("should generate a valid refresh token", () => {
      const token = service.generateRefreshToken({ userId: "1", email: "t@t.com", role: "admin" });
      expect(token).toBeDefined();
    });
  });

  describe("verifyAccessToken", () => {
    it("should throw on invalid token", () => {
      expect(() => service.verifyAccessToken("invalid")).toThrow();
    });
  });

  describe("generateTokenPair", () => {
    it("should return both tokens", () => {
      const pair = service.generateTokenPair({ userId: "1", email: "t@t.com", role: "admin" });
      expect(pair.accessToken).toBeDefined();
      expect(pair.refreshToken).toBeDefined();
    });
  });
});
