import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["source"]

  async connect() {
    try {
      const { EditorView, basicSetup } = await import("codemirror")
      const { EditorState }            = await import("@codemirror/state")
      const { StreamLanguage }         = await import("@codemirror/language")
      const { stex }                   = await import("@codemirror/legacy-modes/mode/stex")

      const initialContent = this.sourceTarget.value

      this.view = new EditorView({
        state: EditorState.create({
          doc: initialContent,
          extensions: [basicSetup, StreamLanguage.define(stex)]
        }),
        parent: this.sourceTarget.parentElement
      })

      this.sourceTarget.style.display = "none"

      const form = this.element.closest("form")
      if (form) {
        form.addEventListener("submit", () => {
          this.sourceTarget.value = this.view.state.doc.toString()
        })
      }
    } catch (e) {
      console.warn("CodeMirror unavailable, using plain textarea:", e)
    }
  }

  disconnect() {
    this.view?.destroy()
  }
}
