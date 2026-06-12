import { chromium } from "../workspace/node_modules/playwright/index.mjs";

const url = process.env.MOTE_SURFACE_URL ?? "http://127.0.0.1:41732";
const executablePath = process.env.MOTE_TEST_CHROMIUM;
const browser = await chromium.launch({
  headless: true,
  ...(executablePath ? { executablePath } : {}),
});
const page = await browser.newPage({ viewport: { width: 390, height: 820 } });
const errors = [];
page.on("pageerror", (error) => errors.push(error.message));
page.on("console", (message) => {
  if (message.type() === "error" && !message.text().includes("Failed to load resource")) {
    errors.push(message.text());
  }
});

try {
  await page.goto(url, { waitUntil: "networkidle" });
  await page.getByText("Connected", { exact: true }).first().waitFor();
  await page.getByText("Ready", { exact: true }).waitFor();
  await page.getByText("Remote activity", { exact: true }).waitFor();
  await page.getByText("Review requested", { exact: true }).waitFor();
  await page.getByText("Review the current change", { exact: true }).waitFor();
  await page.getByText("128G free", { exact: true }).waitFor();

  const refresh = page.getByRole("button", { name: "Refresh status" });
  await refresh.click();
  await refresh.waitFor({ state: "visible" });
  await page.waitForFunction(() => !(document.querySelector('[aria-label="Refresh status"]')?.hasAttribute("disabled")));

  const portalRefresh = page.getByRole("button", { name: "Refresh configured auth" });
  await portalRefresh.click();
  await page.waitForFunction(() => !(document.querySelector('[aria-label="Refresh configured auth"]')?.hasAttribute("disabled")));

  const remoteRefresh = page.getByRole("button", { name: "Refresh remote activity" });
  await remoteRefresh.click();
  await page.waitForFunction(() => !(document.querySelector('[aria-label="Refresh remote activity"]')?.hasAttribute("disabled")));

  await page.getByRole("button", { name: "Acknowledge" }).click();
  await page.getByRole("button", { name: "Steer" }).click();
  await page.getByRole("textbox", { name: "Steering message" }).fill("Continue, but keep the change bounded.");
  await page.getByRole("button", { name: "Send" }).click();

  for (const name of ["Restart", "Stop", "1 hour", "8 hours", "Run cleanup", "Edit this surface"]) {
    const button = page.getByRole("button", { name });
    await button.waitFor();
    await button.click();
    await page.waitForFunction(() => !Array.from(document.querySelectorAll("button")).some((item) => item.hasAttribute("disabled")), null, { timeout: 3000 });
  }

  if (errors.length) throw new Error(`Browser errors:\n${errors.join("\n")}`);
  console.log("surface smoke passed: machine, configured auth, remote activity, attention, steering, reachability, cleanup, workspace");
} finally {
  await browser.close();
}
