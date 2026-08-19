class BookstorePage {
  constructor(page) {
    this.page = page;
    this.searchInput  = page.locator('#search-input');
    this.searchBtn    = page.locator('#search-btn');
    this.resultsGrid  = page.locator('#results');
    this.emptyState   = page.locator('#empty-state');
    this.bookCards    = page.locator('.book-card');
  }

  async goto() {
    await this.page.goto('/');
    await this.page.waitForSelector('.book-card', { timeout: 5000 });
  }

  async typeSearch(query) {
    await this.searchInput.fill(query);
    await this.page.waitForTimeout(400);
  }

  async typeSearchAndPressEnter(query) {
    await this.searchInput.fill(query);
    await this.searchInput.press('Enter');
    await this.page.waitForTimeout(200);
  }

  async clickSearchButton() {
    await this.searchBtn.click();
    await this.page.waitForTimeout(200);
  }

  async clearSearch() {
    await this.searchInput.fill('');
    await this.page.waitForTimeout(400);
  }

  async getCardCount() {
    return this.bookCards.count();
  }

  firstCard() {
    return this.bookCards.first();
  }
}

module.exports = { BookstorePage };
