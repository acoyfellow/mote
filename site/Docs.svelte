<script lang="ts">
  import Layout from "./Layout.svelte";
  let { path = "/docs" } = $props();
</script>

<Layout {path}>
  <div class="docs-shell">
    <aside>
      <p>Mote docs</p>
      <a href="#start">Run prototype</a>
      <a href="#workspace">Workspace</a>
      <a href="#bridge">Native bridge</a>
      <a href="#custom">Custom layer</a>
      <a href="#roadmap">Roadmap</a>
    </aside>

    <article>
      <section class="docs-hero plate-section">
        <p class="eyebrow">Mote 0.1</p>
        <h1>Run it locally. Change it live.</h1>
        <p class="intro">Mote is a working prototype: an AppKit status item and panel, a WKWebView, a local Vite/Svelte workspace, and a typed bridge to bounded native capabilities.</p>
        <div class="metrics hero-metrics">
          <span>Host <b>AppKit · WKWebView</b></span>
          <span>Surface <b>Svelte 5 · Vite</b></span>
          <span>Bridge <b>Typed native calls</b></span>
          <span>Config <b>Local custom layer</b></span>
        </div>
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
        <h2>The workspace is the product surface.</h2>
        <p>A Mote panel is an ordinary local Svelte project. There is no proprietary document format and no cloud round-trip in the edit loop.</p>
        <pre>workspace/
├── package.json
├── vite.config.ts
└── src/
    ├── App.svelte       # interface
    ├── style.css        # visual language
    └── lib/native.ts    # typed host bindings</pre>
        <div class="claim inline">
          <span class="status">Local edit loop</span>
          <h3>After dependencies exist locally, editing the panel does not require the network.</h3>
          <div class="metrics"><span>Try it <b>Turn Wi‑Fi off, save Svelte</b></span><span>Known limit <b>New installs still fetch dependencies</b></span></div>
        </div>
      </section>

      <section id="bridge">
        <h2>The native bridge</h2>
        <p>The Swift host injects one small Promise-based function into the webview. The Svelte SDK wraps command strings with typed methods.</p>
        <pre>import &#123; native &#125; from "./lib/native";

const status = await native.machinectl.status();

await native.machinectl.action("restart", "core");
await native.reachability.start(8 * 60 * 60);</pre>
        <table><thead><tr><th>Namespace</th><th>Commands</th></tr></thead><tbody><tr><td><code>app</code></td><td>info, configuration, open workspace, open logs</td></tr><tr><td><code>machinectl</code></td><td>status, start, stop, restart</td></tr><tr><td><code>reachability</code></td><td>status, start, stop</td></tr><tr><td><code>maintenance</code></td><td>report, cleanup</td></tr><tr><td><code>authResource</code></td><td>status, refresh, recover</td></tr><tr><td><code>remoteCoordinator</code></td><td>overview, acknowledge, steer, open</td></tr></tbody></table>
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

      <div class="end"><p class="specimen">End of current docs</p><a href="https://github.com/acoyfellow/mote">Read the source →</a></div>
    </article>
  </div>
</Layout>

<style>
  .docs-shell { max-width: 1128px; margin: 0 auto; padding: 64px 0 132px; display: grid; grid-template-columns: 190px 1fr; gap: 78px; }
  aside { position: sticky; top: 24px; align-self: start; display: grid; padding: 16px 0 16px 18px; border-left: 1px solid var(--teal); background: rgba(243,239,226,.72); }
  aside p { margin: 0 0 12px; color: var(--teal); font: 700 10px var(--mono); text-transform: uppercase; letter-spacing: .12em; }
  aside a { color: rgba(23,32,25,.62); font: 11px/1.7 var(--mono); padding: 3px 0; }
  aside a:hover { color: var(--teal); }
  article { max-width: 860px; }
  h1 {
    margin: 18px 0 20px;
    max-width: 760px;
    color: var(--teal);
    font-size: clamp(3.6rem, 7vw, 6.2rem);
    line-height: .94;
    letter-spacing: -.065em;
  }
  .intro { color: rgba(23,32,25,.7); font-size: 18px; max-width: 65ch; }
  section {
    position: relative;
    margin-top: 34px;
    padding: 30px;
    border: 1px solid var(--line);
    background: rgba(251,247,234,.66);
    box-shadow: 0 18px 50px rgba(23,32,25,.06), inset 0 0 0 1px rgba(255,255,255,.45);
  }
  section::before, section::after {
    content: "";
    position: absolute;
    width: 18px;
    height: 18px;
    border-color: var(--teal);
    opacity: .42;
  }
  section::before { left: 14px; top: 14px; border-left: 1px solid; border-top: 1px solid; }
  section::after { right: 14px; bottom: 14px; border-right: 1px solid; border-bottom: 1px solid; }
  section h2 {
    margin: 0 0 18px;
    max-width: 700px;
    color: var(--teal);
    font-size: clamp(2.7rem, 5.4vw, 4.5rem);
    line-height: .96;
    letter-spacing: -.058em;
  }
  section > p { color: rgba(23,32,25,.68); max-width: 68ch; }
  .docs-hero { margin-top: 0; }
  .hero-metrics { margin-top: 24px; }
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
  @media(max-width:840px) {
    .docs-shell { display:block; margin:0 20px; padding-top:42px; }
    aside { display:none; }
    section { padding: 22px; }
    h1 { font-size:3.5rem; }
    section h2 { font-size: 3rem; }
  }
</style>
