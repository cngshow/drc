import React from 'react';
import WebsocketChat from '../../components/websocket_chat';

class Account extends React.Component {
    componentDidMount() {
        console.log(this.props.id + " is now mounted!");
    }

    componentWillUnmount() {
        console.log(this.props.id + " will unmount!");
    }

    render() {
        let style = {
            backgroundColor: 'cornsilk'
        };
        return (
            <div style={style}>
                this is the {this.props.id} card
                <WebsocketChat />
            </div>
        )
    }
}

export default Account
