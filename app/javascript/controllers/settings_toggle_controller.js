import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["ollama", "claude"]

  toggle(event) {
    const isOllama = event.target.value === "ollama"
    this.ollamaTarget.classList.toggle("opacity-50", !isOllama)
    this.claudeTarget.classList.toggle("opacity-50", isOllama)
  }
}
