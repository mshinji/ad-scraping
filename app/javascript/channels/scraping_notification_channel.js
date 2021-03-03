import consumer from "./consumer";

consumer.subscriptions.create("ScrapingNotificationChannel", {
  connected() {
    // Called when the subscription is ready for use on the server
  },

  disconnected() {
    // Called when the subscription has been terminated by the server
  },

  received(data) {
    // Called when there's incoming data on the websocket for this channel
    console.log(data);
    $('.scraping-button[data-id="' + data.id + '"]').removeClass(
      "disabled loading"
    );
    if (confirm(data.message)) {
      window.location.href = data.url;
      return false;
    } else {
      return false;
    }
  },
});
