# Demo SaaS App\nA sample project for CostLens demo purposes.

## Setup

1. Clone the repo
2. Copy `.env.example` to `.env`
3. Run `npm install`
4. Run `npx prisma migrate dev`
5. Run `npm run dev`

## Environment Variables

- `DATABASE_URL` - PostgreSQL connection string
- `JWT_SECRET` - Secret for signing tokens
- `PORT` - Server port (default: 3000)
