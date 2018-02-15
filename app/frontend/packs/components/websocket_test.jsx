import React from 'react';
import WebSocketHelper from '../../packs/utilities/websocket'
import PubSub from 'pubsub-js'
import axios from 'axios'
import GH from '../components/helpers/gon_helper'

class WebsocketTest extends React.Component {
    constructor() {
        super();
        this.state = {post_msg: '', incoming_msg: ''}
        this.onmessage = this.onmessage.bind(this);
    }

    postMsg() {
        var msg = this.state.post_msg;
        console.log("msg is " + msg);
        let that = this;
        var setup = this.websocket.socket_setup

        axios({
            method: 'post',
            url: gon.routes.websocket_test_path,
            data: {post_msg: this.state.post_msg},
            headers: {
                ws_setup: JSON.stringify(setup)
            }
        })
            .then(function (response) {
                console.log('response data is', response.data);
            })
            .catch(function (error) {
                console.log(error);
            });


        this.setState({post_msg: ''});

    }

    handleChange(e) {
        this.setState({post_msg: e.target.value});
    }

    render() {
        return (
            <div className="">
                <input type="text" name="post_msg" value={this.state.post_msg} onChange={this.handleChange.bind(this)}/>
                <button onClick={this.postMsg.bind(this)}>Submit Msg</button>
                <hr/>
                <div>
                    <label htmlFor="incoming_msg">Last Incoming MSG</label>
                    <p>{this.state.incoming_msg}</p>
                </div>
            </div>
        )
    }

    onmessage(channel, msg) {
        console.log("received data on " + channel, msg);
        this.setState({incoming_msg: msg});
    }

    componentWillMount() {
    }

    componentDidMount() {
        PubSub.subscribe(this.props.ps_channel, this.onmessage);
        this.websocket = new WebSocketHelper(this.props.ws_channel, this.props.ps_channel);
    }

    componentWillUpdate(nextProps, nextState) {
    }

    componentDidUpdate(prevProps, prevState) {
    }

    componentWillUnmount() {
    }
}

export default WebsocketTest
