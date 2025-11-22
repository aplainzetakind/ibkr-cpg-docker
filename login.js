import { chromium } from "playwright";
import { randomUUID } from "crypto";

const isPaper = !(process.env.IBKR_LIVE === "LIVE");

const variables = {
  uname: isPaper ? "IBKR_PAPER_USERNAME" : "IBKR_LIVE_USERNAME",
  passwd: isPaper ? "IBKR_PAPER_PASSWORD" : "IBKR_LIVE_PASSWORD",
};

for (let envVar of [variables.uname, variables.passwd]) {
  if (!process.env[envVar]) {
    console.log(`Environment variable ${envVar} not set. Quitting.`);
    process.exit(1);
  }
}

const uname = process.env[variables.uname];
const passwd = process.env[variables.passwd];

async function retry(fn, retries = 3) {
  let attempt = 0;
  while (true) {
    try {
      return await fn();
    } catch (err) {
      attempt++;
      if (attempt > retries) {
        console.log(`FAILED after ${retries + 1} attempts with ${err}.`);
        throw err;
      } else {
        console.log(`Attempt ${attempt} failed with ${err}. Retrying in 2s.`);
      }
      await new Promise((res) => setTimeout(res, 2000));
    }
  }
}

async function login() {
  const browser = await chromium.launch({ headless: true });
  const page = await browser.newPage();
  try {
    console.log("Logging in to client portal gateway.");
    await page.goto("http://localhost:5000");
    console.log("Login page opened.");

    if (isPaper) {
      await page.click("label[for='toggle1']");
      await page.waitForSelector("p:has-text('simulated')", {
        state: "visible",
      });
      await new Promise((res) => setTimeout(res, 1000));
      console.log("Selected paper trading.");
    } else {
      console.log("Proceeding to live trading.");
    }

    await page.fill("input[id='xyz-field-username']", uname);
    await page.fill("input[id='xyz-field-password']", passwd);

    await page.click("button:has-text('Login')");
    await page.waitForLoadState("networkidle");
    console.log("Submitted credentials.");

    await page.waitForSelector("pre:has-text('Client login succeeds')", {
      state: "visible",
    });
    console.log("Login successful.");
  } finally {
    await browser.close();
  }
}

try {
  await retry(login);
} catch (err) {
  process.exit(1);
}
