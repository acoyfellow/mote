import { Hono } from "hono";
import { attachSvelteRoutes, svelteRenderer } from "svelte-hono";
import { bundles } from "./bundles.generated.js";
import Home from "./Home.svelte";
import Docs from "./Docs.svelte";

const app = new Hono();
attachSvelteRoutes(app, { bundles });

const description = "Mote is a local-first Svelte shell for native macOS capabilities.";
const head = (path: string, title: string) => `
<meta name="description" content="${description}">
<meta property="og:title" content="${title}">
<meta property="og:description" content="${description}">
<meta property="og:type" content="website">
<meta property="og:url" content="https://mote.coey.dev${path}">
<meta property="og:image" content="https://mote.coey.dev/og.svg">
<meta name="twitter:card" content="summary_large_image">
<link rel="icon" href="data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 32 32'%3E%3Ccircle cx='16' cy='16' r='14' fill='%230b0d0c' stroke='%2391f7b3' stroke-opacity='.3'/%3E%3Ccircle cx='16' cy='16' r='4' fill='%2391f7b3'/%3E%3C/svg%3E">
`;

app.get("/", svelteRenderer(Home, {
  hydrateAs: "home",
  title: "Mote — A programmable personal edge",
  head: head("/", "Mote — Make your Mac yours"),
  props: { path: "/" },
}));

app.get("/docs", svelteRenderer(Docs, {
  hydrateAs: "docs",
  title: "Documentation — Mote",
  head: head("/docs", "Mote documentation"),
  props: { path: "/docs" },
}));

app.get("/health", (c) => c.json({ ok: true, service: "mote", runtime: "svelte-hono" }));
app.get("/robots.txt", (c) => c.text("User-agent: *\nAllow: /\nSitemap: https://mote.coey.dev/sitemap.xml\n"));
app.get("/sitemap.xml", () => new Response(`<?xml version="1.0" encoding="UTF-8"?><urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9"><url><loc>https://mote.coey.dev/</loc></url><url><loc>https://mote.coey.dev/docs</loc></url></urlset>`, { headers: { "content-type": "application/xml" } }));

app.get("/og.svg", (c) => c.body(`<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1200 630"><defs><radialGradient id="g"><stop stop-color="#24442e"/><stop offset="1" stop-color="#0b0d0c"/></radialGradient></defs><rect width="1200" height="630" fill="url(#g)"/><circle cx="100" cy="95" r="28" fill="none" stroke="#91f7b3" stroke-opacity=".3"/><circle cx="100" cy="95" r="8" fill="#91f7b3"/><text x="150" y="110" font-family="system-ui" font-size="46" font-weight="650" fill="#f2f6ef">mote</text><text x="80" y="330" font-family="system-ui" font-size="92" font-weight="650" letter-spacing="-5" fill="#f2f6ef">Make your Mac yours.</text><text x="85" y="410" font-family="monospace" font-size="27" fill="#91f7b3">A programmable personal edge.</text><text x="85" y="540" font-family="system-ui" font-size="23" fill="#899087">Native macOS capabilities. Live Svelte interfaces.</text></svg>`, 200, { "content-type": "image/svg+xml", "cache-control": "public, max-age=86400" }));

export default app;
