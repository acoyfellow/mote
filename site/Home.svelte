<script lang="ts">
  import Layout from "./Layout.svelte";
  let { path = "/" } = $props();
  let prompt = $state("Add a machinectl restart button");
  let generated = $state(false);

  function make() {
    generated = true;
    window.setTimeout(() => (generated = false), 2400);
  }
</script>

<Layout {path}>
  <section class="hero">
    <div class="orb one"></div><div class="orb two"></div>
    <div class="hero-copy">
      <p class="eyebrow">A programmable personal edge</p>
      <h1>Make your Mac<br><em>yours.</em></h1>
      <p class="lede">Mote is a local-first application shell for macOS. Build live Svelte interfaces over native capabilities—by hand or with an agent—without recompiling the app.</p>
      <div class="actions"><a class="primary" href="/docs">Read the architecture <span>→</span></a><a href="https://github.com/acoyfellow/mote">View source</a></div>
      <p class="install"><span></span>Early source release · macOS · MIT</p>
    </div>

    <div class="stage">
      <div class="menubar"><span>●</span><span>Wed Jun 11&nbsp;&nbsp; 1:47 PM&nbsp;&nbsp; <b>●</b></span></div>
      <div class="panel">
        <div class="panel-top"><div class="mini-brand"><span class="mote"></span><p><b>Mote</b><small>AX surface</small></p></div><button>↻</button></div>
        <div class="remote"><div class="remote-head"><span class="device">▰</span><p><small>Remote access</small><b>Connected</b></p><i><span></span> core</i></div><div class="address"><span>local-machine</span><span>private endpoint</span></div><div class="controls"><button>↻ &nbsp;Restart</button><button>◉ &nbsp;Stop</button><button>›</button></div></div>
        <div class="twins"><div><p>◒ &nbsp;Reachability <i></i></p><b>Awake</b><small>until 9:47 PM</small><button>Turn off</button></div><div><p>⌁ &nbsp;System <i></i></p><b>128G free</b><small>cleanup yesterday</small><button>⌘ &nbsp;Run cleanup</button></div></div>
        <div class="edit">▱ <p><b>Edit this surface</b><small>Save Svelte. See it live.</small></p><span>›</span></div>
      </div>
      <div class="annotation"><span></span>Native window<br><b>Live Svelte inside</b></div>
    </div>
  </section>

  <section class="premise">
    <p class="eyebrow">The premise</p>
    <h2>Swift is the shell.<br>Svelte is the material.</h2>
    <div class="premise-grid">
      <p>The native host owns the menu bar, windows, permissions, hotkeys, and carefully scoped macOS capabilities.</p>
      <p>Your interface is just a local Svelte workspace. Edit it in any tool. Save. Mote recompiles and reloads it instantly.</p>
    </div>
  </section>

  <section class="loop">
    <div class="loop-copy"><p class="eyebrow">Co-generation, not configuration</p><h2>Describe the tool.<br>Keep the source.</h2><p>Mote’s artifact is not a chat transcript. It is readable Svelte in a folder you own. Generate a change, preview it, accept it, then keep editing by hand.</p><ul><li><span>01</span> Agent proposes a source patch</li><li><span>02</span> Local compiler checks it</li><li><span>03</span> You preview and approve</li><li><span>04</span> Last-known-good stays recoverable</li></ul></div>
    <div class="workbench">
      <div class="chrome"><span></span><span></span><span></span><b>mote workbench</b></div>
      <div class="prompt"><label for="prompt">Ask Mote to change the surface</label><textarea id="prompt" bind:value={prompt}></textarea><button onclick={make}>{generated ? "Applied ✓" : "Generate change →"}</button></div>
      <div class="diff"><span>Panel.svelte</span><pre><i>+</i> &lt;button onclick=&#123;restart&#125;&gt;
<i>+</i>   Restart machinectl
<i>+</i> &lt;/button&gt;</pre></div>
    </div>
  </section>

  <section class="cloud">
    <p class="eyebrow">Local by default · Connected by Cloudflare</p><h2>The cloud earns its place.</h2><p class="cloud-lede">Mote works with Wi-Fi off. Cloudflare is the optional trust and reach layer when your personal edge needs to connect outward.</p>
    <div class="cloud-grid">
      <article><span>01</span><h3>Access</h3><p>Authenticate the people and agents allowed to reach a high-authority personal device.</p></article>
      <article><span>02</span><h3>Durable Objects</h3><p>Route one live outbound-connected Mac, approvals, presence, and reconnecting sessions.</p></article>
      <article><span>03</span><h3>AI Gateway</h3><p>Choose local or cloud models, route generation, observe cost, and define fallback policy.</p></article>
      <article><span>04</span><h3>Workers</h3><p>Host the remote control plane and Svelte interfaces—like this site, rendered with svelte-hono.</p></article>
    </div>
  </section>

  <section class="closing"><div class="closing-dot"></div><p class="eyebrow">Your Mac is the runtime</p><h2>Personal software should feel personal again.</h2><a href="/docs">Start with the source <span>→</span></a></section>
</Layout>

<style>
  .hero { max-width: 1180px; min-height: 760px; margin: 0 auto; padding: 110px 28px 90px; display: grid; grid-template-columns: 1fr 1fr; align-items: center; gap: 80px; position: relative; }
  .orb { position: absolute; border-radius: 50%; filter: blur(80px); pointer-events: none; }
  .orb.one { width: 420px; height: 420px; background: rgba(68,215,120,.08); right: 0; top: 80px; }
  .orb.two { width: 260px; height: 260px; background: rgba(89,113,246,.04); left: -160px; top: 220px; }
  h1 { font-size: clamp(4.2rem, 8vw, 7.5rem); line-height: .85; letter-spacing: -.085em; margin: 22px 0 32px; font-weight: 650; }
  h1 em { color: var(--green); font-style: normal; font-weight: 450; }
  .lede { max-width: 570px; color: #a3aaa0; font-size: 17px; line-height: 1.7; }
  .actions { display: flex; align-items: center; gap: 26px; margin-top: 30px; font-size: 12px; }
  .actions .primary { padding: 12px 17px; border: 1px solid rgba(145,247,179,.22); border-radius: 9px; background: rgba(145,247,179,.08); }
  .actions span { color: var(--green); margin-left: 12px; }
  .install { display: flex; align-items: center; gap: 8px; margin-top: 24px; color: #60675f; font: 9px "SF Mono", monospace; text-transform: uppercase; letter-spacing: .09em; }
  .install span { width: 5px; height: 5px; border-radius: 50%; background: var(--green); box-shadow: 0 0 8px var(--green); }
  .stage { min-height: 550px; border: 1px solid var(--line); border-radius: 22px; background: linear-gradient(145deg,#1b1d1c,#0d0f0e); position: relative; overflow: hidden; box-shadow: 0 45px 100px rgba(0,0,0,.4); transform: perspective(1200px) rotateY(-3deg) rotateX(1deg); }
  .menubar { height: 30px; padding: 0 12px; display: flex; justify-content: space-between; align-items: center; color: #a3a6a1; background: rgba(255,255,255,.04); border-bottom: 1px solid rgba(255,255,255,.04); font: 8px "SF Mono", monospace; }
  .menubar b { color: var(--green); }
  .panel { width: 328px; margin: 38px auto; padding: 14px; border: 1px solid rgba(255,255,255,.09); border-radius: 16px; background: rgba(17,19,18,.96); box-shadow: 0 25px 70px rgba(0,0,0,.5); }
  .panel-top, .mini-brand, .remote-head, .controls, .twins, .edit { display: flex; align-items: center; }
  .panel-top { justify-content: space-between; margin-bottom: 11px; }.mini-brand { gap: 9px; }.mini-brand p,.remote p,.edit p { margin: 0; display: grid; }.mini-brand small,.remote small,.edit small,.twins small { color: #777d75; font-size: 7px; }.mini-brand b { font-size: 10px; }.mote { width: 24px; height: 24px; display: grid; place-items: center; border: 1px solid rgba(145,247,179,.15); border-radius: 50%; }.mote::after { content:""; width: 5px; height: 5px; border-radius: 50%; background: var(--green); box-shadow: 0 0 10px var(--green); }.panel button { color: #d9ddd7; border: 1px solid rgba(255,255,255,.08); background: rgba(255,255,255,.05); border-radius: 7px; height: 25px; font-size: 7px; }.panel-top button { width: 25px; }
  .remote { padding: 13px; border: 1px solid rgba(145,247,179,.12); border-radius: 12px; background: rgba(255,255,255,.035); }.remote-head { gap: 9px; }.device { width: 29px; height: 29px; display: grid; place-items:center; border:1px solid rgba(255,255,255,.08); border-radius:9px; color:#9ba098 }.remote p b { font-size: 10px; }.remote-head i { margin-left: auto; padding: 4px 7px; border: 1px solid rgba(255,255,255,.08); border-radius: 20px; color:#939990; font: normal 6px "SF Mono",monospace; text-transform:uppercase }.remote-head i span { display:inline-block; width:4px;height:4px;border-radius:50%;background:var(--green);margin-right:4px }.address { display:flex;justify-content:space-between;margin:13px 0 9px;color:#696f68;font:6px "SF Mono",monospace }.controls{gap:5px}.controls button{padding:0 10px}.controls button:first-child{color:#102116;background:var(--green);border-color:var(--green)}.controls button:last-child{margin-left:auto;width:25px;padding:0}.twins{gap:7px;margin-top:7px}.twins>div{width:50%;height:118px;padding:10px;border:1px solid rgba(255,255,255,.07);border-radius:11px;background:rgba(255,255,255,.027);display:flex;flex-direction:column}.twins p{font-size:7px;color:#91968e;margin:0 0 14px}.twins p i{float:right;width:4px;height:4px;border-radius:50%;background:var(--green)}.twins b{font-size:10px}.twins button{margin-top:auto}.edit{margin-top:7px;padding:9px;border:1px solid rgba(255,255,255,.07);border-radius:10px;gap:8px;color:#888e86}.edit p{flex:1}.edit b{font-size:7px;color:#c5cac3}.annotation{position:absolute;right:14px;bottom:15px;color:#747a72;font:7px/1.7 "SF Mono",monospace;text-transform:uppercase;letter-spacing:.08em}.annotation span{display:inline-block;width:26px;height:1px;background:#526157;vertical-align:middle;margin-right:7px}.annotation b{color:#a6ada4;font-weight:400}
  .premise { max-width: 1124px; margin: 0 auto; padding: 120px 0; border-top: 1px solid var(--line); }.premise h2{font-size:clamp(2.8rem,6vw,5.2rem);margin-top:20px}.premise-grid{margin-top:55px;display:grid;grid-template-columns:1fr 1fr;gap:90px;color:#929990;font-size:16px}.premise-grid p:first-child{color:#d9ded6}
  .loop { max-width:1124px;margin:0 auto;padding:120px 0;display:grid;grid-template-columns:.8fr 1.2fr;gap:100px;align-items:center;border-top:1px solid var(--line)}.loop-copy>p:not(.eyebrow){color:var(--muted);max-width:44ch}.loop ul{list-style:none;padding:20px 0 0;margin:0;border-top:1px solid var(--line)}.loop li{padding:10px 0;color:#a4aaa2;font-size:12px;border-bottom:1px solid rgba(255,255,255,.045)}.loop li span{color:var(--green);font:8px "SF Mono",monospace;margin-right:14px}.workbench{border:1px solid var(--line);border-radius:18px;overflow:hidden;background:#111411;box-shadow:0 35px 90px rgba(0,0,0,.3)}.chrome{height:35px;display:flex;align-items:center;gap:5px;padding:0 12px;border-bottom:1px solid var(--line)}.chrome span{width:6px;height:6px;border-radius:50%;background:#383d38}.chrome b{margin-left:auto;color:#676d66;font:7px "SF Mono",monospace}.prompt{padding:20px;display:grid;gap:9px}.prompt label{color:#8f958d;font-size:9px}.prompt textarea{resize:none;height:72px;padding:12px;border:1px solid var(--line);border-radius:10px;color:#edf1eb;background:#090b0a;font:11px/1.5 "SF Mono",monospace}.prompt button{justify-self:end;padding:8px 12px;border:1px solid rgba(145,247,179,.2);border-radius:8px;color:#142219;background:var(--green);font-size:9px}.diff{border-top:1px solid var(--line);padding:16px 20px}.diff>span{color:#737a72;font:8px "SF Mono",monospace}.diff pre{margin-bottom:0}.diff i{color:var(--green);font-style:normal}
  .cloud{max-width:1124px;margin:0 auto;padding:120px 0;border-top:1px solid var(--line)}.cloud>h2{font-size:clamp(2.8rem,6vw,5.2rem);margin:20px 0}.cloud-lede{max-width:58ch;color:var(--muted);font-size:16px}.cloud-grid{display:grid;grid-template-columns:repeat(4,1fr);margin-top:55px;border-top:1px solid var(--line);border-bottom:1px solid var(--line)}.cloud-grid article{padding:24px 25px 30px;border-right:1px solid var(--line)}.cloud-grid article:last-child{border:0}.cloud-grid span{color:#5c645b;font:8px "SF Mono",monospace}.cloud-grid h3{margin-top:50px}.cloud-grid p{color:var(--muted);font-size:11px}
  .closing{max-width:1124px;margin:0 auto;padding:150px 0;text-align:center;position:relative}.closing-dot{width:9px;height:9px;margin:0 auto 24px;border-radius:50%;background:var(--green);box-shadow:0 0 50px 20px rgba(145,247,179,.13)}.closing h2{max-width:780px;margin:22px auto 35px;font-size:clamp(2.8rem,6vw,5rem)}.closing a{display:inline-block;padding:11px 16px;border:1px solid rgba(145,247,179,.2);border-radius:9px;font-size:11px}.closing a span{color:var(--green);margin-left:15px}
  @media(max-width:850px){.hero{grid-template-columns:1fr;padding-top:70px}.stage{transform:none}.premise,.loop,.cloud,.closing{margin-inline:22px}.loop{grid-template-columns:1fr}.cloud-grid{grid-template-columns:1fr 1fr}.cloud-grid article:nth-child(2){border-right:0}.premise-grid{gap:30px}.hero h1{font-size:5rem}}
  @media(max-width:520px){.hero{padding-inline:18px}.stage{min-height:500px}.panel{width:300px}.premise-grid,.cloud-grid{grid-template-columns:1fr}.cloud-grid article{border-right:0;border-bottom:1px solid var(--line)}.premise,.loop,.cloud{padding-block:80px}.hero h1{font-size:4.2rem}}
</style>
