const { defineConfig } = require('@playwright/test');
const { defineBddConfig } = require('playwright-bdd');

const testDir = defineBddConfig({
  features: 'tests/manual/features/**/*.feature',
  steps: [
    'tests/automation/step-definitions/**/*.steps.js',
    'tests/automation/support/fixtures.js',
  ],
  importTestFrom: 'tests/automation/support/fixtures.js',
});

module.exports = defineConfig({
  testDir,
  fullyParallel: false,
  timeout: 15000,
  use: {
    baseURL: 'http://localhost:3001',
    headless: true,
    screenshot: 'only-on-failure',
  },
  webServer: {
    command: 'node node_modules/serve/build/main.js -l 3001 .',
    url: 'http://localhost:3001',
    reuseExistingServer: !process.env.CI,
    timeout: 15000,
  },
  reporter: [['list'], ['html', { open: 'never' }]],
});
