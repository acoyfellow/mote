<script lang="ts">
  import Layout from "./Layout.svelte";
  let { path = "/docs" } = $props();
</script>

<Layout {path}>
  <div class="docs-shell">
    <aside>
      <p>Mote 0.1</p>
      <a href="#start">Run the prototype</a>
      <a href="#workspace">Workspace</a>
      <a href="#bridge">Native bridge</a>
      <a href="#capabilities">Capabilities</a>
      <a href="#architecture">Architecture</a>
      <a href="#roadmap">Roadmap</a>
    </aside>
    <article>
      <p class="eyebrow">Documentation</p>
      <h1>A live Svelte shell<br>for native macOS.</h1>
      <p class="intro">Mote is an early, working prototype: an AppKit status item and panel, a WKWebView, a local Vite/Svelte runtime, and a typed message bridge to bounded native capabilities.</p>

      <section id="start"><h2>Run the prototype</h2><p>Requirements: macOS 14+, Xcode command-line tools, and Bun. Clone the source, install the editable surface, then run the native host.</p><pre>git clone https://github.com/acoyfellow/mote
cd mote/workspace
bun install

cd ../app
MOTE_WORKSPACE="$PWD/../workspace" swift run Mote</pre><p>Click the mote in the menu bar. Right-click it for the recovery menu. Edit <code>workspace/src/App.svelte</code> while Mote is running; Vite HMR updates the panel without rebuilding Swift.</p></section>

      <section id="workspace"><h2>The workspace is the artifact</h2><p>A Mote surface is an ordinary local Svelte project. There is no proprietary document format and no cloud round-trip in the edit loop.</p><pre>workspace/
├── package.json
├── vite.config.ts
└── src/
    ├── App.svelte       # the interface
    ├── style.css        # the visual language
    └── lib/native.ts    # typed host bindings</pre><div class="callout"><b>Offline means offline.</b><p>After dependencies exist locally, compiling, rendering, invoking capabilities, and editing the surface require no network connection.</p></div></section>

      <section id="bridge"><h2>The native bridge</h2><p>The Swift host injects one small Promise-based function into the webview. The Svelte SDK wraps command strings with typed methods.</p><pre>import &#123; native &#125; from "./lib/native";

const status = await native.machinectl.status();

await native.machinectl.action("restart", "core");
await native.reachability.start(8 * 60 * 60);</pre><p>Messages cross <code>WKScriptMessageHandler</code>. Results return to the originating Promise. The webview does not receive a generic shell command.</p></section>

      <section id="capabilities"><h2>Capabilities, not ambient authority</h2><p>The prototype exposes only the operations needed by the AX surface:</p><table><thead><tr><th>Namespace</th><th>Commands</th></tr></thead><tbody><tr><td><code>machinectl</code></td><td>status, start, stop, restart</td></tr><tr><td><code>reachability</code></td><td>status, start, stop</td></tr><tr><td><code>maintenance</code></td><td>report, cleanup</td></tr><tr><td><code>app</code></td><td>info, open workspace, open logs</td></tr></tbody></table><p>The next capability layer will add workspace manifests, explicit grants, an audit trail, and prompts when generated source asks for more authority.</p></section>

      <section id="architecture"><h2>Architecture</h2><div class="diagram"><div><span>Native host</span><b>AppKit · WKWebView</b><small>Windows, permissions, system access</small></div><i>↕ typed messages</i><div><span>Local surface</span><b>Svelte 5 · Vite HMR</b><small>Interface, state, workflows</small></div><i>↕ optional</i><div><span>Cloudflare</span><b>Access · DO · AI Gateway</b><small>Identity, reach, generation</small></div></div><p>The native host is deliberately stable and boring. It should only need recompilation when a genuinely new macOS primitive or entitlement is introduced. Product behavior and visual design remain in Svelte.</p></section>

      <section id="roadmap"><h2>Roadmap</h2><ol><li><b>Now:</b> AX replaces the Hammerspoon menu with a live Svelte panel.</li><li><b>Next:</b> self-contained signed app bundle, bundled compiler sidecar, workspace manifests.</li><li><b>Then:</b> Workbench for agent-proposed patches, isolated preview, accept/reject, rollback.</li><li><b>Connected:</b> optional Access-protected device routing, AI Gateway generation, encrypted bundle history.</li></ol></section>

      <div class="end"><span></span><p>Mote is early. The interface is already live.</p><a href="https://github.com/acoyfellow/mote">Read the source →</a></div>
    </article>
  </div>
</Layout>

<style>
  .docs-shell{max-width:1124px;margin:0 auto;padding:80px 0 140px;display:grid;grid-template-columns:190px 1fr;gap:100px}aside{position:sticky;top:30px;align-self:start;display:grid;border-left:1px solid var(--line);padding-left:18px}aside p{color:var(--green);font:8px "SF Mono",monospace;text-transform:uppercase;letter-spacing:.12em;margin-bottom:14px}aside a{color:var(--muted);font-size:10px;padding:5px 0}aside a:hover{color:var(--ink)}article{max-width:740px}h1{font-size:clamp(3rem,7vw,5.5rem);line-height:.95;letter-spacing:-.07em;margin:20px 0 30px}.intro{color:#a6ada4;font-size:18px;max-width:60ch}section{padding:70px 0 20px;border-top:1px solid var(--line);margin-top:70px}section h2{font-size:2.4rem}section>p{color:#9ba198;max-width:68ch}.callout{padding:20px;border:1px solid rgba(145,247,179,.14);border-radius:13px;background:rgba(145,247,179,.035);margin-top:20px}.callout b{font-size:12px}.callout p{margin:4px 0 0;color:var(--muted);font-size:11px}table{width:100%;border-collapse:collapse;margin:25px 0}th,td{text-align:left;padding:12px;border-bottom:1px solid var(--line);font-size:11px}th{color:#626a61;font:8px "SF Mono",monospace;text-transform:uppercase;letter-spacing:.1em}.diagram{display:grid;gap:10px;margin:30px 0}.diagram div{padding:16px 18px;border:1px solid var(--line);border-radius:12px;background:#101310;display:grid}.diagram span{color:var(--green);font:8px "SF Mono",monospace;text-transform:uppercase}.diagram b{margin-top:5px;font-size:13px}.diagram small{color:var(--muted);font-size:9px}.diagram i{text-align:center;color:#4f574f;font:8px "SF Mono",monospace;font-style:normal}ol{padding-left:20px}li{padding:9px;color:#969d94;font-size:12px}.end{margin-top:100px;padding:35px;border:1px solid var(--line);border-radius:16px;text-align:center}.end span{display:block;width:7px;height:7px;margin:0 auto 15px;border-radius:50%;background:var(--green);box-shadow:0 0 18px var(--green)}.end p{color:var(--muted)}.end a{font-size:11px;color:var(--green)}@media(max-width:800px){.docs-shell{display:block;margin:0 22px;padding-top:50px}aside{display:none}}
</style>
