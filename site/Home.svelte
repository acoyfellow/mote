<script lang="ts">
  import Layout from "./Layout.svelte";
  let { path = "/" } = $props();
</script>

<Layout {path}>
  <section class="hero plate-frame">
    <div class="hero-copy">
      <p class="eyebrow">Local-first Mac app shell</p>
      <h1>Build a Mac control panel in Svelte.</h1>
      <p class="lede">Mote is a menu-bar app for local tools. The native host handles windows, permissions, and macOS APIs. Your panel is ordinary Svelte you can edit live.</p>
      <div class="actions">
        <a class="primary" href="/docs">Read the docs →</a>
        <a href="https://github.com/acoyfellow/mote">View source</a>
      </div>
      <div class="claim hero-claim">
        <span class="status">Working prototype</span>
        <h3>Edit Svelte. The app updates without rebuilding Swift.</h3>
        <p>Run Mote, change <code>workspace/src/App.svelte</code>, and save. Vite updates the panel while the AppKit host keeps running.</p>
        <div class="metrics">
          <span>Host <b>AppKit · WKWebView</b></span>
          <span>Surface <b>Svelte 5 · Vite</b></span>
          <span>Config <b>Local custom layer</b></span>
          <span>Start <b>scripts/run.sh</b></span>
        </div>
      </div>
    </div>

    <figure class="app-specimen" aria-label="Mote app panel mockup in the current visual system">
      <div class="app-grid" aria-hidden="true"></div>
      <div class="mock-topbar"><span class="mock-mark"></span><b>mote</b><i>CUSTOM PANEL</i><button aria-hidden="true">↻</button></div>
      <div class="mock-card mock-main">
        <p>LOCAL BRIDGE</p>
        <div class="mock-row"><span class="mock-icon">▱</span><span><small>LOCAL SERVICE</small><strong>Running</strong></span><em><i></i>CORE</em></div>
        <div class="mock-meta"><span>LOCALHOST</span><span>OPTIONAL ROUTE</span></div>
        <div class="mock-actions"><b>↻ Restart</b><span>Stop</span><u>›</u></div>
      </div>
      <div class="mock-card mock-remote">
        <div class="mock-row"><span class="mock-icon">⌁</span><span><small>REMOTE ACTIVITY</small><strong>Connected</strong><small>8 capabilities · 1 recent session · 1 unread</small></span></div>
        <div class="mock-alert"><i></i><span><b>Review requested</b><small>A remote task needs your attention.</small></span><button>Acknowledge</button></div>
      </div>
      <figcaption class="plate-caption">Generic panel mock rendered as HTML on the homepage.</figcaption>
    </figure>
  </section>

  <section class="demo-reel plate-frame">
    <div class="reel-copy">
      <p class="eyebrow">Example panel</p>
      <h2>Common Mac workflows, one panel.</h2>
      <p>Use one Svelte panel for service control, auth recovery, remote tasks, command shortcuts, logs, files, and cleanup. This example uses placeholder data.</p>
      <p class="plate-caption">Blueprint: placeholder data only; no private endpoints or local resource names.</p>
    </div>
    <figure class="panel-blueprint" aria-label="Generic Mote panel blueprint with common local tool controls">
      <div class="blueprint-top"><span class="mock-mark"></span><b>mote</b><i>CUSTOM PANEL</i></div>
      <div class="blueprint-grid">
        <article class="wide ok"><small>LOCAL SERVICE</small><strong>Running</strong><span>restart · stop · logs</span></article>
        <article class="warn"><small>AUTH</small><strong>Recoverable</strong><span>refresh · recover</span></article>
        <article><small>REMOTE TASK</small><strong>1 waiting</strong><span>ack · steer</span></article>
        <article><small>COMMANDS</small><strong>6 shortcuts</strong><span>typed bridge calls</span></article>
        <article><small>FILES</small><strong>Workspace</strong><span>open · edit · save</span></article>
        <article><small>SYSTEM</small><strong>128G free</strong><span>report · cleanup</span></article>
      </div>
      <figcaption class="plate-caption">Generic surface: placeholder labels, no private endpoints or local resource names.</figcaption>
    </figure>
  </section>

  <section class="specimen-row">
    <article class="sample-card">
      <span class="specimen">Native host</span>
      <h2>Swift owns the shell.</h2>
      <p>The app owns the status item, panel, WebKit view, permissions, logs, and bounded system access. It should stay small and stable.</p>
      <div class="instrument-crop" aria-hidden="true"><i></i><i></i><i></i><i></i></div>
      <p class="plate-caption">Boundary detail: native capability calls stay behind named bridge methods.</p>
    </article>
    <article class="sample-card cyan-field">
      <span class="specimen">Editable workspace</span>
      <h2>Svelte owns the surface.</h2>
      <p>A Mote panel is an ordinary local Svelte project. Save a file; the panel reloads. The product behavior lives in source you can inspect.</p>
      <pre>workspace/src/App.svelte
workspace/src/style.css
workspace/src/lib/native.ts</pre>
    </article>
  </section>

  <section class="method plate-frame">
    <div>
      <p class="eyebrow">Edit loop</p>
      <h2>Change the panel like any other frontend.</h2>
      <p>Keep layout, state, and product workflows in Svelte. Keep privileged system access behind explicit native capabilities.</p>
    </div>
    <div class="method-steps">
      <article><span>01</span><h3>Edit Svelte</h3><p>Change the panel by hand, or ask an agent to propose a source patch.</p></article>
      <article><span>02</span><h3>Compile locally</h3><p>Preview in the same WebKit shell and keep a last-known-good build.</p></article>
      <article><span>03</span><h3>Call named APIs</h3><p>Use typed bridge methods instead of giving the webview shell access.</p></article>
      <article><span>04</span><h3>Roll back</h3><p>If a change breaks the panel, return to the last working workspace state.</p></article>
    </div>
  </section>

  <section class="cloud-measurement">
    <div class="claim">
      <span class="status">Connected services</span>
      <h3>Add Cloudflare when a panel needs the network.</h3>
      <p>Mote runs locally after dependencies are installed. If a panel needs login, remote access, routing, or model calls, those pieces can be wired in without changing the local edit loop.</p>
      <div class="metrics">
        <span>Login <b>Access</b></span>
        <span>Routing <b>Durable Objects</b></span>
        <span>Model calls <b>AI Gateway</b></span>
        <span>Hosting <b>Workers</b></span>
      </div>
    </div>
    <figure class="strip" aria-label="Cyan bands representing optional connected services">
      <div></div><div></div><div></div><div></div>
      <figcaption class="plate-caption">Optional connected services. The local app does not depend on them to run.</figcaption>
    </figure>
  </section>
</Layout>

<style>
  .plate-frame {
    position: relative;
    border: 1px solid var(--line);
    background: rgba(251,247,234,.74);
    box-shadow: 0 20px 60px var(--shadow), inset 0 0 0 1px rgba(255,255,255,.48);
  }
  .hero {
    max-width: 1184px;
    margin: 28px auto 0;
    padding: 46px;
    display: grid;
    grid-template-columns: minmax(0, 1fr) minmax(360px, 438px);
    gap: 44px;
    align-items: center;
    overflow: hidden;
  }
  .hero::before, .hero::after, .method::before, .method::after {
    content: "";
    position: absolute;
    width: 24px;
    height: 24px;
    border-color: var(--teal);
    opacity: .45;
  }
  .hero::before, .method::before { left: 14px; top: 14px; border-left: 1px solid; border-top: 1px solid; }
  .hero::after, .method::after { right: 14px; bottom: 14px; border-right: 1px solid; border-bottom: 1px solid; }
  .hero-copy { position: relative; z-index: 2; max-width: 620px; }
  h1 {
    max-width: 620px;
    margin: 18px 0 20px;
    color: var(--teal);
    font-size: clamp(3rem, 5vw, 4.85rem);
    line-height: .97;
    letter-spacing: -.055em;
  }
  .lede { max-width: 50ch; color: rgba(23,32,25,.72); font-size: 16px; }
  .actions { display: flex; align-items: center; flex-wrap: wrap; gap: 20px; margin: 28px 0; font: 700 11px var(--mono); text-transform: uppercase; letter-spacing: .1em; }
  .actions a { color: var(--teal); }
  .actions .primary { padding: 11px 14px; border: 1px solid var(--teal); background: var(--paper-well); }
  .hero-claim p { margin-bottom: 0; color: rgba(23,32,25,.68); font-size: 13px; }
  .app-specimen {
    position: relative;
    width: 100%;
    margin: 0;
    padding: 18px;
    border: 1px solid rgba(7,92,89,.24);
    background: rgba(251,247,234,.78);
    box-shadow: 0 20px 60px rgba(23,32,25,.08), inset 0 0 0 1px rgba(255,255,255,.45);
  }
  .app-grid { position: absolute; inset: 0; opacity: .5; background: linear-gradient(rgba(7,92,89,.055) 1px, transparent 1px) 0 0 / 22px 22px, linear-gradient(90deg, rgba(7,92,89,.055) 1px, transparent 1px) 0 0 / 22px 22px; pointer-events: none; }
  .mock-topbar, .mock-card, .app-specimen figcaption { position: relative; z-index: 1; }
  .mock-topbar { display: flex; align-items: center; gap: 8px; color: var(--teal); font: 800 11px var(--mono); margin-bottom: 12px; }
  .mock-topbar i { margin-right: auto; color: rgba(23,32,25,.58); font-style: normal; font: 700 8px var(--mono); letter-spacing: .12em; }
  .mock-topbar button { width: 28px; height: 28px; border: 1px solid var(--line); background: var(--paper-well); color: var(--teal); }
  .mock-mark { width: 25px; height: 25px; display: grid; place-items: center; border: 1px solid var(--teal); background: var(--paper-well); }
  .mock-mark::after { content: ""; width: 5px; height: 5px; border-radius: 50%; background: var(--cyan); box-shadow: 0 0 0 6px rgba(22,184,176,.12); }
  .mock-card { border: 1px solid var(--line); background: rgba(251,247,234,.78); padding: 13px; margin-top: 9px; }
  .mock-main p { margin: 0 0 13px; color: var(--teal); font: 700 8px var(--mono); letter-spacing: .13em; }
  .mock-row { display: flex; align-items: center; gap: 11px; }
  .mock-icon { width: 35px; height: 35px; border: 1px solid var(--line); display: grid; place-items: center; color: var(--teal); background: var(--paper-well); }
  .mock-row span:nth-child(2) { display: grid; line-height: 1.12; }
  .mock-row small { color: rgba(23,32,25,.58); font: 700 8px var(--mono); letter-spacing: .11em; }
  .mock-row strong { margin-top: 3px; color: var(--carbon); font-size: 18px; letter-spacing: -.03em; }
  .mock-row em { margin-left: auto; display: flex; align-items: center; gap: 6px; padding: 6px 8px; border: 1px solid var(--line); color: var(--teal); font: 700 8px var(--mono); font-style: normal; letter-spacing: .08em; }
  .mock-row em i, .mock-alert > i { width: 7px; height: 7px; border-radius: 50%; background: var(--cyan); box-shadow: 0 0 0 5px rgba(22,184,176,.12); }
  .mock-meta { display: flex; justify-content: space-between; margin: 12px 0 10px; color: rgba(23,32,25,.56); font: 8px var(--mono); letter-spacing: .08em; }
  .mock-actions { display: flex; gap: 8px; align-items: center; }
  .mock-actions b, .mock-actions span, .mock-actions u, .mock-alert button { border: 1px solid var(--line); padding: 8px 10px; color: var(--teal); background: var(--paper-well); font: 800 9px var(--mono); text-decoration: none; }
  .mock-actions b { background: rgba(22,184,176,.16); }
  .mock-actions u { margin-left: auto; width: 32px; text-align: center; }
  .mock-alert { margin-top: 12px; padding-top: 12px; border-top: 1px solid var(--line-soft); display: flex; align-items: center; gap: 8px; }
  .mock-alert i { background: var(--vermilion); box-shadow: 0 0 0 5px rgba(255,90,54,.12); flex: none; }
  .mock-alert span { min-width: 0; flex: 1; display: grid; }
  .mock-alert b { color: var(--carbon); font-size: 10px; }
  .mock-alert small { color: rgba(23,32,25,.58); font-size: 8px; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
  .mock-alert button { flex: none; }
  .demo-reel {
    max-width: 1128px;
    margin: 64px auto 0;
    padding: 28px;
    display: grid;
    grid-template-columns: .88fr 1.12fr;
    gap: 30px;
    align-items: center;
  }
  .reel-copy p:not(.eyebrow):not(.plate-caption) { color: rgba(23,32,25,.68); max-width: 48ch; }
  .panel-blueprint {
    margin: 0;
    padding: 18px;
    border: 1px solid var(--line);
    background:
      linear-gradient(rgba(7,92,89,.05) 1px, transparent 1px) 0 0 / 22px 22px,
      linear-gradient(90deg, rgba(7,92,89,.05) 1px, transparent 1px) 0 0 / 22px 22px,
      rgba(251,247,234,.82);
    box-shadow: 0 18px 50px rgba(23,32,25,.1), inset 0 0 0 1px rgba(255,255,255,.5);
  }
  .blueprint-top { display: flex; align-items: center; gap: 8px; margin-bottom: 14px; color: var(--teal); font: 800 11px var(--mono); }
  .blueprint-top i { color: rgba(23,32,25,.58); font: 700 8px var(--mono); font-style: normal; letter-spacing: .12em; }
  .blueprint-grid { display: grid; grid-template-columns: repeat(3, 1fr); gap: 9px; }
  .blueprint-grid article {
    min-height: 108px;
    padding: 13px;
    border: 1px solid var(--line);
    background: rgba(251,247,234,.78);
    display: grid;
    align-content: start;
    gap: 7px;
  }
  .blueprint-grid article.wide { grid-column: span 2; }
  .blueprint-grid small { color: rgba(23,32,25,.58); font: 700 8px var(--mono); letter-spacing: .11em; }
  .blueprint-grid strong { color: var(--carbon); font-size: 18px; letter-spacing: -.03em; }
  .blueprint-grid span { color: var(--teal); font: 700 9px var(--mono); }
  .blueprint-grid .ok { background: rgba(22,184,176,.12); }
  .blueprint-grid .warn { position: relative; }
  .blueprint-grid .warn::after { content: ""; position: absolute; top: 13px; right: 13px; width: 8px; height: 8px; border-radius: 50%; background: var(--vermilion); box-shadow: 0 0 0 5px rgba(255,90,54,.12); }
  .specimen-row {
    max-width: 1128px;
    margin: 64px auto 0;
    display: grid;
    grid-template-columns: 1fr 1fr;
    gap: 24px;
  }
  .sample-card {
    min-height: 360px;
    padding: 28px;
    border: 1px solid var(--line);
    background: rgba(251,247,234,.68);
  }
  .sample-card h2 { max-width: 12ch; margin-top: 20px; font-size: clamp(2.2rem, 4vw, 3.8rem); }
  .sample-card p { color: rgba(23,32,25,.68); max-width: 52ch; }
  .cyan-field {
    background:
      repeating-linear-gradient(0deg, rgba(22,184,176,.13) 0 22px, rgba(22,184,176,.055) 22px 44px),
      var(--paper-well);
  }
  .instrument-crop {
    margin-top: 34px;
    height: 92px;
    border: 1px solid var(--line);
    background: linear-gradient(90deg, transparent 0 30%, rgba(22,184,176,.18) 30% 62%, transparent 62%), var(--paper-well);
    display: grid;
    grid-template-columns: repeat(4, 1fr);
  }
  .instrument-crop i { border-right: 1px solid var(--line-soft); position: relative; }
  .instrument-crop i::after { content: ""; position: absolute; right: -1px; top: 0; bottom: 0; width: 1px; background: repeating-linear-gradient(0deg, var(--teal) 0 4px, transparent 4px 10px); opacity: .55; }
  .method {
    max-width: 1128px;
    margin: 64px auto 0;
    padding: 38px;
    display: grid;
    grid-template-columns: .75fr 1.25fr;
    gap: 42px;
  }
  .method > div:first-child p:not(.eyebrow) { color: rgba(23,32,25,.68); }
  .method-steps { display: grid; grid-template-columns: repeat(2, 1fr); border: 1px solid var(--line); }
  .method-steps article { padding: 22px; min-height: 160px; border-right: 1px solid var(--line); border-bottom: 1px solid var(--line); background: rgba(251,247,234,.55); }
  .method-steps article:nth-child(2n) { border-right: 0; }
  .method-steps article:nth-last-child(-n+2) { border-bottom: 0; }
  .method-steps span { color: var(--cyan); font: 700 10px var(--mono); }
  .method-steps p { color: rgba(23,32,25,.62); font-size: 13px; }
  .cloud-measurement {
    max-width: 1128px;
    margin: 64px auto 120px;
    display: grid;
    grid-template-columns: .95fr 1.05fr;
    gap: 24px;
    align-items: stretch;
  }
  .strip {
    margin: 0;
    padding: 22px;
    border: 1px solid var(--line);
    background: var(--paper-well);
    display: grid;
    grid-template-columns: repeat(4, 1fr);
    gap: 10px;
  }
  .strip div {
    min-height: 220px;
    border: 1px solid var(--line-soft);
    background: repeating-linear-gradient(0deg, rgba(22,184,176,.2) 0 14px, rgba(22,184,176,.06) 14px 28px);
  }
  .strip figcaption { grid-column: 1 / -1; }
  @media(max-width:900px) {
    .hero, .method, .cloud-measurement, .demo-reel { grid-template-columns: 1fr; margin-inline: 20px; padding: 24px; }
    .specimen-row { grid-template-columns: 1fr; margin-inline: 20px; }
    .app-specimen { width: 100%; margin-top: 8px; }
    .method-steps { grid-template-columns: 1fr; }
    .method-steps article, .method-steps article:nth-child(2n), .method-steps article:nth-last-child(-n+2) { border-right: 0; border-bottom: 1px solid var(--line); }
    .method-steps article:last-child { border-bottom: 0; }
  }
  @media(max-width:560px) {
    h1 { font-size: 3.2rem; }
    .hero, .method { padding: 20px; }
    .app-specimen { padding: 12px; }
    .mock-alert { align-items: flex-start; }
    .mock-alert button { display: none; }
  }
</style>
