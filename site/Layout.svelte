<script lang="ts">
  import type { Snippet } from "svelte";
  let { path = "/", children }: { path?: string; children: Snippet } = $props();
</script>

<div class="paper-noise" aria-hidden="true"></div>
<header>
  <a class="brand" href="/" aria-label="Mote home">
    <span class="plate-mark"><i></i></span>
    <b>mote</b>
  </a>
  <nav aria-label="Primary">
    <a class:active={path === "/"} href="/">Home</a>
    <a class:active={path === "/docs"} href="/docs">Docs</a>
    <a href="https://github.com/acoyfellow/mote">Source <span>↗</span></a>
  </nav>
</header>

<main>{@render children()}</main>

<footer>
  <div class="brand"><span class="plate-mark small"><i></i></span><b>mote</b></div>
  <p>Runs locally. Connects when needed.</p>
  <a href="https://coey.dev">@acoyfellow</a>
</footer>

<style>
  :global(:root) {
    color-scheme: light;
    --paper: #f3efe2;
    --paper-well: #fbf7ea;
    --paper-deep: #e8e0cc;
    --carbon: #172019;
    --teal: #075c59;
    --cyan: #16b8b0;
    --vermilion: #ff5a36;
    --line: rgba(7, 92, 89, .22);
    --line-soft: rgba(7, 92, 89, .11);
    --shadow: rgba(23, 32, 25, .08);
    --mono: "SF Mono", "IBM Plex Mono", ui-monospace, monospace;
    --sans: Inter, -apple-system, BlinkMacSystemFont, "SF Pro Text", system-ui, sans-serif;
    --grid: 8px;
  }
  :global(*) { box-sizing: border-box; }
  :global(html) { scroll-behavior: smooth; background: var(--paper); }
  :global(body) {
    margin: 0;
    min-width: 320px;
    color: var(--carbon);
    background:
      linear-gradient(rgba(7,92,89,.035) 1px, transparent 1px) 0 0 / 32px 32px,
      linear-gradient(90deg, rgba(7,92,89,.035) 1px, transparent 1px) 0 0 / 32px 32px,
      var(--paper);
    font: 15px/1.65 var(--sans);
    -webkit-font-smoothing: antialiased;
  }
  :global(a) { color: inherit; text-decoration: none; }
  :global(code), :global(pre) { font-family: var(--mono); }
  :global(code) { color: var(--teal); font-size: .88em; }
  :global(pre) {
    margin: 1rem 0;
    padding: 18px;
    overflow: auto;
    border: 1px solid var(--line);
    background: rgba(251,247,234,.78);
    color: var(--carbon);
    font: 12px/1.7 var(--mono);
    box-shadow: inset 0 0 0 1px rgba(255,255,255,.55);
  }
  :global(h1), :global(h2), :global(h3), :global(p) { margin-top: 0; }
  :global(h1), :global(h2), :global(h3) { color: var(--teal); letter-spacing: -.035em; }
  :global(h2) { font-size: clamp(2rem, 4.6vw, 3.75rem); line-height: .98; margin: 0 0 18px; }
  :global(h3) { font-size: 1.02rem; line-height: 1.2; }
  :global(.eyebrow) {
    color: var(--teal);
    text-transform: uppercase;
    letter-spacing: .18em;
    font: 700 10px/1.4 var(--mono);
  }
  :global(.specimen) {
    color: rgba(23,32,25,.62);
    text-transform: uppercase;
    letter-spacing: .12em;
    font: 10px/1.5 var(--mono);
  }
  :global(.claim) {
    border: 1px solid var(--line);
    background: rgba(251,247,234,.82);
    padding: 18px;
    box-shadow: 0 16px 40px var(--shadow), inset 0 0 0 1px rgba(255,255,255,.5);
  }
  :global(.claim .status) {
    display: inline-flex;
    align-items: center;
    gap: 7px;
    color: var(--teal);
    text-transform: uppercase;
    letter-spacing: .14em;
    font: 700 10px/1 var(--mono);
  }
  :global(.claim .status::before) {
    content: "";
    width: 7px;
    height: 7px;
    border-radius: 50%;
    background: var(--cyan);
    box-shadow: 0 0 0 4px rgba(22,184,176,.12);
  }
  :global(.claim h3) { margin: 14px 0 12px; color: var(--carbon); }
  :global(.metrics) { display: grid; grid-template-columns: repeat(2, 1fr); gap: 8px 18px; margin: 14px 0 0; }
  :global(.metrics span) { color: rgba(23,32,25,.56); font: 10px/1.4 var(--mono); text-transform: uppercase; letter-spacing: .08em; }
  :global(.metrics b) { display: block; color: var(--teal); font-weight: 700; }
  :global(.plate-caption) {
    margin: 10px 0 0;
    color: rgba(23,32,25,.58);
    font: 10px/1.55 var(--mono);
    text-transform: uppercase;
    letter-spacing: .08em;
  }
  .paper-noise {
    z-index: 100;
    position: fixed;
    inset: 0;
    opacity: .13;
    pointer-events: none;
    mix-blend-mode: multiply;
    background-image: url("data:image/svg+xml,%3Csvg viewBox='0 0 180 180' xmlns='http://www.w3.org/2000/svg'%3E%3Cfilter id='n'%3E%3CfeTurbulence type='fractalNoise' baseFrequency='.72' numOctaves='3' stitchTiles='stitch'/%3E%3C/filter%3E%3Crect width='100%25' height='100%25' opacity='.34' filter='url(%23n)'/%3E%3C/svg%3E");
  }
  header {
    max-width: 1184px;
    margin: 0 auto;
    padding: 22px 28px;
    display: flex;
    align-items: center;
    justify-content: space-between;
  }
  .brand { display: flex; align-items: center; gap: 10px; color: var(--teal); }
  .brand b { font: 800 16px/1 var(--mono); letter-spacing: -.04em; }
  .plate-mark {
    width: 31px;
    height: 31px;
    display: grid;
    place-items: center;
    position: relative;
    border: 1px solid var(--teal);
    background: radial-gradient(circle at center, rgba(22,184,176,.16) 0 2px, transparent 3px), var(--paper-well);
  }
  .plate-mark::before, .plate-mark::after { content: ""; position: absolute; background: var(--teal); opacity: .68; }
  .plate-mark::before { width: 15px; height: 1px; }
  .plate-mark::after { width: 1px; height: 15px; }
  .plate-mark i { width: 6px; height: 6px; background: var(--cyan); border-radius: 50%; z-index: 1; }
  .plate-mark.small { width: 24px; height: 24px; }
  nav { display: flex; align-items: center; gap: 26px; }
  nav a { color: rgba(23,32,25,.62); font: 700 11px var(--mono); text-transform: uppercase; letter-spacing: .1em; }
  nav a:hover, nav a.active { color: var(--teal); }
  nav span { color: var(--teal); }
  main { min-height: 76vh; }
  footer {
    max-width: 1128px;
    margin: 0 auto;
    padding: 28px 0 48px;
    border-top: 1px solid var(--line);
    display: grid;
    grid-template-columns: 1fr 1.4fr 1fr;
    align-items: center;
    color: rgba(23,32,25,.58);
    font: 11px var(--mono);
    text-transform: uppercase;
    letter-spacing: .08em;
  }
  footer p { margin: 0; text-align: center; }
  footer > a { text-align: right; color: var(--teal); }
  @media (max-width: 720px) {
    header { padding: 18px 20px; align-items: flex-start; gap: 20px; }
    nav { gap: 14px; flex-wrap: wrap; justify-content: flex-end; }
    nav a { font-size: 10px; }
    footer { margin-inline: 20px; grid-template-columns: 1fr; gap: 12px; }
    footer p, footer > a { text-align: left; }
    :global(.metrics) { grid-template-columns: 1fr; }
  }
</style>
