# Pin npm packages by running ./bin/importmap

pin "application"
pin "@hotwired/turbo-rails", to: "turbo.min.js"
pin "@hotwired/stimulus", to: "stimulus.min.js"
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js"
pin_all_from "app/javascript/controllers", under: "controllers"

# PDF.js (lazy-loaded in pdf_viewer_controller)
pin "pdfjs-dist", to: "https://cdn.jsdelivr.net/npm/pdfjs-dist@4.9.155/build/pdf.min.mjs", preload: false

# CodeMirror 6 for LaTeX editor (lazy-loaded)
pin "codemirror", to: "https://cdn.jsdelivr.net/npm/codemirror@6.0.1/dist/index.js"
pin "@codemirror/state", to: "https://cdn.jsdelivr.net/npm/@codemirror/state@6.4.1/dist/index.js"
pin "@codemirror/view", to: "https://cdn.jsdelivr.net/npm/@codemirror/view@6.34.3/dist/index.js"
pin "@codemirror/language", to: "https://cdn.jsdelivr.net/npm/@codemirror/language@6.10.8/dist/index.js"
pin "@codemirror/legacy-modes/mode/stex", to: "https://cdn.jsdelivr.net/npm/@codemirror/legacy-modes@6.4.2/mode/stex.js"
