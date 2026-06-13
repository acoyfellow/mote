<script lang="ts">
  import Layout from "./Layout.svelte";
  let { path = "/" } = $props();
</script>

<Layout {path}>
  <section class="hero plate-frame">
    <div class="hero-copy">
      <p class="eyebrow">Observation plate 01 · local control shell</p>
      <h1>A programmable Mac surface, observed under local conditions.</h1>
      <p class="lede">Mote is a local-first AppKit shell that runs editable Svelte surfaces over bounded native capabilities. The interface is source, the source stays on disk, and the cloud is only a condition you opt into.</p>
      <div class="actions">
        <a class="primary" href="/docs">Read field notes →</a>
        <a href="https://github.com/acoyfellow/mote">Inspect source</a>
      </div>
      <div class="claim hero-claim">
        <span class="status">Measured claim</span>
        <h3>You can change the surface without rebuilding the native app.</h3>
        <p>Run Mote, edit <code>workspace/src/App.svelte</code>, and save. Vite updates the web surface while the Swift host keeps running.</p>
        <div class="metrics">
          <span>Conditions <b>macOS · local workspace</b></span>
          <span>Confidence <b>Working prototype</b></span>
          <span>Sample size <b>AX surface + docs site</b></span>
          <span>Reproduce <b>scripts/run.sh</b></span>
        </div>
      </div>
    </div>

    <figure class="app-specimen" aria-label="Mote app panel mockup in the PARALLAX visual system">
      <div class="app-grid" aria-hidden="true"></div>
      <div class="mock-topbar"><span class="mock-mark"></span><b>mote</b><i>AX SURFACE</i><button aria-hidden="true">↻</button></div>
      <div class="mock-card mock-main">
        <p>OBSERVATION PLATE · LOCAL BRIDGE</p>
        <div class="mock-row"><span class="mock-icon">▱</span><span><small>REMOTE ACCESS</small><strong>Connected</strong></span><em><i></i>CORE</em></div>
        <div class="mock-meta"><span>LOCAL MACHINE</span><span>PRIVATE ENDPOINT</span></div>
        <div class="mock-actions"><b>↻ Restart</b><span>Stop</span><u>›</u></div>
      </div>
      <div class="mock-card mock-remote">
        <div class="mock-row"><span class="mock-icon">⌁</span><span><small>REMOTE ACTIVITY</small><strong>Connected</strong><small>8 capabilities · 1 recent session · 1 unread</small></span></div>
        <div class="mock-alert"><i></i><span><b>Review requested</b><small>A remote task needs your attention.</small></span><button>Acknowledge</button></div>
      </div>
      <figcaption class="plate-caption">Product specimen: current Mote surface style, rendered as HTML in the hero.</figcaption>
    </figure>
  </section>

  <section class="demo-reel plate-frame">
    <div class="reel-copy">
      <p class="eyebrow">Recorded surface · local browser capture</p>
      <h2>The app surface uses the same system.</h2>
      <p>This is the actual Mote Svelte workspace running at panel size: local status, custom auth, remote activity, reachability, cleanup, and source handoff.</p>
      <p class="plate-caption">Video 01: recorded from the local workspace preview. Muted, looped, no external player.</p>
    </div>
    <video autoplay muted loop playsinline preload="metadata" poster="/mote-app-demo-poster.jpg" aria-label="Short recording of the Mote app surface">
      <source src="/mote-app-demo.mp4" type="video/mp4" />
    </video>
  </section>

  <section class="specimen-row">
    <article class="sample-card">
      <span class="specimen">Sample well · A</span>
      <h2>The native host is the instrument.</h2>
      <p>AppKit owns the status item, panel, WebKit view, permissions, logs, and bounded system capabilities. It stays small and stable.</p>
      <div class="instrument-crop" aria-hidden="true"><i></i><i></i><i></i><i></i></div>
      <p class="plate-caption">Detail crop: calibration ticks over host boundary.</p>
    </article>
    <article class="sample-card cyan-field">
      <span class="specimen">Sample well · B</span>
      <h2>The workspace is the artifact.</h2>
      <p>A Mote surface is an ordinary Svelte project. Save a file; the panel reloads. The artifact is inspectable source, not a transcript.</p>
      <pre>workspace/src/App.svelte
workspace/src/style.css
workspace/src/lib/native.ts</pre>
    </article>
  </section>

  <section class="method plate-frame">
    <div>
      <p class="eyebrow">Observed edit loop</p>
      <h2>Edit the source. Reload the surface. Keep the path back.</h2>
      <p>Mote keeps the product loop close to normal application development: source files, a local compiler, typed APIs, preview, and rollback.</p>
    </div>
    <div class="method-steps">
      <article><span>01</span><h3>Describe the surface</h3><p>Write Svelte by hand or ask an agent for a source patch.</p></article>
      <article><span>02</span><h3>Check the specimen</h3><p>Compile locally, preview in the same WebKit shell, and keep last-known-good.</p></article>
      <article><span>03</span><h3>Grant capabilities</h3><p>Use named bridge methods instead of ambient shell authority.</p></article>
      <article><span>04</span><h3>Check the boundary</h3><p>If editing requires a hidden service, move that dependency into an explicit integration.</p></article>
    </div>
  </section>

  <section class="cloud-measurement">
    <div class="claim">
      <span class="status">Optional condition</span>
      <h3>Cloudflare is optional infrastructure.</h3>
      <p>Mote runs locally after dependencies are installed. If a surface needs login, remote access, routing, or model calls, those pieces can be wired through Cloudflare without changing the local edit loop.</p>
      <div class="metrics">
        <span>Identity <b>Access</b></span>
        <span>Routing <b>Durable Objects</b></span>
        <span>Model calls <b>AI Gateway</b></span>
        <span>Hosting <b>Workers</b></span>
      </div>
    </div>
    <figure class="strip" aria-label="Cyan spectral strips for optional cloud capabilities">
      <div></div><div></div><div></div><div></div>
      <figcaption class="plate-caption">Plate 02: optional connected services shown as cyan spectral bands.</figcaption>
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
    min-height: 690px;
    margin: 28px auto 0;
    padding: 56px;
    display: block;
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
  .hero-copy { position: relative; z-index: 2; max-width: 720px; }
  h1 {
    max-width: 720px;
    margin: 20px 0 22px;
    color: var(--teal);
    font-size: clamp(3.4rem, 7vw, 6.3rem);
    line-height: .94;
    letter-spacing: -.06em;
  }
  .lede { max-width: 58ch; color: rgba(23,32,25,.72); font-size: 17px; }
  .actions { display: flex; align-items: center; flex-wrap: wrap; gap: 20px; margin: 28px 0; font: 700 11px var(--mono); text-transform: uppercase; letter-spacing: .1em; }
  .actions a { color: var(--teal); }
  .actions .primary { padding: 11px 14px; border: 1px solid var(--teal); background: var(--paper-well); }
  .hero-claim p { margin-bottom: 0; color: rgba(23,32,25,.68); font-size: 13px; }
  .app-specimen {
    position: absolute;
    right: 38px;
    top: 118px;
    width: min(438px, 41%);
    margin: 0;
    padding: 18px;
    border: 1px solid rgba(7,92,89,.24);
    background: rgba(251,247,234,.78);
    box-shadow: 0 20px 60px rgba(23,32,25,.08), inset 0 0 0 1px rgba(255,255,255,.45);
    transform: rotate(.4deg);
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
  .demo-reel video {
    width: min(100%, 390px);
    justify-self: center;
    display: block;
    border: 1px solid var(--line);
    background: var(--paper-well);
    box-shadow: 0 18px 50px rgba(23,32,25,.1);
  }
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
  .sample-card h2 { max-width: 10ch; margin-top: 20px; font-size: clamp(2.2rem, 4vw, 3.8rem); }
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
    .app-specimen { position: relative; inset: auto; width: 100%; margin-top: 28px; transform: none; }
    .method-steps { grid-template-columns: 1fr; }
    .method-steps article, .method-steps article:nth-child(2n), .method-steps article:nth-last-child(-n+2) { border-right: 0; border-bottom: 1px solid var(--line); }
    .method-steps article:last-child { border-bottom: 0; }
  }
  @media(max-width:560px) {
    h1 { font-size: 3rem; }
    .hero, .method { padding: 20px; }
    .app-specimen { padding: 12px; }
    .mock-alert { align-items: flex-start; }
    .mock-alert button { display: none; }
  }
</style>
