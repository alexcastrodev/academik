import { test, expect } from "@playwright/test"
import { PdfViewerPage } from "./pages/PdfViewerPage.js"

test.describe("PDF Viewer", () => {
  let viewer

  test.beforeEach(async ({ page }) => {
    viewer = new PdfViewerPage(page)
    await viewer.goto()
  })

  test("renders PDF canvas with correct dimensions", async () => {
    const box = await viewer.canvas.boundingBox()
    expect(box.width).toBeGreaterThan(400)
    expect(box.height).toBeGreaterThan(400)
  })

  test("shows page number and total pages", async () => {
    await expect(viewer.pageNum).toHaveText("1")
    const count = parseInt(await viewer.pageCount.textContent())
    expect(count).toBeGreaterThan(1)
  })

  test("navigates to next and previous page", async () => {
    await viewer.clickNext()
    await expect(viewer.pageNum).toHaveText("2")

    await viewer.clickPrev()
    await expect(viewer.pageNum).toHaveText("1")
  })

  test("toolbar closes when changing page", async () => {
    await viewer.selectTextSpans(2, 3)
    await expect(viewer.selectionToolbar).not.toHaveClass(/hidden/)

    await viewer.clickNext()
    await expect(viewer.selectionToolbar).toHaveClass(/hidden/)
  })

  test("highlight saves and renders on correct text occurrence", async ({ page }) => {
    await viewer.clearAnnotations()
    await viewer.goto()

    const secondIdx = await viewer.selectSecondOccurrence("OS")
    expect(secondIdx).toBeGreaterThan(0)

    await viewer.clickHighlight()
    await page.waitForSelector("[data-annotation-id]", { timeout: 5_000 })

    const annotations = await viewer.fetchAnnotations()
    expect(annotations).toHaveLength(1)
    expect(annotations[0].selected_text).toBe("OS")
    expect(annotations[0].start_offset).toBe(secondIdx)

    await expect(viewer.highlights).not.toHaveCount(0)
  })

  test("note popup shows pending highlight while typing", async () => {
    await viewer.selectTextSpans(5, 6)
    await viewer.clickNoteIcon()

    await expect(viewer.notePopup).not.toHaveClass(/hidden/)
    await expect(viewer.page.locator("[data-ann-id='__pending__']")).not.toHaveCount(0)
  })

  test("sidebar separates highlights and notes", async () => {
    const items = await viewer.annotationList.locator("[data-annotation-id]").count()
    if (items > 0) {
      const sections =
        (await viewer.annotationList.locator("text=HIGHLIGHTS").count()) +
        (await viewer.annotationList.locator("text=NOTES").count())
      expect(sections).toBeGreaterThan(0)
    }
  })
})
