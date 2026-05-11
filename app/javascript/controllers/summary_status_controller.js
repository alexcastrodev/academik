import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { paperId: Number }

  connect() {
    this.scheduleRefresh()
  }

  disconnect() {
    clearTimeout(this.timeout)
  }

  scheduleRefresh() {
    this.timeout = setTimeout(() => {
      const frame = document.querySelector(`turbo-frame#summary_paper_${this.paperIdValue}`)
      if (frame) frame.reload()
    }, 5000)
  }
}
