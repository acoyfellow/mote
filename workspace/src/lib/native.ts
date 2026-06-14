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
  if (command === "app.configuration") return { customConfigured: false, machineLabel: "Local service", endpointLabel: "Optional route" };
  if (command === "machinectl.status") return { output: "running 71193 core", exitCode: 0 };
  if (command === "reachability.status") return { output: "off sleepDisabled=0", exitCode: 0 };
  if (command === "maintenance.report") {
    return { output: "Disk free: 128G · Caches: 14G · npm: 2.1G · bun: 1.3G · pnpm: 0B\nLast cleanup: yesterday", exitCode: 0 };
  }
  if (command === "remoteCoordinator.overview") {
    return {
      label: "Remote activity",
      connector: { connected: true, machineName: "local-machine", tools: Array.from({ length: 8 }) },
      sessions: { result: { sessions: [{ id: "demo-session", name: "Review the current change", status: "active", updated_at: new Date().toISOString() }] } },
      attention: { result: { unread: 1, items: [{ id: "00000000-0000-0000-0000-000000000000", title: "Review requested", body: "A remote task needs your attention.", seen_at: null }] } },
    };
  }
  if (command.startsWith("remoteCoordinator.")) return { ok: true };
  if (command === "authResource.status" || command === "authResource.refresh" || command === "authResource.recover") {
    return {
      label: "Configured auth",
      resourceId: "configured-auth",
      recoverAvailable: true,
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
    recover: () => invoke("authResource.recover"),
  },
  remoteCoordinator: {
    overview: () => invoke("remoteCoordinator.overview"),
    acknowledge: (id: string) => invoke("remoteCoordinator.acknowledge", { id }),
    steer: (sessionId: string, content: string) => invoke("remoteCoordinator.steer", { sessionId, content }),
    open: () => invoke("remoteCoordinator.open"),
  },
};
