import { logger } from "../lib/logger";

interface WebhookEvent {
  id: string;
  type: string;
  data: Record<string, unknown>;
  createdAt: string;
}

type WebhookHandler = (event: WebhookEvent) => Promise<void>;

const handlers: Record<string, WebhookHandler> = {
  "user.created": async (event) => {
    logger.info("User created", { userId: event.data.id as string });
  },
  "user.deleted": async (event) => {
    logger.info("User deleted", { userId: event.data.id as string });
  },
  "subscription.updated": async (event) => {
    logger.info("Subscription updated", { subId: event.data.id as string });
  },
  "payment.succeeded": async (event) => {
    logger.info("Payment succeeded", { amount: event.data.amount as number });
  },
  "payment.failed": async (event) => {
    logger.warn("Payment failed", { customerId: event.data.customerId as string });
  },
};

export async function processWebhook(event: WebhookEvent): Promise<void> {
  const handler = handlers[event.type];
  if (!handler) {
    logger.warn(`No handler for event type: ${event.type}`);
    return;
  }
  await handler(event);
}
