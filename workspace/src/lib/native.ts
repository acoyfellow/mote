export type MachineMode = "core" | "pi";
export type MachineAction = "start" | "stop" | "restart";

type MoteResult = Record<string, unknown>;

declare global {
  interface Window {
    mote?: {
      invoke(command: string, arguments?: Record<string, unknown>): Promise<MoteResult>;
    };
  }
}

async function invoke(command: string, arguments_: Record<string, unknown> = {}): Promise<MoteResult> {
  if (!window.mote) {
    return demo(command, arguments_);
  }
  return window.mote.invoke(command, arguments_);
}

function demo(command: string, arguments_: Record<string, unknown>): MoteResult {
  if (command === "machinectl.status") return { output: "running 71193 core", exitCode: 0 };
  if (command === "reachability.status") return { output: "off sleepDisabled=0", exitCode: 0 };
  if (command === "maintenance.report") {
    return { output: "Disk free: 128G · Caches: 14G · npm: 2.1G · bun: 1.3G · pnpm: 0B\nLast cleanup: yesterday", exitCode: 0 };
  }
  if (command === "authResource.status" || command === "authResource.refresh") {
    return {
      label: "Configured auth",
      resourceId: "configured-auth",
      output: JSON.stringify({
        resources: [{ id: "configured-auth", state: "refreshable", expiresAt: new Date(Date.now() + 12 * 60_000).toISOString() }]
      }),
      exitCode: 0,
    };
  }
  return { output: `Preview: ${command} ${JSON.stringify(arguments_)}`, exitCode: 0 };
}

export const native = {
  app: {
    info: () => invoke("app.info"),
    configuration: () => invoke("app.configuration"),
    openWorkspace: () => invoke("app.openWorkspace"),
    openLogs: () => invoke("app.openLogs"),
  },
  machinectl: {
    status: () => invoke("machinectl.status"),
    action: (action: MachineAction, mode: MachineMode = "core") =>
      invoke("machinectl.action", { action, mode }),
  },
  reachability: {
    status: () => invoke("reachability.status"),
    start: (seconds: number) => invoke("reachability.action", { action: "start", seconds }),
    stop: () => invoke("reachability.action", { action: "stop" }),
  },
  maintenance: {
    report: () => invoke("maintenance.report"),
    cleanup: () => invoke("maintenance.cleanup"),
  },
  authResource: {
    status: () => invoke("authResource.status"),
    refresh: () => invoke("authResource.refresh"),
  },
};
