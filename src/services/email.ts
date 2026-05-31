interface EmailOptions { to: string; subject: string; html: string; }

const templates: Record<string, { subject: string; html: (d: Record<string, string>) => string }> = {
  welcome: { subject: "Welcome to Demo SaaS", html: (d) => `<h1>Welcome, ${d.name}!</h1><p>Get started by creating your first project.</p>` },
  passwordReset: { subject: "Reset your password", html: (d) => `<p>Click <a href="${d.resetUrl}">here</a> to reset.</p>` },
  teamInvite: { subject: "Team invitation", html: (d) => `<p>${d.inviter} invited you to ${d.teamName}. <a href="${d.url}">Accept</a></p>` },
};

export class EmailService {
  async send(options: EmailOptions): Promise<void> {
    console.log(`[Email] Sending to ${options.to}: ${options.subject}`);
  }

  async sendTemplate(to: string, name: string, data: Record<string, string>): Promise<void> {
    const t = templates[name];
    if (!t) throw new Error(`Template ${name} not found`);
    await this.send({ to, subject: t.subject, html: t.html(data) });
  }
}

export const emailService = new EmailService();
