// Pulse client for the Mote panel.
//
// Pulse is the "finished agent run" feed exposed by Terrarium
// (live: https://terrarium.coey.dev). The panel consumes terminal events:
//   GET  /status?subscriberId=ID&ownerRunId=OWNER
//   POST /claim {subscriberId,ownerRunId,limit} -> {events:[...]}
//   POST /ack   {subscriberId,ownerRunId,eventId}
// All requests carry `authorization: Bearer <PULSE_TOKEN>`. Token-gated only.
//
// This client runs inside the WKWebView and talks to Pulse with a plain
// `fetch()`. No Swift recompile is required: the URL + token are read from
// configuration the webview can already access (see resolvePulseConfig).
//
// SECURITY: no secret is hardcoded. The token is supplied at build time via
// Vite env (VITE_PULSE_TOKEN) or injected at runtime via window.__MOTE_PULSE__.
// If no token is present, Pulse is "disabled" and the panel hides/greys the
// section.

export const DEFAULT_PULSE_URL = "https://terrarium.coey.dev";

export type PulseEvent = {
  eventId: string;
  runId: string;
  status?: string; // "ok" | "error" | "cancelled" | "timeout" | ...
  ok?: boolean;
  task?: string;
  summary?: string;
  finishedAt?: string; // ISO timestamp
  ownerRunId?: string;
};

export type PulseConfig = {
  enabled: boolean;
  url: string;
  token: string;
  subscriberId: string;
  ownerRunId: string;
};

export type PulseStatus = {
  pending?: number;
  inflight?: number;
  subscriberId?: string;
  ownerRunId?: string;
  ok?: boolean;
};

type RuntimePulseConfig = Partial<{
  url: string;
  token: string;
  subscriberId: string;
  ownerRunId: string;
}>;

declare global {
  interface Window {
    // Optional runtime injection point. A host (or a local bootstrap script
    // loaded by index.html) can set this without rebuilding to avoid baking a
    // token into the bundle. Example:
    //   window.__MOTE_PULSE__ = { token: "...", subscriberId: "mote", ownerRunId: "all" }
    __MOTE_PULSE__?: RuntimePulseConfig;
  }
}

function readEnv(key: string): string | undefined {
  try {
    // import.meta.env is replaced at build time by Vite.
    const env = (import.meta as unknown as { env?: Record<string, string> }).env;
    const value = env?.[key];
    return value && value.length > 0 ? value : undefined;
  } catch {
    return undefined;
  }
}

/**
 * Resolve Pulse configuration from (in priority order):
 *   1. window.__MOTE_PULSE__  (runtime injection, no rebuild)
 *   2. Vite env VITE_PULSE_*  (baked at build time)
 * Pulse is only "enabled" when a non-empty token is available.
 */
export function resolvePulseConfig(): PulseConfig {
  const runtime = (typeof window !== "undefined" && window.__MOTE_PULSE__) || {};

  const url =
    runtime.url ?? readEnv("VITE_PULSE_URL") ?? DEFAULT_PULSE_URL;
  const token = runtime.token ?? readEnv("VITE_PULSE_TOKEN") ?? "";
  const subscriberId =
    runtime.subscriberId ?? readEnv("VITE_PULSE_SUBSCRIBER_ID") ?? "mote-panel";
  const ownerRunId =
    runtime.ownerRunId ?? readEnv("VITE_PULSE_OWNER_RUN_ID") ?? "all";

  return {
    enabled: token.trim().length > 0,
    url: url.replace(/\/+$/, ""),
    token: token.trim(),
    subscriberId,
    ownerRunId,
  };
}

function headers(config: PulseConfig): HeadersInit {
  return {
    authorization: `Bearer ${config.token}`,
    "content-type": "application/json",
    accept: "application/json",
  };
}

async function parseJson(response: Response): Promise<Record<string, unknown>> {
  const text = await response.text();
  if (!response.ok) {
    throw new Error(`pulse ${response.status}: ${text.slice(0, 200) || response.statusText}`);
  }
  if (!text) return {};
  try {
    return JSON.parse(text) as Record<string, unknown>;
  } catch {
    throw new Error(`pulse returned non-JSON: ${text.slice(0, 120)}`);
  }
}

function normalizeEvent(raw: Record<string, unknown>): PulseEvent {
  const data = (raw.event as Record<string, unknown>) ?? raw;
  const payload = (data.payload as Record<string, unknown>) ?? {};
  const eventId = String(
    data.eventId ?? data.id ?? raw.eventId ?? raw.id ?? crypto.randomUUID?.() ?? Math.random()
  );
  const runId = String(data.runId ?? payload.runId ?? raw.runId ?? "unknown");
  const ok = (data.ok ?? payload.ok) as boolean | undefined;
  const status =
    (data.status as string | undefined) ??
    (payload.status as string | undefined) ??
    (typeof ok === "boolean" ? (ok ? "ok" : "error") : undefined);
  return {
    eventId,
    runId,
    status,
    ok,
    task: (data.task ?? payload.task) as string | undefined,
    summary: (data.summary ?? payload.summary) as string | undefined,
    finishedAt: (data.finishedAt ?? data.ts ?? payload.finishedAt) as string | undefined,
    ownerRunId: (data.ownerRunId ?? raw.ownerRunId) as string | undefined,
  };
}

/** GET /status — lightweight queue depth check. */
export async function pulseStatus(config: PulseConfig): Promise<PulseStatus> {
  const query = new URLSearchParams({
    subscriberId: config.subscriberId,
    ownerRunId: config.ownerRunId,
  });
  const response = await fetch(`${config.url}/status?${query.toString()}`, {
    method: "GET",
    headers: headers(config),
  });
  const json = await parseJson(response);
  return {
    pending: typeof json.pending === "number" ? json.pending : undefined,
    inflight: typeof json.inflight === "number" ? json.inflight : undefined,
    subscriberId: config.subscriberId,
    ownerRunId: config.ownerRunId,
    ok: true,
  };
}

/** POST /claim — pull up to `limit` terminal events. */
export async function pulseClaim(config: PulseConfig, limit = 10): Promise<PulseEvent[]> {
  const response = await fetch(`${config.url}/claim`, {
    method: "POST",
    headers: headers(config),
    body: JSON.stringify({
      subscriberId: config.subscriberId,
      ownerRunId: config.ownerRunId,
      limit,
    }),
  });
  const json = await parseJson(response);
  const events = Array.isArray(json.events) ? json.events : [];
  return events.map((event) => normalizeEvent(event as Record<string, unknown>));
}

/** POST /ack — acknowledge a claimed event so it is not redelivered. */
export async function pulseAck(config: PulseConfig, eventId: string): Promise<void> {
  const response = await fetch(`${config.url}/ack`, {
    method: "POST",
    headers: headers(config),
    body: JSON.stringify({
      subscriberId: config.subscriberId,
      ownerRunId: config.ownerRunId,
      eventId,
    }),
  });
  await parseJson(response);
}

/**
 * Convenience: claim recent terminal events. Does NOT auto-ack so the panel
 * can show them across refreshes; the panel acks explicitly when the user
 * dismisses an event. Errors are surfaced to the caller.
 */
export async function pulseRecent(config: PulseConfig, limit = 10): Promise<PulseEvent[]> {
  if (!config.enabled) return [];
  return pulseClaim(config, limit);
}
