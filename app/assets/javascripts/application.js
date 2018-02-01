// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, or any plugin's
// vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file. JavaScript code in this file should be added after the last require_* statement.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require rails-ujs
//= require turbolinks
//= require_tree .
if ("WebSocket" in window) {
    alert("WebSocket is supported by your Browser!");

    // Let us open a web socket
    var ws = new WebSocket("ws://localhost:8090/websocket/rails");

    ws.onopen = function () {
        // Web Socket is connected, send data using send()
        ws.send("Message to send");
        console.log("Message is sent...");
    };

    ws.onmessage = function (evt) {
        var received_msg = evt.data;
        console.log("Message is received..." + received_msg);
    };

    ws.onclose = function () {
        // websocket is closed.
        console.log("Connection is closed...");
    };

    window.onbeforeunload = function (event) {
        ws.close();
    };
}

else {
    // The browser doesn't support WebSocket
    alert("WebSocket NOT supported by your Browser!");
}