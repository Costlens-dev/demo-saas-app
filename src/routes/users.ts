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
