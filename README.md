# Mote

**A programmable personal edge.**

Mote is a local-first application shell for macOS. It gives editable Svelte interfaces controlled access to native capabilities, so personal tools can change without recompiling the native app.

Edit a `.svelte` file. Save it. The menu-bar panel changes immediately.

## What works today

- Native AppKit status item and anchored `NSPanel`
- Svelte 5 interface inside `WKWebView`
- Vite hot-module reload from a local workspace
- Promise-based Swift ↔ JavaScript bridge
- Bounded local controls for the current AX surface
- Configured remote-activity inbox with connector health, recent sessions, attention acknowledgements, and session steering
- Native right-click recovery menu
- Offline runtime after dependencies are installed
- Cloudflare Worker documentation site built with `svelte-hono`

This is an early vertical slice, not yet a Hammerspoon replacement or a signed release.

## Run from source

Requirements: macOS 14+, Swift/Xcode command-line tools, and [Bun](https://bun.sh).

```sh
git clone https://github.com/acoyfellow/mote
cd mote/workspace
bun install

cd ..
./scripts/run.sh
```

Click the small mote in the menu bar. Right-click for recovery controls.

While Mote runs, edit:

```text
workspace/src/App.svelte
workspace/src/style.css
```

The live panel updates without rebuilding Swift.

## Install the prototype

```sh
./scripts/install.sh
open /Applications/Mote.app
```

The installer creates:

```text
/Applications/Mote.app
~/.mote/workspaces/ax
```

Edit `~/.mote/workspaces/ax/src/App.svelte` and save to update the installed app live.

## Architecture

```text
Mote.app
├── AppKit status item + NSPanel
├── WKWebView
├── native capability bridge
└── local runtime process
      └── editable Svelte workspace + Vite HMR
```

The native host is intentionally small and stable. Svelte owns layout, interaction, visual design, and composition. Swift is only required when adding a genuinely new native macOS primitive or entitlement.

Current bridge commands:

| Namespace | Commands |
|---|---|
| `app` | info, configuration, open workspace, open logs |
| `machinectl` | status, start, stop, restart |
| `reachability` | status, start, stop |
| `maintenance` | report, cleanup |
| `authResource` | status, refresh |
| `remoteCoordinator` | overview, acknowledge, steer, open |

The current AX surface invokes the existing scripts in `~/.hammerspoon`. This keeps the first migration reversible. Those implementations can move behind native or LaunchAgent-backed capabilities later without changing the Svelte API.

Employee-only resource names, endpoints, and CLI details are not part of this repository. They live in `~/.mote/config/employee.json`, a local runtime layer outside the workspace and application bundle. Public source uses only generic capability names.

## Repository

```text
app/        Swift/AppKit native host
workspace/  First editable Svelte surface
scripts/    Run and install helpers
```

## Develop

```sh
# Svelte surface
cd workspace
bun run check
bun run build

# Native host + capability/lifecycle integration tests
cd app
swift test

# Browser smoke test for every control on the Svelte surface
cd ../workspace
bun run dev -- --host 127.0.0.1 --port 41732 --strictPort
# in another terminal, from the repository root:
MOTE_SURFACE_URL=http://127.0.0.1:41732 node scripts/test-surface.mjs

```

## Cloudflare

Mote is useful offline. Cloudflare is the optional trust and reach layer:

- **Access** authenticates people and agents reaching a personal device.
- **Durable Objects** route one live outbound-connected Mac and its approval state.
- **AI Gateway / Workers AI** can power optional interface co-generation.
- **Workers** can host explicitly reviewed connected control surfaces.
- **R2** can hold encrypted, content-addressed bundle history.

## License

MIT
