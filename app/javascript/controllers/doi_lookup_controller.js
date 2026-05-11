import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "status",
                    "title", "authors", "year", "journal", "doi", "abstract"]

  async lookup() {
    const value = this.inputTarget.value.trim()
    if (!value) return

    this._setStatus("loading", "Fetching metadata…")

    try {
      const res = await fetch(`/papers/resolve_doi?input=${encodeURIComponent(value)}`, {
        headers: { "Accept": "application/json", "X-CSRF-Token": this._csrf() }
      })

      if (!res.ok) { this._setStatus("error", "Could not fetch metadata."); return }

      const data = await res.json()
      if (!data || Object.keys(data).length === 0) {
        this._setStatus("error", "No metadata found for this DOI/URL.")
        return
      }

      if (data.title    && this.hasTitleTarget)    this.titleTarget.value    = data.title
      if (data.authors  && this.hasAuthorsTarget)  this.authorsTarget.value  = data.authors
      if (data.year     && this.hasYearTarget)     this.yearTarget.value     = data.year
      if (data.journal  && this.hasJournalTarget)  this.journalTarget.value  = data.journal
      if (data.doi      && this.hasDOITarget)      this.doiTarget.value      = data.doi
      if (data.abstract && this.hasAbstractTarget) this.abstractTarget.value = data.abstract

      const msg = data.pdf_url
        ? "Metadata loaded. PDF will be attached automatically."
        : "Metadata loaded."
      this._setStatus("ok", msg)
    } catch {
      this._setStatus("error", "Network error.")
    }
  }

  _setStatus(type, msg) {
    if (!this.hasStatusTarget) return
    const colors = { loading: "text-blue-500", ok: "text-green-600", error: "text-red-500" }
    this.statusTarget.textContent = msg
    this.statusTarget.className = `mt-1 text-xs ${colors[type]}`
  }

  _csrf() {
    return document.querySelector("meta[name='csrf-token']")?.content ?? ""
  }
}
