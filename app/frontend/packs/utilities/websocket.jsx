import PubSub from 'pubsub-js'

class WebSocketHelper {
    constructor(channel = null) {
        this.channel = channel;
        this.websocket = new WebSocket(gon.websocket_endpoint_url);
        // this.websocket = new WebSocket('ws://localhost:8090/websocket/rails');
        this.chat = this.chat.bind(this);
        this.websocket.onopen = this.onopen.bind(this);
        this.websocket.onmessage = this.onmessage.bind(this);
        this.websocket.onclose = this.onclose.bind(this);
        this.close = this.close.bind(this);
        this.channeled = false;
    }

    onopen() {
        if ((this.channel != null) && !this.channeled) {
            try {
                let socket_setup = {'broadcast_channel_setup': this.channel} //todo, bind this string to ruby code via irb somewhere.
                this.websocket.send(JSON.stringify(socket_setup));
                this.channeled = true; //Do we need to do this?  Is onOpen called for every message sent?
            }
            catch (err){
                console.log("I could not register this websocket against " + this.channel);
                console.log("Error is", err);
            }
        }
        console.log("onopen");
    }

    onmessage(evt) {
        console.log("onmessage", evt);
        PubSub.publish(this.channel, evt.data);
    }

    onclose() {
        console.log("onclose");
    }

    close() {
        this.websocket.close();
    }

    chat(msg) {
        console.log("I would talk on ", this.channel);
        this.websocket.send(msg);
    };
}

export default WebSocketHelper;