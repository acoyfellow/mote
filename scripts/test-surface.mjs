import { chromium } from "../workspace/node_modules/playwright/index.mjs";

const url = process.env.MOTE_SURFACE_URL ?? "http://127.0.0.1:41732";
const executablePath = process.env.MOTE_TEST_CHROMIUM;
const browser = await chromium.launch({
  headless: true,
  ...(executablePath ? { executablePath } : {}),
});
const page = await browser.newPage({ viewport: { width: 390, height: 620 } });
const errors = [];
page.on("pageerror", (error) => errors.push(error.message));
page.on("console", (message) => {
  if (message.type() === "error" && !message.text().includes("Failed to load resource")) {
    errors.push(message.text());
  }
});

try {
  await page.goto(url, { waitUntil: "networkidle" });
  await page.getByText("Connected", { exact: true }).waitFor();
  await page.getByText("Ready", { exact: true }).waitFor();
  await page.getByText("128G free", { exact: true }).waitFor();

  const refresh = page.getByRole("button", { name: "Refresh status" });
  await refresh.click();
  await refresh.waitFor({ state: "visible" });
  await page.waitForFunction(() => !(document.querySelector('[aria-label="Refresh status"]')?.hasAttribute("disabled")));

  const portalRefresh = page.getByRole("button", { name: "Refresh configured auth" });
  await portalRefresh.click();
  await page.waitForFunction(() => !(document.querySelector('[aria-label="Refresh configured auth"]')?.hasAttribute("disabled")));

  for (const name of ["Restart", "Stop", "1 hour", "8 hours", "Run cleanup", "Edit this surface"]) {
    const button = page.getByRole("button", { name });
    await button.waitFor();
    await button.click();
    await page.waitForFunction(() => !Array.from(document.querySelectorAll("button")).some((item) => item.hasAttribute("disabled")), null, { timeout: 3000 });
  }

  if (errors.length) throw new Error(`Browser errors:\n${errors.join("\n")}`);
  console.log("surface smoke passed: machine, configured auth, refresh, reachability, cleanup, workspace");
} finally {
  await browser.close();
}
