import { Controller } from "@hotwired/stimulus"

const queue = []
let processing = false

function processQueue() {
  if (processing || queue.length === 0) return
  processing = true
  const { address, controller } = queue.shift()
  controller.fetchAndRender(address)
}

function enqueue(address, controller, delay = 0) {
  queue.push({ address, controller })
  if (queue.length === 1) {
    setTimeout(processQueue, delay)
  }
}

function dequeue(controller) {
  const idx = queue.indexOf(controller)
  if (idx > -1) queue.splice(idx, 1)
}

export default class extends Controller {
  static values = { address: String }

  connect() {
    this._loading = true
    this.renderLoading()
    enqueue(this.addressValue, this, this.index * 300)
  }

  disconnect() {
    dequeue(this)
    this.destroyMap()
  }

  get index() {
    if (!this.element.dataset.mapIndex) {
      this.element.dataset.mapIndex = document.querySelectorAll("[data-controller='branch-map']").length
    }
    return parseInt(this.element.dataset.mapIndex)
  }

  renderLoading() {
    this.element.innerHTML = `<div class="flex items-center justify-center h-full"><div class="w-5 h-5 border-2 border-orange-500 border-t-transparent rounded-full animate-spin"></div></div>`
  }

  fetchAndRender(address) {
    fetch(`https://nominatim.openstreetmap.org/search?format=json&q=${encodeURIComponent(address + ', Uruguay')}&limit=1`, {
      headers: { "Accept-Language": "es" }
    })
      .then(r => r.json())
      .then(data => {
        if (data && data.length > 0) {
          const lat = parseFloat(data[0].lat)
          const lon = parseFloat(data[0].lon)
          this.renderMap(lat, lon)
        } else {
          this.renderFallback(address)
        }
      })
      .catch(() => this.renderFallback(address))
      .finally(() => {
        processing = false
        setTimeout(processQueue, 1200)
      })
  }

  renderMap(lat, lon) {
    this._loading = false
    this.element.innerHTML = ""

    const mapEl = document.createElement("div")
    mapEl.style.width = "100%"
    mapEl.style.height = "100%"
    mapEl.style.borderRadius = "0.75rem"
    this.element.appendChild(mapEl)

    const map = L.map(mapEl, {
      zoomControl: false,
      attributionControl: false,
      scrollWheelZoom: false
    }).setView([lat, lon], 15)

    L.tileLayer("https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png", {
      maxZoom: 19
    }).addTo(map)

    L.marker([lat, lon]).addTo(map)
    this._map = map
  }

  renderFallback(address) {
    this._loading = false
    this.element.innerHTML = `<div class="flex items-center justify-center h-full px-3"><p class="text-gray-500 text-xs text-center truncate">${address}</p></div>`
  }

  destroyMap() {
    if (this._map) {
      this._map.remove()
      this._map = null
    }
  }
}
