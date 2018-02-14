import PubSub from 'pubsub-js'

const guid=()=> {
    const s4=()=> Math.floor((1 + Math.random()) * 0x10000).toString(16).substring(1);
    return `${s4() + s4()}-${s4()}-${s4()}-${s4()}-${s4() + s4() + s4()}`;
}

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
        this.setup = false;
        this.socket_setup = {'broadcast_channel_setup': this.channel, uuid: gon.uuid, client_uid: guid()} //todo, bind this string to ruby code via irb somewhere.
    }

    onopen() {
        if ((this.socket_setup != null) && !this.setup) {
            try {
                this.websocket.send(JSON.stringify(this.socket_setup));
                this.setup = true; //Do we need to do this?  Is onOpen called for every message sent?
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