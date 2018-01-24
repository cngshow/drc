import React from 'react';

class VsoMain extends React.Component {
    constructor() {
        super();
        this.state = {text: 'default text'};
        this.headerClickSwapText = this.headerClickSwapText.bind(this);
    }

    headerClickSwapText(channel, data) {
        console.log("channel is " + channel);
        this.setState({text: data.text});
    }

    componentDidMount() {
        PubSub.subscribe('HeaderClick', this.headerClickSwapText);
    }

    render () {

        return (
            <div className="kmain">
                <p>{this.state.text}</p>
            </div>
        )
    }
}

export default VsoMain;