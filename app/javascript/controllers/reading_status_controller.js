import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["button"]
  static values  = { url: String }

  async update(event) {
    const status = event.currentTarget.dataset.status
    const token  = document.querySelector('meta[name="csrf-token"]').content

    this.buttonTargets.forEach(btn => btn.classList.toggle("active", btn.dataset.status === status))

    await fetch(this.urlValue, {
      method: "PATCH",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": token,
        Accept: "text/vnd.turbo-stream.html"
      },
      body: JSON.stringify({ paper: { reading_status: status } })
    })
  }
}
