import { Hono } from "hono";
import { attachSvelteRoutes, svelteRenderer } from "svelte-hono";
import { bundles } from "./bundles.generated.js";
import { APPLE_TOUCH_ICON_PNG, ICON_192_PNG, ICON_512_PNG, OG_IMAGE_PNG } from "./generated-media.js";
import Home from "./Home.svelte";
import Docs from "./Docs.svelte";

const app = new Hono();
attachSvelteRoutes(app, { bundles });

const origin = "https://mote.coey.dev";
const siteName = "Mote";
const description = "Mote is a local-first Mac app shell for editable Svelte control panels, bounded native capabilities, and optional connected services.";
const assetVersion = "20260614";
const iconSvg = `<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 32 32"><rect width="32" height="32" fill="#f3efe2"/><path d="M6.5 6.5h19v19h-19z" fill="none" stroke="#075c59"/><path d="M10 16h12M16 10v12" stroke="#075c59" stroke-width="1.2"/><circle cx="16" cy="16" r="2.5" fill="#16b8b0"/><circle cx="21" cy="21" r="1.8" fill="#ff5a36"/></svg>`;

function structuredData(path: string, title: string, pageDescription: string) {
  const graph: Record<string, unknown>[] = [
    {
      "@type": "WebSite",
      name: siteName,
      url: origin,
      description,
    },
    {
      "@type": "SoftwareApplication",
      name: siteName,
      url: `${origin}${path}`,
      applicationCategory: "DeveloperApplication",
      operatingSystem: "macOS",
      license: "https://github.com/acoyfellow/mote/blob/main/LICENSE",
      description: pageDescription,
      author: { "@type": "Person", name: "Jordan Coeyman", url: "https://coey.dev" },
      codeRepository: "https://github.com/acoyfellow/mote",
      offers: { "@type": "Offer", price: "0", priceCurrency: "USD" },
    },
  ];
  return JSON.stringify({ "@context": "https://schema.org", "@graph": graph });
}

const head = (path: string, title: string, pageDescription = description) => `
<meta name="viewport" content="width=device-width, initial-scale=1, viewport-fit=cover">
<meta name="description" content="${pageDescription}">
<meta name="robots" content="index, follow, max-image-preview:large">
<meta name="author" content="Jordan Coeyman">
<meta name="application-name" content="Mote">
<meta name="apple-mobile-web-app-title" content="Mote">
<meta name="apple-mobile-web-app-capable" content="yes">
<meta name="mobile-web-app-capable" content="yes">
<meta name="apple-mobile-web-app-status-bar-style" content="default">
<meta name="format-detection" content="telephone=no">
<meta name="color-scheme" content="light">
<meta name="theme-color" content="#F3EFE2">
<link rel="canonical" href="${origin}${path}">
<link rel="manifest" href="/manifest.webmanifest">
<link rel="icon" href="/favicon.svg" type="image/svg+xml">
<link rel="icon" href="/icon-192.png" sizes="192x192" type="image/png">
<link rel="apple-touch-icon" href="/apple-touch-icon.png" sizes="180x180">
<link rel="mask-icon" href="/favicon.svg" color="#075C59">
<meta property="og:site_name" content="Mote">
<meta property="og:locale" content="en_US">
<meta property="og:title" content="${title}">
<meta property="og:description" content="${pageDescription}">
<meta property="og:type" content="website">
<meta property="og:url" content="${origin}${path}">
<meta property="og:image" content="${origin}/og.png?v=${assetVersion}">
<meta property="og:image:secure_url" content="${origin}/og.png?v=${assetVersion}">
<meta property="og:image:type" content="image/png">
<meta property="og:image:width" content="1200">
<meta property="og:image:height" content="630">
<meta property="og:image:alt" content="Mote homepage preview: a local Mac control panel built with Svelte.">
<meta name="twitter:card" content="summary_large_image">
<meta name="twitter:title" content="${title}">
<meta name="twitter:description" content="${pageDescription}">
<meta name="twitter:image" content="${origin}/og.png?v=${assetVersion}">
<meta name="twitter:image:alt" content="Mote homepage preview: a local Mac control panel built with Svelte.">
<script type="application/ld+json">${structuredData(path, title, pageDescription)}</script>
`;

app.get("/", svelteRenderer(Home, {
  hydrateAs: "home",
  title: "Mote — Mac control panels in Svelte",
  head: head("/", "Mote — Mac control panels in Svelte"),
  props: { path: "/" },
}));

app.get("/docs", svelteRenderer(Docs, {
  hydrateAs: "docs",
  title: "Docs — Mote",
  head: head("/docs", "Mote docs", "Docs for Mote: architecture, local workspace, custom configuration, native bridge, and the visual system."),
  props: { path: "/docs" },
}));

function bytesFromBase64(base64: string) {
  const binary = atob(base64);
  const bytes = new Uint8Array(binary.length);
  for (let i = 0; i < binary.length; i++) bytes[i] = binary.charCodeAt(i);
  return bytes;
}

function media(base64: string, type: string, maxAge = 31_536_000) {
  const bytes = bytesFromBase64(base64);
  return new Response(bytes, { headers: { "content-type": type, "content-length": String(bytes.byteLength), "cache-control": `public, max-age=${maxAge}, immutable` } });
}

function png(base64: string, maxAge = 31_536_000) {
  return media(base64, "image/png", maxAge);
}

app.get("/health", (c) => c.json({ ok: true, service: "mote", runtime: "svelte-hono" }));
app.get("/favicon.svg", (c) => c.body(iconSvg, 200, { "content-type": "image/svg+xml", "cache-control": "public, max-age=31536000, immutable" }));
app.get("/icon.svg", (c) => c.body(iconSvg, 200, { "content-type": "image/svg+xml", "cache-control": "public, max-age=31536000, immutable" }));
app.get("/icon-192.png", () => png(ICON_192_PNG));
app.get("/icon-512.png", () => png(ICON_512_PNG));
app.get("/apple-touch-icon.png", () => png(APPLE_TOUCH_ICON_PNG));
app.get("/og.png", () => png(OG_IMAGE_PNG, 86_400));

app.get("/og.svg", (c) => c.body(`<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1200 630"><defs><pattern id="grid" width="32" height="32" patternUnits="userSpaceOnUse"><path d="M32 0H0V32" fill="none" stroke="#075C59" stroke-opacity=".12"/></pattern><pattern id="wells" width="42" height="42" patternUnits="userSpaceOnUse"><circle cx="21" cy="21" r="7" fill="none" stroke="#16B8B0" stroke-opacity=".55"/></pattern></defs><rect width="1200" height="630" fill="#F3EFE2"/><rect width="1200" height="630" fill="url(#grid)"/><rect x="70" y="62" width="1060" height="506" fill="#FBF7EA" stroke="#075C59" stroke-opacity=".45"/><rect x="666" y="126" width="382" height="286" fill="url(#wells)" opacity=".65"/><rect x="712" y="174" width="264" height="64" fill="#FBF7EA" stroke="#075C59" stroke-opacity=".5"/><rect x="712" y="266" width="264" height="84" fill="#FBF7EA" stroke="#075C59" stroke-opacity=".5"/><circle cx="742" cy="308" r="8" fill="#FF5A36"/><text x="110" y="128" font-family="ui-monospace, monospace" font-size="18" font-weight="700" fill="#075C59" letter-spacing="3">MOTE · LOCAL MAC APP SHELL</text><text x="110" y="280" font-family="system-ui, sans-serif" font-size="72" font-weight="720" fill="#075C59" letter-spacing="-4">Build a Mac control</text><text x="110" y="358" font-family="system-ui, sans-serif" font-size="72" font-weight="720" fill="#075C59" letter-spacing="-4">panel in Svelte.</text><text x="114" y="426" font-family="system-ui, sans-serif" font-size="28" fill="#172019">Editable source files. Bounded native capabilities.</text><text x="114" y="506" font-family="ui-monospace, monospace" font-size="18" fill="#075C59" letter-spacing="2">APPKIT · WKWEBVIEW · SVELTE · LOCAL WORKSPACE</text></svg>`, 200, { "content-type": "image/svg+xml", "cache-control": "public, max-age=86400" }));
app.get("/robots.txt", (c) => c.text("User-agent: *\nAllow: /\nSitemap: https://mote.coey.dev/sitemap.xml\n", 200, { "content-type": "text/plain; charset=utf-8" }));
app.get("/sitemap.xml", () => new Response(`<?xml version="1.0" encoding="UTF-8"?><urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9"><url><loc>https://mote.coey.dev/</loc><lastmod>2026-06-13</lastmod><changefreq>weekly</changefreq><priority>1.0</priority></url><url><loc>https://mote.coey.dev/docs</loc><lastmod>2026-06-13</lastmod><changefreq>weekly</changefreq><priority>0.8</priority></url></urlset>`, { headers: { "content-type": "application/xml; charset=utf-8", "cache-control": "public, max-age=3600" } }));
app.get("/manifest.webmanifest", (c) => c.json({
  name: "Mote",
  short_name: "Mote",
  description,
  id: `${origin}/`,
  start_url: "/",
  scope: "/",
  display: "standalone",
  orientation: "any",
  background_color: "#F3EFE2",
  theme_color: "#075C59",
  categories: ["developer", "productivity", "utilities"],
  lang: "en-US",
  dir: "ltr",
  icons: [
    { src: "/icon.svg", sizes: "any", type: "image/svg+xml", purpose: "any maskable" },
    { src: "/icon-192.png", sizes: "192x192", type: "image/png", purpose: "any maskable" },
    { src: "/icon-512.png", sizes: "512x512", type: "image/png", purpose: "any maskable" },
  ],
  shortcuts: [
    { name: "Docs", short_name: "Docs", url: "/docs", description: "Read Mote architecture and setup notes." },
  ],
  prefer_related_applications: false,
}, 200, { "content-type": "application/manifest+json; charset=utf-8", "cache-control": "public, max-age=3600" }));

export default app;
