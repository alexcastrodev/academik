import { BasePage } from "./BasePage.js"

export class PapersPage extends BasePage {
  constructor(page) {
    super(page)
    this.rows = page.locator("tr[data-paper-url]")
    this.mobileLinks = page.locator("ul li a")
  }

  async goto() {
    await super.goto("/papers")
  }

  async firstRowUrl() {
    return this.rows.first().getAttribute("data-paper-url")
  }

  async clickFirstRow() {
    await this.rows.first().click()
  }

  async firstMobileHref() {
    return this.mobileLinks.first().getAttribute("href")
  }

  async clickFirstMobileLink() {
    await this.mobileLinks.first().click()
  }
}
