import React from 'react';
import WebSocketHelper from '../../packs/utilities/websocket'
import PubSub from 'pubsub-js'
import AjaxValidatorForm from '../components/ajax_validator_form'
import { TextValidator } from 'react-material-ui-form-validator';
import Button from 'material-ui/Button';

class WebsocketTest extends React.Component {
    constructor() {
        super();
        this.state = {incoming_msg: ''};
    }

    onsuccess(data) {
        console.table(data);
    }

    onerror(response) {
        console.log("onerror callback with response", JSON.stringify(response));
    }

    addlHeaders() {
        let setup = this.websocket.socket_setup;
        return { ws_setup: JSON.stringify(setup)};
    }

    onmessage = (channel, msg) => {
        console.log("received data on " + channel, msg);
        this.setState({incoming_msg: msg});
    };

    componentDidMount() {
        PubSub.subscribe(this.props.ps_channel, this.onmessage);
        this.websocket = new WebSocketHelper(this.props.ws_channel, this.props.ps_channel);
    }

    render() {
        return (
            <div className="">
                <AjaxValidatorForm formName={this.props.id}
                                   action_path={gon.routes.websocket_test_url}
                                   onsuccess={this.onsuccess.bind(this)}
                                   onerror={this.onerror.bind(this)}
                                   addlHeaders={this.addlHeaders.bind(this)}
                                   focus="post_msg" >
                    <TextValidator
                        label="Msg"
                        name="post_msg"
                        validators={['required']}
                        errorMessages={['this field is required']}
                    />
                    <Button raised="true" type="submit">Submit</Button>
                </AjaxValidatorForm>
                <hr/>
                <div>
                    <label htmlFor="incoming_msg">Last Incoming MSG</label>
                    <p>{this.state.incoming_msg}</p>
                </div>
            </div>
        )
    }
}

export default WebsocketTest
