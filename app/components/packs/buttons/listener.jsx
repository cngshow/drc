import React from 'react';
import Button from 'material-ui/Button';

export default class ListenButton extends React.Component {
    constructor(props) {
        super(props);
        this.state = {message: 'Nothing yet!'}
        this.notified = this.notified.bind(this);
    }

    notification(data) {
        console.log(data)
    }

    onClick() {
        console.log("Clicked!!!", App.web_notifications)
    };

    componentDidMount() {
        PubSub.subscribe('WebNotificationsChannel', this.notified);
    }

    notified(channel, data) {
        console.log("Event m", channel)//Dad count
        console.log("Event d ", data)//count (like 1)
        this.setState({message: data.message})
    }



    render() {
        {
            console.log("I am a child rendering")
        }
        return (
            <Button
                onClick={this.onClick}>Listener {this.state.message}
            </Button>
        )
    }

}