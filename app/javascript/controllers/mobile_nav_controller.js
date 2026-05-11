import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["sidebar", "overlay"]

  toggleSidebar() {
    const open = !this.sidebarTarget.classList.contains("translate-x-0")
    this.sidebarTarget.classList.toggle("-translate-x-full", !open)
    this.sidebarTarget.classList.toggle("translate-x-0", open)
    this.overlayTarget.classList.toggle("hidden", !open)
  }

  closeSidebar() {
    this.sidebarTarget.classList.add("-translate-x-full")
    this.sidebarTarget.classList.remove("translate-x-0")
    this.overlayTarget.classList.add("hidden")
  }
}
