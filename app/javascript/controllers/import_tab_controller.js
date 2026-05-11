import { Controller } from "@hotwired/stimulus"

const ACTIVE   = ["border-b-2", "border-blue-600", "text-blue-700"]
const INACTIVE = ["border-b-2", "border-transparent", "text-gray-500", "hover:text-gray-700"]

export default class extends Controller {
  static targets = ["pdfTab", "doiTab", "pdfPanel", "doiPanel"]

  connect() {
    this.showPdf()
  }

  showPdf() {
    this._activate(this.pdfTabTarget)
    this._deactivate(this.doiTabTarget)
    this.pdfPanelTarget.classList.remove("hidden")
    this.doiPanelTarget.classList.add("hidden")
    this._setDisabled(this.doiPanelTarget, true)
    this._setDisabled(this.pdfPanelTarget, false)
  }

  showDoi() {
    this._activate(this.doiTabTarget)
    this._deactivate(this.pdfTabTarget)
    this.doiPanelTarget.classList.remove("hidden")
    this.pdfPanelTarget.classList.add("hidden")
    this._setDisabled(this.pdfPanelTarget, true)
    this._setDisabled(this.doiPanelTarget, false)
  }

  _activate(el) {
    el.classList.remove(...INACTIVE)
    el.classList.add(...ACTIVE)
  }

  _deactivate(el) {
    el.classList.remove(...ACTIVE)
    el.classList.add(...INACTIVE)
  }

  _setDisabled(panel, disabled) {
    panel.querySelectorAll("input, select, textarea").forEach(el => {
      el.disabled = disabled
    })
  }
}
