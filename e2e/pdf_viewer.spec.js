import { test, expect } from "@playwright/test"

const PDF_URL = "/papers/1/pdf_viewer"

test.describe("PDF Viewer", () => {
  test.beforeEach(async ({ page }) => {
    await page.goto(PDF_URL)
    // Wait for PDF.js to render the canvas
    await page.waitForFunction(
      () => document.querySelector("[data-pdf-viewer-target='canvas']")?.width > 0,
      { timeout: 15_000 }
    )
    // Wait for text layer spans to appear
    await page.waitForSelector("#pdf-text-layer span", { timeout: 15_000 })
  })

  test("renders PDF canvas with correct dimensions", async ({ page }) => {
    const canvas = page.locator("[data-pdf-viewer-target='canvas']")
    const box = await canvas.boundingBox()
    expect(box.width).toBeGreaterThan(400)
    expect(box.height).toBeGreaterThan(400)
  })

  test("shows page number and total pages", async ({ page }) => {
    const pageNum   = page.locator("[data-pdf-viewer-target='pageNum']")
    const pageCount = page.locator("[data-pdf-viewer-target='pageCount']")
    await expect(pageNum).toHaveText("1")
    const count = parseInt(await pageCount.textContent())
    expect(count).toBeGreaterThan(1)
  })

  test("navigates to next and previous page", async ({ page }) => {
    await page.click("[data-action='click->pdf-viewer#nextPage']")
    await expect(page.locator("[data-pdf-viewer-target='pageNum']")).toHaveText("2")

    await page.click("[data-action='click->pdf-viewer#prevPage']")
    await expect(page.locator("[data-pdf-viewer-target='pageNum']")).toHaveText("1")
  })

  test("toolbar closes when changing page", async ({ page }) => {
    // Create a selection to show toolbar
    await page.evaluate(() => {
      const spans = document.querySelectorAll("#pdf-text-layer span")
      const range = document.createRange()
      range.setStart(spans[2].childNodes[0], 0)
      range.setEnd(spans[3].childNodes[0], 0)
      window.getSelection().removeAllRanges()
      window.getSelection().addRange(range)
      spans[2].parentElement.parentElement.dispatchEvent(new MouseEvent("mouseup", { bubbles: true }))
    })

    const toolbar = page.locator("[data-pdf-viewer-target='selectionToolbar']")
    await expect(toolbar).not.toHaveClass(/hidden/)

    // Navigate away — toolbar must close
    await page.click("[data-action='click->pdf-viewer#nextPage']")
    await expect(toolbar).toHaveClass(/hidden/)
  })

  test("highlight saves and renders on correct text occurrence", async ({ page }) => {
    // Delete any existing annotations first
    const res = await page.evaluate(async () => {
      const r = await fetch("/papers/1/annotations", { headers: { Accept: "application/json" } })
      return r.json()
    })
    for (const ann of res) {
      await page.evaluate(async (id) => {
        const csrf = document.querySelector("meta[name='csrf-token']").content
        await fetch(`/papers/1/annotations/${id}`, { method: "DELETE", headers: { "X-CSRF-Token": csrf } })
      }, ann.id)
    }
    await page.reload()
    await page.waitForSelector("#pdf-text-layer span", { timeout: 15_000 })

    // Find second occurrence of "OS" in the text layer
    const { secondIdx } = await page.evaluate(() => {
      const spans  = Array.from(document.querySelectorAll("#pdf-text-layer span"))
      const joined = spans.map(s => s.textContent).join("")
      const first  = joined.indexOf("OS")
      const second = joined.indexOf("OS", first + 2)
      return { firstIdx: first, secondIdx: second }
    })
    expect(secondIdx).toBeGreaterThan(0)

    // Select exactly the second "OS"
    await page.evaluate((targetOffset) => {
      const spans  = Array.from(document.querySelectorAll("#pdf-text-layer span"))
      const joined = spans.map(s => s.textContent).join("")
      let pos = 0, startNode, startOff, endNode, endOff
      for (const span of spans) {
        const len = span.textContent.length
        if (!startNode && pos + len > targetOffset) {
          startNode = span.childNodes[0]
          startOff  = targetOffset - pos
        }
        if (!endNode && pos + len >= targetOffset + 2) {
          endNode = span.childNodes[0]
          endOff  = targetOffset + 2 - pos
          break
        }
        pos += len
      }
      const range = document.createRange()
      range.setStart(startNode, startOff)
      range.setEnd(endNode, endOff)
      window.getSelection().removeAllRanges()
      window.getSelection().addRange(range)
      document.querySelector("#pdf-text-layer").parentElement.dispatchEvent(
        new MouseEvent("mouseup", { bubbles: true })
      )
    }, secondIdx)

    // Click Highlight
    await page.locator("[data-action='mousedown->pdf-viewer#highlightDirect']").dispatchEvent("mousedown")

    // Wait for annotation to appear in sidebar
    await page.waitForSelector("[data-annotation-id]", { timeout: 5_000 })

    // Verify start_offset was saved correctly
    const annotations = await page.evaluate(async () => {
      const r = await fetch("/papers/1/annotations", { headers: { Accept: "application/json" } })
      return r.json()
    })
    expect(annotations).toHaveLength(1)
    expect(annotations[0].selected_text).toBe("OS")
    expect(annotations[0].start_offset).toBe(secondIdx)

    // Verify highlight div appears on canvas
    const highlights = page.locator(".pdf-highlight")
    await expect(highlights).not.toHaveCount(0)
  })

  test("note popup shows pending highlight while typing", async ({ page }) => {
    await page.evaluate(() => {
      const spans = document.querySelectorAll("#pdf-text-layer span")
      const range = document.createRange()
      range.setStart(spans[5].childNodes[0], 0)
      range.setEnd(spans[6].childNodes[0], 0)
      window.getSelection().removeAllRanges()
      window.getSelection().addRange(range)
      spans[5].parentElement.parentElement.dispatchEvent(new MouseEvent("mouseup", { bubbles: true }))
    })

    // Click note icon
    await page.locator("[data-action='mousedown->pdf-viewer#openNotePopup']").dispatchEvent("mousedown")

    // Popup should be visible
    await expect(page.locator("[data-pdf-viewer-target='notePopup']")).not.toHaveClass(/hidden/)

    // Pending highlight should be drawn
    const pending = page.locator("[data-ann-id='__pending__']")
    await expect(pending).not.toHaveCount(0)
  })

  test("sidebar separates highlights and notes", async ({ page }) => {
    const annList = page.locator("[data-pdf-viewer-target='annotationList']")

    // If there are annotations with and without notes, check sections exist
    const hasHighlights = await annList.locator("text=HIGHLIGHTS").count()
    const hasNotes      = await annList.locator("text=NOTES").count()

    // At least one section must be present if annotations exist
    const items = await annList.locator("[data-annotation-id]").count()
    if (items > 0) {
      expect(hasHighlights + hasNotes).toBeGreaterThan(0)
    }
  })
})
