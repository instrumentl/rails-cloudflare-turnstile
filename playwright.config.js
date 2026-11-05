const { defineConfig } = require("@playwright/test")

module.exports = defineConfig({
  testDir: "./spec/browser",
  fullyParallel: true,
  forbidOnly: !!process.env.CI,
  use: {
    baseURL: "http://127.0.0.1:4386",
    browserName: "chromium",
    launchOptions: process.env.CHROMIUM_PATH ? { executablePath: process.env.CHROMIUM_PATH } : {}
  },
  webServer: {
    command: "node spec/browser/server.js",
    url: "http://127.0.0.1:4386"
  }
})
