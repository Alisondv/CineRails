import { Controller } from "@hotwired/stimulus"

// Stimulus: liga comportamento JS a um HTML que já existe.
// Qualquer elemento com data-controller="autohide" some sozinho depois de 3s.
// (Funciona também para mensagens que chegam via Turbo Stream.)
export default class extends Controller {
  connect() {
    this.timeout = setTimeout(() => this.element.remove(), 3000)
  }

  disconnect() {
    clearTimeout(this.timeout)
  }
}
