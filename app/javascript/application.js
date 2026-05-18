// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"
import "chartkick"
import "Chart.bundle"

window.addEventListener("beforeunload", (event) => {
  // Attempt to notify the server about the user's logout when the page unloads.
  // Be defensive: don't throw if the CSRF meta tag is missing, and swallow errors.
  try {
    const meta = document.querySelector('meta[name="csrf-token"]')
    if (!meta) return
    const token = meta.getAttribute("content")
    if (!token) return

    // Use fetch with keepalive for best compatibility. Some browsers support
    // navigator.sendBeacon but it doesn't allow DELETE; use fetch as a fallback.
    fetch("/logout", {
      method: "DELETE",
      headers: {
        "X-CSRF-Token": token,
        "Content-Type": "application/json"
      },
      keepalive: true
    }).catch(() => {
      // Ignore failures during unload — nothing useful we can do here.
    })
  } catch (e) {
    // Swallow errors during unload to avoid interfering with navigation.
  }
})
