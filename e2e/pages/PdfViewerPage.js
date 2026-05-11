import { BasePage } from "./BasePage.js"

export class PdfViewerPage extends BasePage {
  constructor(page) {
    super(page)
    this.canvas = page.locator("[data-pdf-viewer-target='canvas']")
    this.pageNum = page.locator("[data-pdf-viewer-target='pageNum']")
    this.pageCount = page.locator("[data-pdf-viewer-target='pageCount']")
    this.selectionToolbar = page.locator("[data-pdf-viewer-target='selectionToolbar']")
    this.annotationList = page.locator("[data-pdf-viewer-target='annotationList']")
    this.notePopup = page.locator("[data-pdf-viewer-target='notePopup']")
    this.highlights = page.locator(".pdf-highlight")
    this.textLayer = page.locator("#pdf-text-layer")
  }

  async goto(paperId = 1) {
    await super.goto(`/papers/${paperId}/pdf_viewer`)
    await this.waitForFunction(
      () => document.querySelector("[data-pdf-viewer-target='canvas']")?.width > 0,
      { timeout: 15_000 }
    )
    await this.waitForSelector("#pdf-text-layer span", { timeout: 15_000 })
  }

  async clickNext() {
    await this.page.click("[data-action='click->pdf-viewer#nextPage']")
  }

  async clickPrev() {
    await this.page.click("[data-action='click->pdf-viewer#prevPage']")
  }

  async selectTextSpans(startIdx, endIdx) {
    await this.page.evaluate(([s, e]) => {
      const spans = document.querySelectorAll("#pdf-text-layer span")
      const range = document.createRange()
      range.setStart(spans[s].childNodes[0], 0)
      range.setEnd(spans[e].childNodes[0], 0)
      window.getSelection().removeAllRanges()
      window.getSelection().addRange(range)
      spans[s].parentElement.parentElement.dispatchEvent(new MouseEvent("mouseup", { bubbles: true }))
    }, [startIdx, endIdx])
  }

  async selectSecondOccurrence(text) {
    return this.page.evaluate((needle) => {
      const spans = Array.from(document.querySelectorAll("#pdf-text-layer span"))
      const joined = spans.map(s => s.textContent).join("")
      const first = joined.indexOf(needle)
      const second = joined.indexOf(needle, first + needle.length)

      let pos = 0, startNode, startOff, endNode, endOff
      for (const span of spans) {
        const len = span.textContent.length
        if (!startNode && pos + len > second) {
          startNode = span.childNodes[0]
          startOff = second - pos
        }
        if (!endNode && pos + len >= second + needle.length) {
          endNode = span.childNodes[0]
          endOff = second + needle.length - pos
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
      return second
    }, text)
  }

  async clickHighlight() {
    await this.page.locator("[data-action='mousedown->pdf-viewer#highlightDirect']").dispatchEvent("mousedown")
  }

  async clickNoteIcon() {
    await this.page.locator("[data-action='mousedown->pdf-viewer#openNotePopup']").dispatchEvent("mousedown")
  }

  async clearAnnotations(paperId = 1) {
    const annotations = await this.page.evaluate(async (id) => {
      const r = await fetch(`/papers/${id}/annotations`, { headers: { Accept: "application/json" } })
      return r.json()
    }, paperId)

    for (const ann of annotations) {
      await this.page.evaluate(async ([id, annId]) => {
        const csrf = document.querySelector("meta[name='csrf-token']").content
        await fetch(`/papers/${id}/annotations/${annId}`, {
          method: "DELETE",
          headers: { "X-CSRF-Token": csrf },
        })
      }, [paperId, ann.id])
    }
  }

  async fetchAnnotations(paperId = 1) {
    return this.page.evaluate(async (id) => {
      const r = await fetch(`/papers/${id}/annotations`, { headers: { Accept: "application/json" } })
      return r.json()
    }, paperId)
  }
}
