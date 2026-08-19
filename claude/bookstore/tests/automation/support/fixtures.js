const { test: base } = require('playwright-bdd');
const { expect } = require('@playwright/test');
const { BookstorePage } = require('./page-objects/bookstore.page');

const test = base.extend({
  bookstorePage: async ({ page }, use) => {
    const bookstore = new BookstorePage(page);
    await use(bookstore);
  },
});

module.exports = { test, expect };
