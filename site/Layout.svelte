<script lang="ts">
  import type { Snippet } from "svelte";
  let { path = "/", children }: { path?: string; children: Snippet } = $props();
</script>

<div class="noise"></div>
<header>
  <a class="brand" href="/" aria-label="Mote home"><span class="mark"><i></i></span><b>mote</b></a>
  <nav>
    <a class:active={path === "/"} href="/">Manifesto</a>
    <a class:active={path === "/docs"} href="/docs">Docs</a>
    <a href="https://github.com/acoyfellow/mote">GitHub <span>↗</span></a>
  </nav>
</header>

<main>{@render children()}</main>

<footer>
  <div class="brand"><span class="mark small"><i></i></span><b>mote</b></div>
  <p>Local by default. Connected by Cloudflare.</p>
  <a href="https://coey.dev">Built by @acoyfellow</a>
</footer>

<style>
  :global(:root) {
    color-scheme: dark;
    --bg: #0b0d0c;
    --panel: #121512;
    --ink: #f2f6ef;
    --muted: #899087;
    --line: rgba(230, 255, 235, .105);
    --green: #91f7b3;
    --green-strong: #4ce184;
  }
  :global(*) { box-sizing: border-box; }
  :global(html) { scroll-behavior: smooth; background: var(--bg); }
  :global(body) { margin: 0; color: var(--ink); background: var(--bg); font: 15px/1.65 -apple-system, BlinkMacSystemFont, "SF Pro Text", system-ui, sans-serif; }
  :global(a) { color: inherit; text-decoration: none; }
  :global(code) { color: var(--green); font: .88em "SF Mono", ui-monospace, monospace; }
  :global(pre) { margin: 1.2rem 0; padding: 1.25rem; overflow: auto; border: 1px solid var(--line); border-radius: 15px; color: #d8ddd6; background: #080a09; font: 12.5px/1.65 "SF Mono", ui-monospace, monospace; }
  :global(h1), :global(h2), :global(h3), :global(p) { margin-top: 0; }
  :global(h2) { font-size: clamp(1.7rem, 4vw, 2.45rem); line-height: 1.1; letter-spacing: -.045em; margin: 0 0 1rem; }
  :global(h3) { font-size: 1rem; letter-spacing: -.02em; }
  :global(.eyebrow) { color: var(--green); text-transform: uppercase; letter-spacing: .16em; font: 600 10px "SF Mono", ui-monospace, monospace; }
  .noise { z-index: 100; position: fixed; inset: 0; opacity: .025; pointer-events: none; background-image: url("data:image/svg+xml,%3Csvg viewBox='0 0 180 180' xmlns='http://www.w3.org/2000/svg'%3E%3Cfilter id='n'%3E%3CfeTurbulence type='fractalNoise' baseFrequency='.9' numOctaves='4' stitchTiles='stitch'/%3E%3C/filter%3E%3Crect width='100%25' height='100%25' filter='url(%23n)'/%3E%3C/svg%3E"); }
  header { position: relative; z-index: 2; max-width: 1180px; margin: 0 auto; padding: 24px 28px; display: flex; align-items: center; justify-content: space-between; }
  .brand { display: flex; align-items: center; gap: 10px; }
  .brand b { letter-spacing: -.04em; font-size: 16px; }
  .mark { width: 29px; height: 29px; display: grid; place-items: center; position: relative; border: 1px solid rgba(145,247,179,.2); border-radius: 50%; }
  .mark::after { content: ""; position: absolute; inset: 5px; border: 1px solid rgba(145,247,179,.1); border-radius: 50%; }
  .mark i { width: 6px; height: 6px; background: var(--green); border-radius: 50%; box-shadow: 0 0 15px rgba(145,247,179,.8); }
  .mark.small { width: 22px; height: 22px; }
  nav { display: flex; align-items: center; gap: 28px; }
  nav a { color: var(--muted); font-size: 12px; transition: color .2s; }
  nav a:hover, nav a.active { color: var(--ink); }
  nav span { color: var(--green); }
  main { min-height: 76vh; }
  footer { max-width: 1124px; margin: 0 auto; padding: 30px 0 50px; border-top: 1px solid var(--line); display: grid; grid-template-columns: 1fr 1fr 1fr; align-items: center; color: var(--muted); font-size: 11px; }
  footer p { margin: 0; text-align: center; }
  footer > a { text-align: right; }
  @media (max-width: 700px) {
    header { padding: 20px; }
    nav { gap: 14px; }
    nav a:first-child { display: none; }
    footer { margin-inline: 20px; grid-template-columns: 1fr; gap: 12px; }
    footer p, footer > a { text-align: left; }
  }
</style>
