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
    const entry: LogEntry = { timestamp: new Date().toISOString(), level, message, data };
    console.log(JSON.stringify(entry));
  }

  debug(msg: string, data?: Record<string, unknown>) { this.log("debug", msg, data); }
  info(msg: string, data?: Record<string, unknown>) { this.log("info", msg, data); }
  warn(msg: string, data?: Record<string, unknown>) { this.log("warn", msg, data); }
  error(msg: string, data?: Record<string, unknown>) { this.log("error", msg, data); }
}

export const logger = new Logger();
