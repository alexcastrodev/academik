import { Controller } from "@hotwired/stimulus"

const COLORS = {
  yellow: "#fde68a",
  green:  "#86efac",
  blue:   "#93c5fd",
  red:    "#fca5a5",
  purple: "#c4b5fd"
}

export default class extends Controller {
  static targets = ["canvas", "textLayer", "pageNum", "pageCount",
                    "annotationList", "selectionToolbar", "notePopup", "noteText"]
  static values  = { url: String, annotationsUrl: String, paperId: Number }

  async connect() {
    const pdfjsLib = await import("pdfjs-dist")
    pdfjsLib.GlobalWorkerOptions.workerSrc =
      "https://cdn.jsdelivr.net/npm/pdfjs-dist@4.9.155/build/pdf.worker.min.mjs"

    this.pdfjsLib         = pdfjsLib
    this.currentPage      = 1
    this.scale            = 1.4
    this.annotations      = []
    this.activeColor      = "yellow"
    this.pendingAnnotation = null
    this._savedRange      = null

    this.pdf = await this.pdfjsLib.getDocument(this.urlValue).promise
    this.pageCountTarget.textContent = this.pdf.numPages
    await this.renderPage(this.currentPage)
    await this.loadAnnotations()
  }

  // ── Navigation ──────────────────────────────────────────────────────────────

  async prevPage() {
    if (this.currentPage <= 1) return
    this._dismissAll()
    this.currentPage--
    await this.renderPage(this.currentPage)
    this.renderHighlights()
  }

  async nextPage() {
    if (this.currentPage >= this.pdf.numPages) return
    this._dismissAll()
    this.currentPage++
    await this.renderPage(this.currentPage)
    this.renderHighlights()
  }

  setColor(event) {
    this.activeColor = event.currentTarget.dataset.color
    this.element.querySelectorAll("[data-color]").forEach(btn => {
      btn.classList.toggle("ring-2", btn.dataset.color === this.activeColor)
      btn.classList.toggle("ring-offset-1", btn.dataset.color === this.activeColor)
    })
  }

  // ── Render ───────────────────────────────────────────────────────────────────

  async renderPage(num) {
    const page     = await this.pdf.getPage(num)
    const viewport = page.getViewport({ scale: this.scale })
    const canvas   = this.canvasTarget
    const ctx      = canvas.getContext("2d")

    canvas.height = viewport.height
    canvas.width  = viewport.width

    await page.render({ canvasContext: ctx, viewport }).promise

    const textContent = await page.getTextContent()
    const textLayer   = this.textLayerTarget
    textLayer.innerHTML = ""
    textLayer.style.width  = `${viewport.width}px`
    textLayer.style.height = `${viewport.height}px`
    textLayer.style.setProperty("--scale-factor", this.scale)

    const textLayerInstance = new this.pdfjsLib.TextLayer({
      textContentSource: textContent,
      container:         textLayer,
      viewport:          viewport
    })
    await textLayerInstance.render()

    this.pageNumTarget.textContent = num
  }

  // ── Selection → Annotation ───────────────────────────────────────────────────

  handleSelection() {
    const selection = window.getSelection()
    if (!selection || selection.isCollapsed) return

    const text = selection.toString().trim()
    if (!text) return

    const range     = selection.getRangeAt(0)
    // Save the range so we can restore it after opening note popup
    this._savedRange = range.cloneRange()

    const rects     = Array.from(range.getClientRects())
    const layerRect = this.textLayerTarget.getBoundingClientRect()

    // Store per-line rects for precise highlight rendering
    const lineRects = rects.map(r => ({
      top:    r.top    - layerRect.top,
      left:   r.left   - layerRect.left,
      width:  r.width,
      height: r.height
    })).filter(r => r.width > 0 && r.height > 0)

    // Bounding box of whole selection (for toolbar positioning)
    const boundTop    = Math.min(...rects.map(r => r.top))
    const boundLeft   = Math.min(...rects.map(r => r.left))
    const boundBottom = Math.max(...rects.map(r => r.bottom))
    const boundRight  = Math.max(...rects.map(r => r.right))

    // Calculate character offset within the full text layer so we can find
    // the exact occurrence (not just the first one) when re-rendering
    const startOffset = this._rangeStartOffset(range)

    this.pendingAnnotation = {
      page:          this.currentPage,
      selected_text: text,
      color:         this.activeColor,
      start_offset:  startOffset,
      _lineRects:    lineRects,
      _boundRect: {
        top:    boundTop    - layerRect.top,
        left:   boundLeft   - layerRect.left,
        bottom: boundBottom - layerRect.top,
        right:  boundRight  - layerRect.left,
        width:  boundRight  - boundLeft,
        height: boundBottom - boundTop
      }
    }

    const toolbar     = this.selectionToolbarTarget
    const toolbarLeft = Math.min(
      Math.max(boundLeft - layerRect.left + (boundRight - boundLeft) / 2 - 80, 0),
      layerRect.width - 180
    )
    toolbar.style.top  = `${boundTop - layerRect.top - 44}px`
    toolbar.style.left = `${toolbarLeft}px`
    toolbar.classList.remove("hidden")
  }

  highlightDirect(event) {
    event.preventDefault()
    this._dismissToolbar()
    this._saveAnnotation("")
  }

  openNotePopup(event) {
    event.preventDefault()
    this._dismissToolbar()

    // Draw temporary pending highlight so user sees what they're annotating
    this._clearPendingHighlights()
    this.pendingAnnotation._lineRects.forEach(r =>
      this._drawRectHighlight(r, this.pendingAnnotation.color, "__pending__")
    )

    const bound     = this.pendingAnnotation._boundRect
    const layerRect = this.textLayerTarget.getBoundingClientRect()
    const popup     = this.notePopupTarget
    popup.style.top  = `${bound.bottom + 6}px`
    popup.style.left = `${Math.min(bound.left, layerRect.width - 288)}px`
    popup.classList.remove("hidden")
    this.noteTextTarget.value = ""
  }

  _clearPendingHighlights() {
    this.textLayerTarget.querySelectorAll('[data-ann-id="__pending__"]').forEach(el => el.remove())
  }

  async saveAnnotation() {
    if (!this.pendingAnnotation) return
    const note = this.noteTextTarget.value.trim()
    this.notePopupTarget.classList.add("hidden")
    this._clearPendingHighlights()
    window.getSelection()?.removeAllRanges()
    this._savedRange = null
    await this._saveAnnotation(note)
  }

  cancelAnnotation(event) {
    event?.preventDefault()
    this._dismissToolbar()
    this._clearPendingHighlights()
    this.notePopupTarget.classList.add("hidden")
    window.getSelection()?.removeAllRanges()
    this._savedRange = null
    this.pendingAnnotation = null
  }

  _dismissToolbar() {
    this.selectionToolbarTarget.classList.add("hidden")
  }

  _dismissAll() {
    this.selectionToolbarTarget.classList.add("hidden")
    this.notePopupTarget.classList.add("hidden")
    this._clearPendingHighlights()
    window.getSelection()?.removeAllRanges()
    this._savedRange = null
    this.pendingAnnotation = null
  }

  async _saveAnnotation(note) {
    if (!this.pendingAnnotation) return
    const pending = this.pendingAnnotation
    this.pendingAnnotation = null

    const payload = {
      page:          pending.page,
      selected_text: pending.selected_text,
      color:         pending.color,
      start_offset:  pending.start_offset,
      note
    }

    const res = await fetch(this.annotationsUrlValue, {
      method:  "POST",
      headers: { "Content-Type": "application/json", "X-CSRF-Token": this._csrf() },
      body:    JSON.stringify({ annotation: payload })
    })

    if (res.ok) {
      const saved = await res.json()
      // Draw immediate highlight from captured line rects
      if (pending._lineRects) {
        pending._lineRects.forEach(r => this._drawRectHighlight(r, saved.color, saved.id))
      }
      await this.loadAnnotations()
    }
  }

  // ── Annotations list ─────────────────────────────────────────────────────────

  async loadAnnotations() {
    const res = await fetch(this.annotationsUrlValue, {
      headers: { "Accept": "application/json" }
    })
    this.annotations = res.ok ? await res.json() : []
    this.renderSidebar()
    this.renderHighlights()
  }

  renderSidebar() {
    const list = this.annotationListTarget
    list.innerHTML = ""

    const highlights = this.annotations.filter(a => !a.note)
    const notes      = this.annotations.filter(a => a.note)

    if (this.annotations.length === 0) {
      list.innerHTML = '<p class="text-xs text-gray-400 text-center mt-4">No annotations yet.<br>Select text to highlight.</p>'
      return
    }

    if (highlights.length > 0) {
      this._renderSidebarSection(list, "Highlights", highlights)
    }

    if (notes.length > 0) {
      if (highlights.length > 0) {
        const divider = document.createElement("div")
        divider.className = "border-t border-gray-100 my-2"
        list.appendChild(divider)
      }
      this._renderSidebarSection(list, "Notes", notes)
    }
  }

  _renderSidebarSection(list, title, items) {
    const header = document.createElement("p")
    header.className = "text-[10px] font-semibold uppercase tracking-wider text-gray-400 px-3 pt-3 pb-1"
    header.textContent = title
    list.appendChild(header)

    items.forEach(ann => {
      const item = document.createElement("div")
      item.className = "group px-3 py-2 hover:bg-gray-50 cursor-pointer border-l-2 mb-1 mx-2 rounded transition-colors"
      item.style.borderColor = COLORS[ann.color] || COLORS.yellow
      item.dataset.annotationId = ann.id
      item.innerHTML = `
        <p class="text-xs text-gray-700 line-clamp-2 leading-relaxed">${this._esc(ann.selected_text)}</p>
        ${ann.note ? `<p class="text-xs text-gray-400 mt-1 italic leading-relaxed">${this._esc(ann.note)}</p>` : ""}
        <div class="flex items-center gap-2 mt-1">
          <span class="text-[10px] text-gray-300">p.${ann.page}</span>
          <button class="hidden group-hover:block text-[10px] text-red-400 hover:text-red-600 ml-auto"
                  data-action="delete">Delete</button>
        </div>
      `
      item.querySelector("[data-action='delete']")?.addEventListener("click", e => {
        e.stopPropagation()
        this.deleteAnnotation(ann.id)
      })
      item.addEventListener("click", () => this.jumpToAnnotation(ann))
      list.appendChild(item)
    })
  }

  renderHighlights() {
    this.textLayerTarget.querySelectorAll(".pdf-highlight").forEach(el => el.remove())

    // Collect all rects per annotation, then merge overlapping rects before drawing
    const allRects = []
    this.annotations
      .filter(a => a.page === this.currentPage)
      .forEach(ann => {
        const rects = this._getHighlightRects(ann.selected_text, ann.start_offset)
        rects.forEach(r => allRects.push({ ...r, color: ann.color, annId: ann.id }))
      })

    // Merge rects that overlap on the same visual line (within 2px vertical tolerance)
    const merged = this._mergeRects(allRects)
    merged.forEach(r => this._drawRectHighlight(r, r.color, r.annId))
  }

  _mergeRects(rects) {
    if (rects.length === 0) return []

    // Group by same color + approximate line (top within 2px)
    const lineKey = r => `${r.color}:${Math.round(r.top / 2) * 2}`
    const groups  = new Map()

    rects.forEach(r => {
      const key = lineKey(r)
      if (!groups.has(key)) {
        groups.set(key, { ...r })
      } else {
        const g      = groups.get(key)
        const right  = Math.max(g.left + g.width, r.left + r.width)
        g.left   = Math.min(g.left, r.left)
        g.width  = right - g.left
        g.height = Math.max(g.height, r.height)
        // keep the annId of the first rect (for flash/scroll)
      }
    })

    return Array.from(groups.values())
  }

  async deleteAnnotation(id) {
    await fetch(`${this.annotationsUrlValue}/${id}`, {
      method:  "DELETE",
      headers: { "X-CSRF-Token": this._csrf() }
    })
    await this.loadAnnotations()
  }

  async jumpToAnnotation(ann) {
    if (ann.page !== this.currentPage) {
      this.currentPage = ann.page
      await this.renderPage(ann.page)
      this.renderHighlights()
    }
    // Flash the highlight(s) for this annotation
    const els = this.textLayerTarget.querySelectorAll(`[data-ann-id="${ann.id}"]`)
    els[0]?.scrollIntoView({ behavior: "smooth", block: "center" })
    els.forEach(el => {
      el.style.transition = "none"
      el.style.opacity = "1"
      el.style.outline = `3px solid ${COLORS[ann.color] || COLORS.yellow}`
      el.style.outlineOffset = "1px"
      el.style.zIndex = "10"
      setTimeout(() => {
        el.style.transition = "opacity 0.4s, outline 0.4s"
        el.style.opacity = "0.45"
        el.style.outline = "none"
        el.style.zIndex = ""
      }, 600)
    })

    // Highlight active item in sidebar
    this.annotationListTarget.querySelectorAll("[data-annotation-id]").forEach(el => {
      el.classList.toggle("bg-blue-50", el.dataset.annotationId === String(ann.id))
    })
  }

  // ── Helpers ──────────────────────────────────────────────────────────────────

  _getHighlightRects(text, startOffset) {
    if (!text) return []
    const layer  = this.textLayerTarget
    const spans  = Array.from(layer.querySelectorAll("span"))
    const joined = spans.map(s => s.textContent).join("")

    // Use saved offset if available, else fall back to first occurrence
    let idx = (startOffset != null && startOffset >= 0)
      ? startOffset
      : joined.indexOf(text)
    // Validate: text at idx must match (offset may be stale if PDF re-renders)
    if (idx < 0 || joined.slice(idx, idx + text.length) !== text) {
      idx = joined.indexOf(text)
    }
    if (idx < 0) return []

    let pos = 0
    let startNode = null, startNodeOffset = 0, endNode = null, endNodeOffset = 0

    for (const span of spans) {
      const len   = span.textContent.length
      const start = pos
      const end   = pos + len

      if (startNode === null && end > idx) {
        startNode       = span.childNodes[0] || span
        startNodeOffset = idx - start
      }
      if (end >= idx + text.length) {
        endNode       = span.childNodes[0] || span
        endNodeOffset = idx + text.length - start
        break
      }
      pos = end
    }

    if (!startNode || !endNode) return []

    const range     = document.createRange()
    const layerRect = layer.getBoundingClientRect()
    try {
      range.setStart(startNode, Math.min(startNodeOffset, startNode.length || 0))
      range.setEnd(endNode,   Math.min(endNodeOffset,   endNode.length   || 0))
    } catch { return [] }

    return Array.from(range.getClientRects())
      .filter(r => r.width > 0 && r.height > 0)
      .map(r => ({
        top:    r.top    - layerRect.top,
        left:   r.left   - layerRect.left,
        width:  r.width,
        height: r.height
      }))
  }

  // Returns the character offset of the Range's start within the full text layer
  _rangeStartOffset(range) {
    const spans = Array.from(this.textLayerTarget.querySelectorAll("span"))
    let offset  = 0
    for (const span of spans) {
      const node = span.childNodes[0]
      if (node && range.startContainer === node) {
        return offset + range.startOffset
      }
      offset += span.textContent.length
    }
    return 0
  }

  _drawRectHighlight(rect, color, annId) {
    const el = document.createElement("div")
    el.className = "pdf-highlight absolute pointer-events-none"
    if (annId) el.dataset.annId = annId
    el.style.cssText = `
      top:${rect.top}px; left:${rect.left}px;
      width:${rect.width}px; height:${rect.height}px;
      background:${COLORS[color] || COLORS.yellow}; opacity:0.45;
      border-radius:2px; mix-blend-mode:multiply;
    `
    this.textLayerTarget.appendChild(el)
  }

  _csrf() {
    return document.querySelector("meta[name='csrf-token']")?.content ?? ""
  }

  _esc(str) {
    return str?.replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;") ?? ""
  }
}
