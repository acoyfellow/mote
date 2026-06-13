<script lang="ts">
  import Layout from "./Layout.svelte";
  let { path = "/docs" } = $props();
</script>

<Layout {path}>
  <div class="docs-shell">
    <aside>
      <p>Mote field notes</p>
      <a href="#brand">Brand system</a>
      <a href="#start">Run prototype</a>
      <a href="#workspace">Workspace</a>
      <a href="#bridge">Native bridge</a>
      <a href="#custom">Custom layer</a>
      <a href="#roadmap">Roadmap</a>
    </aside>

    <article>
      <p class="eyebrow">Field notebook · Mote 0.1</p>
      <h1>A local Svelte shell for native macOS capabilities.</h1>
      <p class="intro">These notes describe the current working specimen: an AppKit status item and panel, a WKWebView, a local Vite/Svelte runtime, and a typed bridge to bounded native capabilities.</p>

      <section id="brand" class="plate-section">
        <div class="section-head">
          <span class="specimen">Observation system</span>
          <h2>PARALLAX, adjusted for Mote.</h2>
          <p>Mote borrows the language of scientific observation, then makes it personal: the Mac is the runtime, the Svelte workspace is the artifact, and every claim includes a reproduction handle.</p>
        </div>
        <div class="brand-grid">
          <div class="palette">
            <div><i class="swatch teal"></i><span>Cold teal ink</span><b>#075C59</b><small>Structure, rails, labels, hard edges.</small></div>
            <div><i class="swatch cyan"></i><span>Cyan samples</span><b>#16B8B0</b><small>Measurements, wells, confidence bands.</small></div>
            <div><i class="swatch vermilion"></i><span>Vermilion anomaly</span><b>#FF5A36</b><small>One visible failure mark per view.</small></div>
            <div><i class="swatch carbon"></i><span>Carbon text</span><b>#172019</b><small>Body copy, code, durable facts.</small></div>
          </div>
          <div class="claim">
            <span class="status">Measured voice</span>
            <h3>State what was tested, what happened, and how to run it again.</h3>
            <p>Use compact engineering-note pacing: condition, sample, confidence, reproduction handle, and known limits. Avoid theatrical typography, decorative gradients, and accent colors outside the palette.</p>
            <div class="metrics">
              <span>Spacing <b>8px base grid</b></span>
              <span>Typography <b>System sans + mono labels</b></span>
              <span>Pacing <b>Claim → evidence → steps</b></span>
              <span>Surface <b>Plate, rail, sample, caption</b></span>
            </div>
          </div>
        </div>
        <figure class="detail-plate" aria-label="Instrument detail plate made from HTML and CSS">
          <div class="rail"></div>
          <div class="wells"></div>
          <div class="bands"><i></i><i></i><i></i><i></i></div>
          <figcaption class="plate-caption">Plate 03: texture field and instrument detail crop. Provenance: HTML/CSS plate; all words are accessible HTML.</figcaption>
        </figure>
      </section>

      <section id="start">
        <h2>Run the prototype</h2>
        <p>Requirements: macOS 14+, Xcode command-line tools, and Bun. Clone the source, install the editable surface, then run the native host.</p>
        <pre>git clone https://github.com/acoyfellow/mote
cd mote/workspace
bun install

cd ..
./scripts/run.sh</pre>
        <p>Click the mote in the menu bar. Right-click it for recovery controls. Edit <code>workspace/src/App.svelte</code> while Mote is running; Vite HMR updates the panel without rebuilding Swift.</p>
      </section>

      <section id="workspace">
        <h2>The workspace is the artifact</h2>
        <p>A Mote surface is an ordinary local Svelte project. There is no proprietary document format and no cloud round-trip in the edit loop.</p>
        <pre>workspace/
├── package.json
├── vite.config.ts
└── src/
    ├── App.svelte       # interface
    ├── style.css        # visual language
    └── lib/native.ts    # typed host bindings</pre>
        <div class="claim inline">
          <span class="status">Offline condition</span>
          <h3>After dependencies exist locally, the edit loop keeps working without a network connection.</h3>
          <div class="metrics"><span>Reproduce <b>Turn Wi‑Fi off, save Svelte</b></span><span>Known limit <b>New installs still need dependencies</b></span></div>
        </div>
      </section>

      <section id="bridge">
        <h2>The native bridge</h2>
        <p>The Swift host injects one small Promise-based function into the webview. The Svelte SDK wraps command strings with typed methods.</p>
        <pre>import &#123; native &#125; from "./lib/native";

const status = await native.machinectl.status();

await native.machinectl.action("restart", "core");
await native.reachability.start(8 * 60 * 60);</pre>
        <table><thead><tr><th>Namespace</th><th>Commands</th></tr></thead><tbody><tr><td><code>app</code></td><td>info, configuration, open workspace, open logs</td></tr><tr><td><code>machinectl</code></td><td>status, start, stop, restart</td></tr><tr><td><code>reachability</code></td><td>status, start, stop</td></tr><tr><td><code>maintenance</code></td><td>report, cleanup</td></tr><tr><td><code>authResource</code></td><td>status, refresh</td></tr><tr><td><code>remoteCoordinator</code></td><td>overview, acknowledge, steer, open</td></tr></tbody></table>
      </section>

      <section id="custom">
        <h2>Custom configuration stays outside source.</h2>
        <p>Machine-specific resource names, endpoints, CLI paths, and private capability wiring live in a local runtime layer outside the repository and app bundle.</p>
        <pre>~/.mote/config/custom.json
~/.mote/scripts/</pre>
        <p>Public source uses only generic capability names. The custom layer can point to any local implementation without changing the Svelte API or publishing private details.</p>
      </section>

      <section id="architecture">
        <h2>Architecture</h2>
        <div class="diagram">
          <div><span>Native host</span><b>AppKit · WKWebView</b><small>Windows, permissions, bounded system access</small></div>
          <i>typed messages</i>
          <div><span>Local surface</span><b>Svelte 5 · Vite HMR</b><small>Interface, state, workflows</small></div>
          <i>optional services</i>
          <div><span>Cloudflare</span><b>Access · Durable Objects · AI Gateway</b><small>Login, routing, model calls</small></div>
        </div>
      </section>

      <section id="roadmap">
        <h2>Roadmap</h2>
        <ol>
          <li><b>Now:</b> local menu-bar shell with live Svelte surface and bounded native bridge.</li>
          <li><b>Next:</b> signed app bundle, bundled compiler sidecar, workspace manifests.</li>
          <li><b>Then:</b> workbench for agent-proposed patches, isolated preview, accept/reject, rollback.</li>
          <li><b>Connected:</b> optional login, device routing, model-call routing, and encrypted bundle history.</li>
        </ol>
      </section>

      <div class="end"><p class="specimen">END OF CURRENT SPECIMEN</p><a href="https://github.com/acoyfellow/mote">Read the source →</a></div>
    </article>
  </div>
</Layout>

<style>
  .docs-shell { max-width: 1128px; margin: 0 auto; padding: 64px 0 132px; display: grid; grid-template-columns: 190px 1fr; gap: 78px; }
  aside { position: sticky; top: 24px; align-self: start; display: grid; padding: 16px 0 16px 18px; border-left: 1px solid var(--teal); background: rgba(243,239,226,.72); }
  aside p { margin: 0 0 12px; color: var(--teal); font: 700 10px var(--mono); text-transform: uppercase; letter-spacing: .12em; }
  aside a { color: rgba(23,32,25,.62); font: 11px/1.7 var(--mono); padding: 3px 0; }
  aside a:hover { color: var(--teal); }
  article { max-width: 820px; }
  h1 { margin: 18px 0 20px; max-width: 760px; color: var(--teal); font-size: clamp(2.85rem, 6.2vw, 5.1rem); line-height: .98; letter-spacing: -.055em; }
  .intro { color: rgba(23,32,25,.7); font-size: 18px; max-width: 65ch; }
  section { margin-top: 64px; padding-top: 44px; border-top: 1px solid var(--line); }
  section > p { color: rgba(23,32,25,.68); max-width: 68ch; }
  .plate-section { border: 1px solid var(--line); padding: 28px; background: rgba(251,247,234,.66); }
  .section-head p { color: rgba(23,32,25,.68); }
  .brand-grid { display: grid; grid-template-columns: .9fr 1.1fr; gap: 22px; margin-top: 26px; }
  .palette { border: 1px solid var(--line); background: var(--paper-well); }
  .palette div { display: grid; grid-template-columns: 28px 1fr auto; gap: 10px; align-items: center; padding: 14px; border-bottom: 1px solid var(--line-soft); }
  .palette div:last-child { border-bottom: 0; }
  .palette span { color: var(--carbon); font-weight: 750; }
  .palette b { color: rgba(23,32,25,.62); font: 10px var(--mono); }
  .palette small { grid-column: 2 / -1; color: rgba(23,32,25,.58); font-size: 12px; }
  .swatch { width: 22px; height: 22px; display: block; border: 1px solid rgba(23,32,25,.18); }
  .teal { background: var(--teal); }
  .cyan { background: var(--cyan); }
  .vermilion { background: var(--vermilion); }
  .carbon { background: var(--carbon); }
  .detail-plate { position: relative; margin: 24px 0 0; padding: 18px; min-height: 240px; border: 1px solid var(--line); background: linear-gradient(rgba(7,92,89,.06) 1px, transparent 1px) 0 0 / 20px 20px, linear-gradient(90deg, rgba(7,92,89,.06) 1px, transparent 1px) 0 0 / 20px 20px, var(--paper-well); display: grid; grid-template-columns: 72px 1fr 1.2fr; gap: 18px; }
  .rail { border-left: 1px solid var(--teal); background: repeating-linear-gradient(0deg, var(--teal) 0 1px, transparent 1px 11px); opacity: .72; }
  .wells { border: 1px solid var(--line); background: radial-gradient(circle, transparent 0 7px, rgba(22,184,176,.45) 7px 8px, transparent 9px) 0 0 / 34px 34px; }
  .bands { display: grid; grid-template-columns: repeat(4,1fr); gap: 8px; }
  .bands i { border: 1px solid var(--line-soft); background: repeating-linear-gradient(0deg, rgba(22,184,176,.18) 0 14px, rgba(22,184,176,.055) 14px 28px); }
  .detail-plate figcaption { grid-column: 1 / -1; }
  .inline { margin-top: 18px; }
  table { width: 100%; border-collapse: collapse; margin: 24px 0; background: rgba(251,247,234,.55); }
  th, td { text-align: left; padding: 12px; border: 1px solid var(--line-soft); font-size: 12px; }
  th { color: var(--teal); font: 700 10px var(--mono); text-transform: uppercase; letter-spacing: .12em; }
  .diagram { display: grid; gap: 10px; margin-top: 22px; }
  .diagram div { padding: 16px; border: 1px solid var(--line); background: rgba(251,247,234,.7); display: grid; }
  .diagram span { color: var(--teal); font: 700 10px var(--mono); text-transform: uppercase; letter-spacing: .12em; }
  .diagram b { margin-top: 4px; color: var(--carbon); }
  .diagram small { color: rgba(23,32,25,.58); }
  .diagram i { color: rgba(7,92,89,.7); font: 10px var(--mono); text-transform: uppercase; letter-spacing: .12em; font-style: normal; text-align: center; }
  ol { padding-left: 20px; }
  li { padding: 8px 0; color: rgba(23,32,25,.68); }
  .end { margin-top: 80px; padding: 24px; border: 1px solid var(--line); text-align: center; background: rgba(251,247,234,.62); }
  .end p { margin-bottom: 12px; }
  .end a { color: var(--teal); font: 700 11px var(--mono); text-transform: uppercase; letter-spacing: .1em; }
  @media(max-width:840px) { .docs-shell { display:block; margin:0 20px; padding-top:42px; } aside { display:none; } .brand-grid, .detail-plate { grid-template-columns:1fr; } h1 { font-size:3.1rem; } }
</style>
