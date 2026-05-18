import { Controller } from "@hotwired/stimulus"
import consumer from "channels/consumer"

export default class extends Controller {
  static targets = ["messages"]
  static values = { conversationId: Number }

  connect() {
    this.channel = consumer.subscriptions.create(
      { channel: "ChatChannel", id: this.conversationIdValue },
      { received: this._onMessage.bind(this) }
    )
  }

  disconnect() {
    this.channel?.unsubscribe()
  }

  _onMessage(data) {
    if (data.type !== "new_message") return

    const container = this.messagesTarget
    if (!container) return

    if (document.getElementById(`message-${data.message_id}`)) return

    const empty = container.querySelector(".flex-1.flex.items-center.justify-center")
    empty?.remove()

    container.insertAdjacentHTML("beforeend", data.html)
    container.scrollTop = container.scrollHeight
  }
}
