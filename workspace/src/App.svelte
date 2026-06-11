<script lang="ts">
  import { onMount } from "svelte";
  import { Activity, ChevronRight, Clock3, FolderOpen, KeyRound, Laptop, Moon, Power, RefreshCw, Sparkles, Wrench } from "@lucide/svelte";
  import { native, type MachineAction, type MachineMode } from "./lib/native";

  let machineOutput = $state("checking");
  let reachabilityOutput = $state("checking");
  type PortalStatus = { state: string; accessTokenState?: string; expiresAt?: string | null };

  let maintenanceOutput = $state("checking");
  let machineLabel = $state("Local machine");
  let endpointLabel = $state("Private endpoint");
  let authLabel = $state("Configured auth");
  let portalStatus = $state<PortalStatus>({ state: "checking" });
  let busy = $state<string | null>(null);
  let error = $state<string | null>(null);
  let updatedAt = $state<Date | null>(null);
  let refreshing = $state(false);
  let maintenanceRefreshing = $state(false);
  let portalRefreshing = $state(false);

  const machineBusy = $derived(busy?.startsWith("machine-") ?? false);
  const reachabilityBusy = $derived(busy === "sleep" || busy?.startsWith("awake-") === true);
  const cleanupBusy = $derived(busy === "cleanup");
  const portalHealthy = $derived(portalStatus.state === "refreshable" || portalStatus.state === "valid");
  const portalDetail = $derived.by(() => {
    if (portalStatus.state === "checking") return "checking local grant";
    if (!portalHealthy) return "sign-in needed";
    if (!portalStatus.expiresAt) return "refresh grant stored";
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

  function readPortalStatus(result: Record<string, unknown>): PortalStatus {
    const resourceId = String(result.resourceId ?? "");
    authLabel = String(result.label ?? "Configured auth");
    const report = JSON.parse(String(result.output ?? "{}")) as { resources?: Array<PortalStatus & { id?: string }>; id?: string; state?: string; accessTokenState?: string; expiresAt?: string | null };
    const portal = report.resources?.find((resource) => resource.id === resourceId) ?? (report.id === resourceId ? report : null);
    if (!portal?.state) throw new Error("Configured auth status was not present in local output");
    return { state: portal.state, accessTokenState: portal.accessTokenState, expiresAt: portal.expiresAt };
  }

  async function refreshPortal(force = false) {
    if (portalRefreshing) return;
    portalRefreshing = true;
    try {
      const result = force ? await native.authResource.refresh() : await native.authResource.status();
      portalStatus = readPortalStatus(result);
      error = null;
    } catch (reason) {
      portalStatus = { state: "error" };
      error = reason instanceof Error ? reason.message : String(reason);
    } finally {
      portalRefreshing = false;
    }
  }

  async function loadConfiguration() {
    const config = await native.app.configuration();
    machineLabel = String(config.machineLabel ?? "Local machine");
    endpointLabel = String(config.endpointLabel ?? "Private endpoint");
  }

  async function refreshAll() {
    await Promise.all([refreshCore(), refreshPortal()]);
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

  onMount(() => {
    void loadConfiguration();
    void refreshAll();
    const statusTimer = window.setInterval(refreshCore, 30_000);
    const maintenanceTimer = window.setInterval(refreshMaintenance, 5 * 60_000);
    const portalTimer = window.setInterval(refreshPortal, 5 * 60_000);
    return () => {
      window.clearInterval(statusTimer);
      window.clearInterval(maintenanceTimer);
      window.clearInterval(portalTimer);
    };
  });
</script>

<svelte:head><title>Mote · AX</title></svelte:head>

<main>
  <header class="topbar">
    <div class="identity">
      <span class="mote-mark"><span></span></span>
      <div>
        <strong>Mote</strong>
        <small>AX surface</small>
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
      <strong>{portalHealthy ? "Ready" : portalStatus.state === "checking" ? "Checking…" : "Needs sign-in"}</strong>
      <small>{portalDetail}</small>
    </div>
    <span class="portal-state"><i></i>{portalStatus.state}</span>
    <button class:spinning={portalRefreshing} disabled={portalRefreshing} aria-label="Refresh configured auth" onclick={() => refreshPortal(true)}>
      <RefreshCw size={14} strokeWidth={1.8} />
    </button>
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

  <footer>
    <span><Clock3 size={12} /> {updatedAt ? `updated ${updatedAt.toLocaleTimeString([], { hour: "numeric", minute: "2-digit" })}` : "checking status"}</span>
    <span>local</span>
  </footer>
</main>
