import React from 'react';
import WebsocketTest from '../../components/websocket_test';

class Account extends React.Component {
    componentDidMount() {
        console.log(this.props.id + " is now mounted!");
        document.getElementById('rootbeer_post_msg').focus();
    }

    componentWillUnmount() {
        console.log(this.props.id + " will unmount!");
    }

    render() {
        let style = {
            // backgroundColor: 'cornsilk'
        };
        return (
            <div style={style}>
                {/*this is the {this.props.id} card*/}
                <h3>Root Beer (ws_channel: root_beer / ps_channel: rootbeer_test) with AjaxValidatorForm</h3>
                <WebsocketTest id="rootbeer" ps_channel="rootbeer_test" ws_channel={gon.websocket_channel.ROOT_BEER}/>
                <br/>
                <br/>
                <br/>
                <br/>
                <h3>Coke (ws_channel: coke / ps_channel: coke_test) with AjaxValidatorForm</h3>
                <WebsocketTest id="coke" ps_channel="coke_test" ws_channel={gon.websocket_channel.COKE}/>
            </div>
        )
    }
}

export default Account
