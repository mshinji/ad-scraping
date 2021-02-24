import consumer from './consumer'

consumer.subscriptions.create('ScrapingNotificationsChannel', {
  connected() {
    // Called when the subscription is ready for use on the server
  },

  disconnected() {
    // Called when the subscription has been terminated by the server
  },

  received(data) {
    // Called when there's incoming data on the websocket for this channel
    if (confirm(data['message'])) {
      window.location.href = data['url']
      return false
    } else {
      return false
    }
  },
  notice(message, url) {
    return this.perform('notice', {
      message: message,
    })
  },
})
