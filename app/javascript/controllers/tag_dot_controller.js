import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    const dot = this.element.querySelector(".lib-tag-dot")
    if (dot) dot.style.setProperty("--tag-dot-color", this.element.dataset.tagColor)
  }
}
