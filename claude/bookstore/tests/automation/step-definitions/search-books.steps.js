const { createBdd } = require('playwright-bdd');
const { test, expect } = require('../support/fixtures');

const { Given, When, Then } = createBdd(test);

Given('I am on the bookstore homepage', async ({ bookstorePage }) => {
  await bookstorePage.goto();
});

When('I type {string} in the search bar', async ({ bookstorePage }, query) => {
  await bookstorePage.typeSearch(query);
});

When('I type {string} in the search bar and press Enter', async ({ bookstorePage }, query) => {
  await bookstorePage.typeSearchAndPressEnter(query);
});

When('I click the search button', async ({ bookstorePage }) => {
  await bookstorePage.clickSearchButton();
});

When('I clear the search input', async ({ bookstorePage }) => {
  await bookstorePage.clearSearch();
});

When('I type a string of 110 characters in the search bar', async ({ bookstorePage }) => {
  const longString = 'A'.repeat(110);
  await bookstorePage.searchInput.fill(longString);
});

Then('the search input is visible', async ({ bookstorePage }) => {
  await expect(bookstorePage.searchInput).toBeVisible();
});

Then('the results grid is visible', async ({ bookstorePage }) => {
  await expect(bookstorePage.resultsGrid).toBeVisible();
});

Then('at least 1 book card is displayed', async ({ bookstorePage }) => {
  const count = await bookstorePage.getCardCount();
  expect(count).toBeGreaterThanOrEqual(1);
});

Then('only books with {string} in the title are displayed', async ({ bookstorePage }, term) => {
  const cards = bookstorePage.bookCards;
  const count = await cards.count();
  expect(count).toBeGreaterThan(0);
  for (let i = 0; i < count; i++) {
    const title = await cards.nth(i).locator('.book-title').textContent();
    expect(title.toLowerCase()).toContain(term.toLowerCase());
  }
});

Then('books matching {string} are displayed', async ({ bookstorePage }, term) => {
  const cards = bookstorePage.bookCards;
  const count = await cards.count();
  expect(count).toBeGreaterThan(0);
  for (let i = 0; i < count; i++) {
    const title = await cards.nth(i).locator('.book-title').textContent();
    expect(title.toLowerCase()).toContain(term.toLowerCase());
  }
});

Then('the empty state message is displayed', async ({ bookstorePage }) => {
  await expect(bookstorePage.emptyState).toBeVisible();
});

Then('the results grid is hidden', async ({ bookstorePage }) => {
  await expect(bookstorePage.resultsGrid).toBeHidden();
});

Then('the first book card shows a cover image', async ({ bookstorePage }) => {
  const img = bookstorePage.firstCard().locator('.book-cover');
  await expect(img).toBeVisible();
  const src = await img.getAttribute('src');
  expect(src).toBeTruthy();
});

Then('the first book card shows a title', async ({ bookstorePage }) => {
  const title = bookstorePage.firstCard().locator('.book-title');
  await expect(title).toBeVisible();
  const text = await title.textContent();
  expect(text.trim()).toBeTruthy();
});

Then('the first book card shows an author', async ({ bookstorePage }) => {
  const author = bookstorePage.firstCard().locator('.book-author');
  await expect(author).toBeVisible();
  const text = await author.textContent();
  expect(text.trim()).toBeTruthy();
});

Then('the first book card shows a price', async ({ bookstorePage }) => {
  const price = bookstorePage.firstCard().locator('.book-price');
  await expect(price).toBeVisible();
  const text = await price.textContent();
  expect(text.trim()).toBeTruthy();
});

Then('the first book card shows an {string} button', async ({ bookstorePage }, label) => {
  const btn = bookstorePage.firstCard().locator('.add-to-cart-btn');
  await expect(btn).toBeVisible();
  await expect(btn).toContainText(label);
});

Then('the search input value is no longer than 100 characters', async ({ bookstorePage }) => {
  const value = await bookstorePage.searchInput.inputValue();
  expect(value.length).toBeLessThanOrEqual(100);
});
