import PubSub from 'pubsub-js'


class WebSocketHelper {
    constructor(channel) {
        this.channel = channel;
        //this.websocket = new WebSocket(gon.websocket_endpoint_url);
        this.websocket = new WebSocket('ws://localhost:8090/websocket/rails');
        this.chat = this.chat.bind(this);
        this.websocket.onopen = this.onopen.bind(this);
        this.websocket.onmessage = this.onmessage.bind(this);
        this.websocket.onclose = this.onclose.bind(this);
        this.close = this.close.bind(this);
    }

    onopen() {
        console.log("onopen");
    }

    onmessage(evt) {
        console.log("onmessage");
        PubSub.publish(this.channel, evt.data)
    }

    onclose() {
        console.log("onclose");
    }

    close() {
        this.websocket.close();
    }

    chat(msg){
        console.log("I would talk on ", this.channel);
        this.websocket.send(msg);
    };
}
export default WebSocketHelper;