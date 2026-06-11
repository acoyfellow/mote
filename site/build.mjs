import { buildHonoSvelte } from "svelte-hono/build";

const result = await buildHonoSvelte({
  workerEntry: "./worker.ts",
  outDir: "./build",
  components: {
    home: "./Home.svelte",
    docs: "./Docs.svelte"
  }
});

console.log(`mote.coey.dev: ${(result.workerBytes / 1024).toFixed(1)} KB worker`);
