import { Controller } from "@hotwired/stimulus"
import consumer from "channels/consumer"

export default class extends Controller {
  static targets = ["badge"]

  connect() {
    this.channel = consumer.subscriptions.create(
      { channel: "NotificationChannel" },
      { received: this._onNotification.bind(this) }
    )
  }

  disconnect() {
    this.channel?.unsubscribe()
  }

  _onNotification(data) {
    if (data.type !== "new_notification") return

    const count = data.unread_count
    const display = count > 9 ? "9+" : count

    this.badgeTargets.forEach(el => {
      el.textContent = display
      el.classList.toggle("hidden", count === 0)
    })
  }
}
