import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["panel", "row"]

  open(event) {
    const row = event.currentTarget
    const url = row.dataset.paperUrl
    if (url) {
      window.location.href = url
      return
    }
    this.rowTargets.forEach(r => r.classList.toggle("selected", r === row))
    this.panelTarget.classList.add("open")
  }

  close() {
    this.panelTarget.classList.remove("open")
    this.rowTargets.forEach(r => r.classList.remove("selected"))
  }
}
