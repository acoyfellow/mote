<script lang="ts">
  import { onMount } from "svelte";
  import { Activity, ChevronRight, Clock3, FolderOpen, KeyRound, Laptop, Moon, Pencil, Play, Plus, Power, RefreshCw, Save, Square, Sparkles, Trash2, Wrench, X } from "@lucide/svelte";
  import { native, type MachineAction, type MachineMode } from "./lib/native";

  let machineOutput = $state("checking");
  let reachabilityOutput = $state("checking");
  type PortalStatus = { state: string; accessTokenState?: string; expiresAt?: string | null; recoverAvailable?: boolean; checkedAt?: string; mcpState?: string };
  type RemoteSession = { id: string; name?: string; status?: string; updated_at?: string };
  type AttentionItem = { id: string; title?: string; body?: string; seen_at?: string | null };
  type LoopRun = { startedAt?: string; finishedAt?: string; exitCode?: number; pid?: number; logPath?: string };
  type LoopDefinition = { name: string; run: string; schedule?: string; cwd?: string; latest?: LoopRun | null };
  type LoopsState = { configPath?: string; watcher?: { running?: boolean; record?: { pid?: number; startedAt?: string } | null }; loops?: LoopDefinition[] };
  type TerrariumRun = { runId: string; status?: string; task?: string; progressText?: string; needsAttention?: boolean; startedAt?: string; taskContractStatus?: string };
  type TerrariumState = { activeCount?: number; runs?: TerrariumRun[] };
  type TerrariumDoctor = { ok?: boolean; checks?: { activeRuns?: number; orphanedRuns?: number; needsAttentionRuns?: number; groups?: number; subscribers?: number; pendingCallbacks?: number; inflightCallbacks?: number; staleChildClaims?: number }; warnings?: string[] };

  let maintenanceOutput = $state("checking");
  let customConfigured = $state<boolean | null>(null);
  let machineLabel = $state("Local service");
  let endpointLabel = $state("Optional route");
  let authLabel = $state("Configured auth");
  let portalStatus = $state<PortalStatus>({ state: "checking" });
  let busy = $state<string | null>(null);
  let error = $state<string | null>(null);
  let updatedAt = $state<Date | null>(null);
  let refreshing = $state(false);
  let maintenanceRefreshing = $state(false);
  let portalRefreshing = $state(false);
  let portalRecovering = $state(false);
  let remoteLabel = $state("Remote activity");
  let remoteConnected = $state(false);
  let remoteToolCount = $state(0);
  let remoteSessions = $state<RemoteSession[]>([]);
  let attentionItems = $state<AttentionItem[]>([]);
  let remoteRefreshing = $state(false);
  let remoteError = $state<string | null>(null);
  let steeringSession = $state<string | null>(null);
  let steeringMessage = $state("");
  let loopsLabel = $state("loops.yaml");
  let loopsState = $state<LoopsState>({});
  let loopsRefreshing = $state(false);
  let loopsError = $state<string | null>(null);
  let editingLoop = $state<LoopDefinition | null>(null);
  let loopLogs = $state<{ name: string; text: string } | null>(null);
  let deletePending = $state<string | null>(null);
  let terrariumLabel = $state("Terrarium");
  let terrariumState = $state<TerrariumState>({});
  let terrariumDoctor = $state<TerrariumDoctor>({});
  let terrariumRefreshing = $state(false);
  let terrariumError = $state<string | null>(null);

  const unreadAttention = $derived(attentionItems.filter((item) => !item.seen_at));
  const loops = $derived(loopsState.loops ?? []);
  const watcherRunning = $derived(loopsState.watcher?.running === true);
  const machineBusy = $derived(busy?.startsWith("machine-") ?? false);
  const reachabilityBusy = $derived(busy === "sleep" || busy?.startsWith("awake-") === true);
  const cleanupBusy = $derived(busy === "cleanup");
  const portalExpired = $derived(portalStatus.accessTokenState === "expired");
  const portalConnected = $derived(portalStatus.mcpState === "connected");
  const portalHealthy = $derived(portalConnected);
  const portalMissing = $derived((portalStatus.mcpState !== "connected" || portalStatus.state === "missing" || portalExpired) && portalStatus.recoverAvailable !== false);
  const portalBusy = $derived(portalRefreshing || portalRecovering);
  const portalDetail = $derived.by(() => {
    if (portalStatus.state === "checking") return "checking local grant";
    if (portalStatus.mcpState === "needs authentication") return "local opencode MCP needs authentication";
    if (portalStatus.mcpState === "unknown") return "could not probe local MCP";
    if (portalExpired) return "MCP token expired · reconnect required";
    if (!portalHealthy) return "sign-in needed";
    if (!portalStatus.expiresAt) return "connected · refresh grant stored";
    const expiry = new Date(portalStatus.expiresAt);
    if (Number.isNaN(expiry.getTime())) return "refresh grant stored";
    return `access token until ${expiry.toLocaleTimeString([], { hour: "numeric", minute: "2-digit" })}`;
  });
  const machineRunning = $derived(machineOutput.startsWith("running "));
  const machineMode = $derived(machineOutput.match(/^running\s+\S+\s+(\S+)/)?.[1] ?? "core");
  const reachable = $derived(reachabilityOutput.startsWith("on "));
  const reachabilityOrphaned = $derived(reachabilityOutput.startsWith("orphan "));
  const reachabilityEnd = $derived.by(() => {
    const seconds = Number(reachabilityOutput.match(/ends=(\d+)/)?.[1] ?? 0);
    if (!seconds) return reachable ? "until turned off" : "sleep normally";
    return `until ${new Date(seconds * 1000).toLocaleTimeString([], { hour: "numeric", minute: "2-digit" })}`;
  });
  const diskFree = $derived(maintenanceOutput.match(/Disk free:\s*([^·\n]+)/)?.[1]?.trim() ?? "—");
  const lastCleanup = $derived(maintenanceOutput.match(/Last cleanup:\s*(.+)/)?.[1]?.trim() ?? "—");
  const terrariumRuns = $derived(terrariumState.runs ?? []);
  const terrariumAttention = $derived(terrariumRuns.filter((run) => run.needsAttention));
  const terrariumActive = $derived(terrariumDoctor.checks?.activeRuns ?? terrariumState.activeCount ?? 0);

  async function refreshCore() {
    if (refreshing) return;
    refreshing = true;
    try {
      const [machine, reachability] = await Promise.all([
        native.machinectl.status(),
        native.reachability.status(),
      ]);
      machineOutput = String(machine.output ?? "stopped");
      reachabilityOutput = String(reachability.output ?? "off");
      updatedAt = new Date();
      error = null;
    } catch (reason) {
      error = reason instanceof Error ? reason.message : String(reason);
    } finally {
      refreshing = false;
    }
  }

  async function refreshMaintenance() {
    if (maintenanceRefreshing) return;
    maintenanceRefreshing = true;
    try {
      const maintenance = await native.maintenance.report();
      maintenanceOutput = String(maintenance.output ?? "unavailable");
    } catch (reason) {
      error = reason instanceof Error ? reason.message : String(reason);
    } finally {
      maintenanceRefreshing = false;
    }
  }

  function readMcpStatus(result: Record<string, unknown>): Pick<PortalStatus, "mcpState"> {
    const clean = String(result.output ?? "").replace(/\x1b\[[0-9;?]*[ -/]*[@-~]/g, "");
    const line = clean.split("\n").find((value) => value.includes("cf-portal")) ?? "";
    if (line.includes("connected")) return { mcpState: "connected" };
    if (line.includes("needs authentication")) return { mcpState: "needs authentication" };
    return { mcpState: "unknown" };
  }

  function readPortalStatus(result: Record<string, unknown>): PortalStatus {
    const resourceId = String(result.resourceId ?? "");
    authLabel = String(result.label ?? "Configured auth");
    const report = JSON.parse(String(result.output ?? "{}")) as { resources?: Array<PortalStatus & { id?: string }>; id?: string; state?: string; accessTokenState?: string; expiresAt?: string | null; checkedAt?: string };
    const portal = report.resources?.find((resource) => resource.id === resourceId) ?? (report.id === resourceId ? report : null);
    if (!portal?.state) throw new Error("Configured auth status was not present in local output");
    return {
      state: portal.state,
      accessTokenState: portal.accessTokenState,
      expiresAt: portal.expiresAt,
      recoverAvailable: result.recoverAvailable !== false,
      checkedAt: report.checkedAt,
    };
  }

  async function refreshPortal(force = false) {
    if (portalBusy) return;
    portalRefreshing = true;
    try {
      const [result, mcp] = await Promise.all([
        force ? native.authResource.refresh() : native.authResource.status(),
        native.authResource.mcpStatus(),
      ]);
      portalStatus = { ...readPortalStatus(result), ...readMcpStatus(mcp) };
      error = null;
    } catch (reason) {
      portalStatus = { state: "error" };
      error = reason instanceof Error ? reason.message : String(reason);
    } finally {
      portalRefreshing = false;
    }
  }

  async function recoverPortal() {
    if (portalBusy) return;
    portalRecovering = true;
    error = null;
    try {
      await native.authResource.recover();
      const result = await native.authResource.status();
      portalStatus = readPortalStatus(result);
    } catch (reason) {
      portalStatus = { state: "error" };
      error = reason instanceof Error ? reason.message : String(reason);
    } finally {
      portalRecovering = false;
    }
  }

  async function loadConfiguration() {
    const config = await native.app.configuration();
    customConfigured = config.customConfigured !== false;
    machineLabel = String(config.machineLabel ?? "Local service");
    endpointLabel = String(config.endpointLabel ?? "Optional route");
    return customConfigured;
  }

  async function refreshTerrarium() {
    if (terrariumRefreshing) return;
    terrariumRefreshing = true;
    try {
      const [status, doctor] = await Promise.all([native.terrarium.status(), native.terrarium.doctor()]);
      terrariumLabel = String(status.label ?? "Terrarium");
      terrariumState = (status.data ?? {}) as TerrariumState;
      terrariumDoctor = (doctor.data ?? {}) as TerrariumDoctor;
      terrariumError = null;
    } catch (reason) {
      terrariumState = {};
      terrariumDoctor = {};
      terrariumError = reason instanceof Error ? reason.message : String(reason);
    } finally { terrariumRefreshing = false; }
  }

  async function cancelTerrarium(runId: string) {
    await run(`terrarium-cancel-${runId}`, () => native.terrarium.cancel(runId));
    await refreshTerrarium();
  }

  async function refreshLoops() {
    if (loopsRefreshing) return;
    loopsRefreshing = true;
    try {
      const result = await native.loopsYaml.status();
      loopsLabel = String(result.label ?? "loops.yaml");
      loopsState = (result.data ?? {}) as LoopsState;
      loopsError = null;
    } catch (reason) {
      loopsState = {};
      loopsError = reason instanceof Error ? reason.message : String(reason);
    } finally {
      loopsRefreshing = false;
    }
  }

  function editLoop(loop?: LoopDefinition) {
    editingLoop = loop ? { ...loop } : { name: "", run: "", schedule: "", cwd: "" };
    loopLogs = null;
  }

  async function saveLoop() {
    if (!editingLoop?.name.trim() || !editingLoop.run.trim()) return;
    await run("loop-save", () => native.loopsYaml.set({
      name: editingLoop!.name.trim(),
      run: editingLoop!.run,
      schedule: editingLoop!.schedule ?? "",
      cwd: editingLoop!.cwd ?? "",
    }));
    editingLoop = null;
    await refreshLoops();
  }

  async function deleteLoop(name: string) {
    await run("loop-delete", () => native.loopsYaml.delete(name));
    deletePending = null;
    await refreshLoops();
  }

  function requestDelete(name: string) {
    if (deletePending === name) {
      void deleteLoop(name);
      return;
    }
    deletePending = name;
  }

  async function runLoopNow(name: string) {
    await run(`loop-run-${name}`, () => native.loopsYaml.run(name));
    await refreshLoops();
  }

  async function showLoopLogs(name: string) {
    if (busy) return;
    busy = `loop-logs-${name}`;
    error = null;
    try {
      const result = await native.loopsYaml.logs(name);
      loopLogs = { name, text: String(result.output ?? "No output") };
    } catch (reason) {
      error = reason instanceof Error ? reason.message : String(reason);
    } finally {
      busy = null;
    }
  }

  async function watcherAction(action: "start" | "stop" | "restart") {
    await run(`watcher-${action}`, () => native.loopsYaml.watcher(action));
    await refreshLoops();
  }

  async function refreshRemote() {
    if (remoteRefreshing) return;
    remoteRefreshing = true;
    try {
      const overview = await native.remoteCoordinator.overview() as any;
      remoteLabel = String(overview.label ?? "Remote activity");
      remoteConnected = overview.connector?.connected === true;
      remoteToolCount = Array.isArray(overview.connector?.tools) ? overview.connector.tools.length : 0;
      remoteSessions = Array.isArray(overview.sessions?.result?.sessions) ? overview.sessions.result.sessions : [];
      attentionItems = Array.isArray(overview.attention?.result?.items) ? overview.attention.result.items : [];
      remoteError = null;
    } catch (reason) {
      // Remote auth/connectivity failures stay scoped to this card instead of
      // taking over the whole panel with a global error banner.
      remoteConnected = false;
      remoteSessions = [];
      attentionItems = [];
      remoteError = reason instanceof Error ? reason.message : String(reason);
    } finally {
      remoteRefreshing = false;
    }
  }

  async function acknowledge(id: string) {
    await run("attention", () => native.remoteCoordinator.acknowledge(id));
    await refreshRemote();
  }

  async function sendSteering(sessionId: string) {
    const content = steeringMessage.trim();
    if (!content) return;
    await run("steer", () => native.remoteCoordinator.steer(sessionId, content));
    steeringMessage = "";
    steeringSession = null;
    await refreshRemote();
  }

  async function refreshAll() {
    if (customConfigured === false) {
      const configured = await loadConfiguration();
      if (!configured) return;
    }
    await Promise.all([refreshCore(), refreshPortal(), refreshRemote(), refreshLoops(), refreshTerrarium()]);
    void refreshMaintenance();
  }

  async function run(name: string, operation: () => Promise<unknown>) {
    if (busy) return;
    busy = name;
    error = null;
    try {
      await operation();
      await refreshCore();
    } catch (reason) {
      error = reason instanceof Error ? reason.message : String(reason);
    } finally {
      busy = null;
    }
  }

  function machineAction(action: MachineAction, mode: MachineMode = "core") {
    return run(`machine-${action}`, () => native.machinectl.action(action, mode));
  }

  function formatSessionTime(value?: string) {
    if (!value) return "recent";
    const normalized = value.includes("T") ? value : value.replace(" ", "T") + "Z";
    const date = new Date(normalized);
    if (Number.isNaN(date.getTime())) return "recent";
    return date.toLocaleString([], { month: "short", day: "numeric", hour: "numeric", minute: "2-digit" });
  }

  onMount(() => {
    const timers: number[] = [];
    void (async () => {
      const configured = await loadConfiguration();
      if (!configured) return;
      void refreshAll();
      timers.push(window.setInterval(refreshCore, 30_000));
      timers.push(window.setInterval(refreshMaintenance, 5 * 60_000));
      timers.push(window.setInterval(refreshPortal, 30_000));
      timers.push(window.setInterval(refreshRemote, 30_000));
      timers.push(window.setInterval(refreshLoops, 30_000));
      timers.push(window.setInterval(refreshTerrarium, 5_000));
    })();
    return () => {
      for (const timer of timers) window.clearInterval(timer);
    };
  });
</script>

<svelte:head><title>Mote</title></svelte:head>

<main>
  <header class="topbar">
    <div class="identity">
      <span class="mote-mark"><span></span></span>
      <div>
        <strong>Mote</strong>
        <small>custom panel</small>
      </div>
    </div>
    <button class="icon-button" class:spinning={refreshing} disabled={refreshing} aria-label="Refresh status" onclick={refreshAll}>
      <RefreshCw size={15} strokeWidth={1.8} />
    </button>
  </header>

  {#if error}
    <button class="error-banner" onclick={() => (error = null)}>
      <span>{error}</span><span>×</span>
    </button>
  {/if}

  {#if customConfigured === false}
    <section class="empty-card" aria-labelledby="empty-title">
      <div class="empty-plate" aria-hidden="true">
        <span></span><span></span><span></span><span></span><i></i>
      </div>
      <p class="specimen-label">Blank local panel</p>
      <h1 id="empty-title">Start with an empty Svelte surface.</h1>
      <p>Mote is installed. No custom controls are configured yet. Open the workspace, edit the Svelte files, and add only the native capabilities you need.</p>
      <div class="empty-actions">
        <button class="primary" onclick={() => native.app.openWorkspace()}><FolderOpen size={14} /> Open workspace</button>
        <button onclick={() => native.app.openLogs()}><ChevronRight size={14} /> Open logs</button>
      </div>
      <div class="empty-path"><span>workspace/src/App.svelte</span><b>save → live panel</b></div>
    </section>
  {:else}
    <section class="hero-card" class:online={machineRunning}>
    <div class="hero-glow"></div>
    <div class="card-heading">
      <div class="icon-well"><Laptop size={19} strokeWidth={1.7} /></div>
      <div class="heading-copy">
        <span>Remote access</span>
        <strong>{machineRunning ? "Connected" : "Offline"}</strong>
      </div>
      <span class="status-pill"><i></i>{machineRunning ? machineMode : "stopped"}</span>
    </div>

    <div class="machine-line">
      <span>{machineLabel}</span>
      <span>{endpointLabel}</span>
    </div>

    <div class="button-row">
      {#if machineRunning}
        <button class="primary" disabled={machineBusy} onclick={() => machineAction("restart", machineMode === "pi" ? "pi" : "core")}>
          <RefreshCw size={14} /> Restart
        </button>
        <button disabled={machineBusy} onclick={() => machineAction("stop")}><Power size={14} /> Stop</button>
      {:else}
        <button class="primary" disabled={machineBusy} onclick={() => machineAction("start", "core")}><Power size={14} /> Start</button>
        <button disabled={machineBusy} onclick={() => machineAction("start", "pi")}><Sparkles size={14} /> Start Pi</button>
      {/if}
      <button class="square" aria-label="Open logs" onclick={() => native.app.openLogs()}><ChevronRight size={15} /></button>
    </div>
  </section>

  <section class="portal-card" class:healthy={portalHealthy}>
    <div class="icon-well small"><KeyRound size={16} strokeWidth={1.8} /></div>
    <div class="portal-copy">
      <span>{authLabel}</span>
      <strong>{portalHealthy ? "Connected" : portalStatus.state === "checking" ? "Checking…" : "Reconnect needed"}</strong>
      <small>{portalDetail}</small>
    </div>
    <span class="portal-state"><i></i>{portalStatus.mcpState ?? "checking"}</span>
    {#if portalMissing}
      <button class="recover-action" disabled={portalBusy} onclick={recoverPortal}>
        <Wrench size={14} strokeWidth={1.8} /> {portalRecovering ? "Reconnecting…" : "Reconnect"}
      </button>
    {/if}
    <button class:spinning={portalRefreshing} disabled={portalBusy} aria-label="Refresh configured auth" onclick={() => refreshPortal(true)}>
      <RefreshCw size={14} strokeWidth={1.8} />
    </button>
  </section>

  <section class="remote-card" class:online={remoteConnected} class:degraded={!!remoteError}>
    <div class="remote-summary">
      <div class="icon-well small"><Activity size={16} /></div>
      <div class="remote-copy">
        <span>{remoteLabel}</span>
        <strong>{remoteError ? remoteError : remoteConnected ? "Connected" : "Unavailable"}</strong>
        <small>{remoteError ? "Run: cloudflared access login" : `${remoteToolCount} capabilities · ${remoteSessions.length} recent sessions · ${unreadAttention.length} unread`}</small>
      </div>
      <button class:spinning={remoteRefreshing} disabled={remoteRefreshing} aria-label="Refresh remote activity" onclick={refreshRemote}><RefreshCw size={14} /></button>
      <button aria-label="Open remote coordinator" onclick={() => native.remoteCoordinator.open()}><ChevronRight size={14} /></button>
    </div>

    {#if unreadAttention.length > 0}
      <div class="attention-list">
        {#each unreadAttention.slice(0, 2) as item (item.id)}
          <div class="attention-row">
            <i></i>
            <span><strong>{item.title ?? "Attention requested"}</strong><small>{item.body ?? "A remote task needs review."}</small></span>
            <button disabled={busy === "attention"} onclick={() => acknowledge(item.id)}>Acknowledge</button>
          </div>
        {/each}
      </div>
    {/if}

    {#if remoteSessions.length > 0}
      <div class="session-list">
        {#each remoteSessions.slice(0, 3) as session (session.id)}
          <div class="session-row">
            <span><strong>{session.name || "Untitled session"}</strong><small>{session.status ?? "unknown"} · {formatSessionTime(session.updated_at)}</small></span>
            <button onclick={() => steeringSession = steeringSession === session.id ? null : session.id}>Steer</button>
          </div>
          {#if steeringSession === session.id}
            <form class="steer-form" onsubmit={(event) => { event.preventDefault(); void sendSteering(session.id); }}>
              <input bind:value={steeringMessage} aria-label="Steering message" placeholder="Add guidance…" maxlength="1000" />
              <button disabled={!steeringMessage.trim() || busy === "steer"}>Send</button>
            </form>
          {/if}
        {/each}
      </div>
    {/if}
  </section>

  <section class="review-card terrarium-card" class:blocked={terrariumAttention.length > 0 || (terrariumDoctor.checks?.orphanedRuns ?? 0) > 0}>
    <div class="review-summary">
      <div class="icon-well small"><Sparkles size={16} /></div>
      <div class="review-copy">
        <span>{terrariumLabel}</span>
        <strong>{terrariumError ? "Unavailable" : `${terrariumActive} active run${terrariumActive === 1 ? "" : "s"}`}</strong>
        <small>{terrariumError ?? `${terrariumAttention.length} need attention · ${terrariumDoctor.checks?.groups ?? 0} groups · ${terrariumDoctor.checks?.pendingCallbacks ?? 0} pending callbacks`}</small>
      </div>
      <button class:spinning={terrariumRefreshing} disabled={terrariumRefreshing} aria-label="Refresh Terrarium" onclick={refreshTerrarium}><RefreshCw size={14} /></button>
    </div>
    <div class="review-list terrarium-list">
      {#each terrariumRuns.slice(0, 5) as run (run.runId)}
        <div class="review-row terrarium-row" class:attention={run.needsAttention}>
          <div class="loop-main"><span><strong>{run.task || "Unnamed task"}</strong><small>{run.status ?? "unknown"} · {run.progressText ?? "waiting"} · {run.runId.slice(-8)}</small></span></div>
          {#if run.needsAttention}<span class="pill warn">attention</span>{/if}
          {#if run.status === "running"}<button title="Cancel run" disabled={busy?.startsWith("terrarium-cancel-")} onclick={() => cancelTerrarium(run.runId)}><Square size={13} /></button>{/if}
        </div>
      {:else}
        <p class="review-empty">No active Terrarium runs. Launch one from Pi or the CLI.</p>
      {/each}
    </div>
  </section>

  <section class="review-card loops-card" class:blocked={loops.some((loop) => loop.latest?.exitCode != null && loop.latest.exitCode !== 0)}>
    <div class="review-summary">
      <div class="icon-well small"><RefreshCw size={16} /></div>
      <div class="review-copy">
        <span>{loopsLabel}</span>
        <strong>{loopsError ? "Unavailable" : `${loops.length} loop${loops.length === 1 ? "" : "s"}`}</strong>
        <small>{loopsError ?? `${watcherRunning ? `active · pid ${loopsState.watcher?.record?.pid ?? "?"}` : "schedules paused"} · ${loopsState.configPath ?? "loops.yaml"}`}</small>
      </div>
      <button class="watcher-action" disabled={busy?.startsWith("watcher-")} onclick={() => watcherAction(watcherRunning ? "stop" : "start")}>
        {#if watcherRunning}<Square size={12} /> Pause{:else}<Play size={12} /> Resume{/if}
      </button>
      {#if watcherRunning}<button aria-label="Restart watcher" disabled={busy?.startsWith("watcher-")} onclick={() => watcherAction("restart")}><RefreshCw size={14} /></button>{/if}
      <button class:spinning={loopsRefreshing} disabled={loopsRefreshing} aria-label="Refresh loops" onclick={refreshLoops}><RefreshCw size={14} /></button>
      <button aria-label="Add loop" onclick={() => editLoop()}><Plus size={14} /></button>
    </div>

    <div class="review-list loops-list">
      {#each loops as loop (loop.name)}
        <div class="review-row loop-row">
          <div class="loop-main">
            <span><strong>{loop.name}</strong><small>{loop.schedule || "on demand"} · {loop.latest ? loop.latest.exitCode == null ? "running" : `exit ${loop.latest.exitCode}` : "never run"}</small></span>
          </div>
          <button title="Edit loop" disabled={busy === "loop-save"} onclick={() => editLoop(loop)}><Pencil size={13} /></button>
          <button title="Run now" disabled={busy === `loop-run-${loop.name}`} onclick={() => runLoopNow(loop.name)}><Play size={13} /></button>
          <button title="View logs" disabled={busy === `loop-logs-${loop.name}`} onclick={() => showLoopLogs(loop.name)}><ChevronRight size={13} /></button>
          {#if deletePending === loop.name}
            <button class="danger-action" title="Confirm delete" disabled={busy === "loop-delete"} onclick={() => requestDelete(loop.name)}><Trash2 size={13} /></button>
            <button title="Cancel delete" disabled={busy === "loop-delete"} onclick={() => deletePending = null}><X size={13} /></button>
          {:else}
            <button class="danger-action" title="Delete" disabled={busy === "loop-delete"} onclick={() => requestDelete(loop.name)}><Trash2 size={13} /></button>
          {/if}
        </div>
      {:else}
        <p class="review-empty">No loops yet. Add one to edit the real loops.yaml file.</p>
      {/each}
    </div>

    {#if editingLoop}
      <form class="loop-editor" onsubmit={(event) => { event.preventDefault(); void saveLoop(); }}>
        <div class="editor-heading"><strong>{loops.some((loop) => loop.name === editingLoop?.name) ? "Edit loop" : "New loop"}</strong><button type="button" aria-label="Close editor" onclick={() => editingLoop = null}><X size={14} /></button></div>
        <label>Name<input bind:value={editingLoop.name} required pattern="[a-zA-Z0-9][a-zA-Z0-9._-]*" disabled={loops.some((loop) => loop.name === editingLoop?.name)} /></label>
        <label>Command<textarea bind:value={editingLoop.run} required rows="3"></textarea></label>
        <div class="editor-grid"><label>Schedule<input bind:value={editingLoop.schedule} placeholder="*/30 * * * *" /></label><label>Working directory<input bind:value={editingLoop.cwd} placeholder="relative or absolute" /></label></div>
        <button class="primary" disabled={busy === "loop-save" || !editingLoop.name.trim() || !editingLoop.run.trim()}><Save size={13} /> Save to loops.yaml</button>
      </form>
    {/if}

    {#if loopLogs}
      <div class="loop-logs"><div class="editor-heading"><strong>{loopLogs.name} logs</strong><button aria-label="Close logs" onclick={() => loopLogs = null}><X size={14} /></button></div><pre>{loopLogs.text}</pre></div>
    {/if}
  </section>

  <section class="grid">
    <article class="mini-card">
      <div class="mini-title"><Moon size={16} /><span>Reachability</span><i class:active={reachable} class:warning={reachabilityOrphaned}></i></div>
      <strong>{reachable ? "Awake" : reachabilityOrphaned ? "Needs attention" : "Normal"}</strong>
      <small>{reachabilityOrphaned ? "lid sleep remains disabled" : reachabilityEnd}</small>
      <div class="segmented">
        {#if reachable}
          <button disabled={reachabilityBusy} onclick={() => run("sleep", native.reachability.stop)}>Turn off</button>
        {:else}
          <button disabled={reachabilityBusy} onclick={() => run("awake-1", () => native.reachability.start(3600))}>1 hour</button>
          <button disabled={reachabilityBusy} onclick={() => run("awake-8", () => native.reachability.start(28_800))}>8 hours</button>
        {/if}
      </div>
    </article>

    <article class="mini-card">
      <div class="mini-title"><Activity size={16} /><span>System</span><i class="active"></i></div>
      <strong>{maintenanceRefreshing && maintenanceOutput === "checking" ? "Checking…" : `${diskFree} free`}</strong>
      <small>cleanup {lastCleanup}</small>
      <button class="text-action" disabled={cleanupBusy} onclick={() => run("cleanup", async () => {
        await native.maintenance.cleanup();
        await refreshMaintenance();
      })}>
        <Wrench size={13} /> Run cleanup
      </button>
    </article>
  </section>

    <button class="workspace-row" onclick={() => native.app.openWorkspace()}>
      <span class="icon-well small"><FolderOpen size={16} /></span>
      <span><strong>Edit this surface</strong><small>Save Svelte. See it live.</small></span>
      <ChevronRight size={15} />
    </button>
  {/if}

  <footer>
    <span><Clock3 size={12} /> {customConfigured === false ? "empty workspace" : updatedAt ? `updated ${updatedAt.toLocaleTimeString([], { hour: "numeric", minute: "2-digit" })}` : "checking status"}</span>
    <span>local</span>
  </footer>
</main>
