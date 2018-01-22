import React from 'react';
import Button from 'material-ui/Button';


export default class ChildButton extends React.Component {
    constructor(props) {
        super(props);
        this.state = {dad_count: '', peers: {}, children: this.props.children}
        this.dadListen = this.dadListen.bind(this);
        this.peerListen = this.peerListen.bind(this);
        this.childClick = this.childClick.bind(this);
      //  this.peerString = this.peerString.bind(this);
        this.state.click_count = 0
    }

    childClick(){
        console.log("Clicked!!!")
        console.log("I am ", this.props.name)
        const clickCount = this.state.click_count + 1
        this.setState({
            click_count: clickCount,
        })
        PubSub.publish(this.props.name, clickCount)
    };

    dadListen(channel, data) {
        console.log("Event m", channel)//Dad count
        console.log("Event d ", data)//count (like 1)
        this.setState({dad_count: data})
    }

    peerListen(channel, data) {
        console.log("peer m", channel)//Dad count
        console.log("peer d ", data)//count (like 1)
        let peers = this.state.peers
        peers[channel] = data
        this.setState(peers)
    }

    componentDidMount() {
        PubSub.subscribe('Dad count', this.dadListen);
        let result = [];
        for (let child of this.state.children) {
            if (child !== this.state.name) {
                PubSub.subscribe(child, this.peerListen);
            }
        }
    }

    peerString() {
        let s = ''
        console.log('this.state.peers', this.state.peers)
        for (let key of Object.keys(this.state.peers)) {
            console.log('Cris', key)
            let val = this.state.peers[key]
            console.log('Cris2', val)
            s = s + ' : ' + key + '::' + val + '; '
        }
        return s
    }

    render() {
        {
            console.log("I am a child rendering")
        }
        return (
            <Button
                onClick={this.childClick}>{this.props.name} {'DC ' + this.state.dad_count.toString()} {this.peerString()}
            </Button>
        )
    }

}