import { defineConfig } from "@playwright/test"

export default defineConfig({
  testDir: "./e2e",
  timeout: 30_000,
  use: {
    baseURL: "http://localhost:3000",
    headless: true,
    viewport: { width: 1280, height: 800 },
  },
  webServer: {
    command: "bin/rails server -p 3000",
    url: "http://localhost:3000",
    reuseExistingServer: true,
  },
})
