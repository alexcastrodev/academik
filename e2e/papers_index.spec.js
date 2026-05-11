import { test, expect } from "@playwright/test"
import { PapersPage } from "./pages/PapersPage.js"

test.describe("Papers index", () => {
  test("clicking a paper row navigates to its show page", async ({ page }) => {
    const papers = new PapersPage(page)
    await papers.goto()

    await expect(papers.rows.first()).toBeVisible()
    const url = await papers.firstRowUrl()

    await papers.clickFirstRow()

    await expect(page).toHaveURL(new RegExp(url))
  })

  test("clicking a paper on mobile navigates to its show page", async ({ page }) => {
    await page.setViewportSize({ width: 375, height: 812 })

    const papers = new PapersPage(page)
    await papers.goto()

    await expect(papers.mobileLinks.first()).toBeVisible()
    const href = await papers.firstMobileHref()

    await papers.clickFirstMobileLink()

    await expect(page).toHaveURL(new RegExp(href))
  })
})
