import React from 'react';
import Button from 'material-ui/Button';
import ChildButton from './child'
import ListenButton from './listener'

export default class ParentButton extends React.Component {
    constructor(props) {
        super(props);
        this.state = {children: ['brother', 'sister', 'cousin'], child_data: {}}
        this.state.click_count = 0
        //this.childrenString = this.childrenString.bind(this);
        this.childListen = this.childListen.bind(this);
        this.parentClick = this.parentClick.bind(this);
    }

    parentClick(){
        console.log("Clicked!!!")
        console.log("Children are ", this.state.children)
        const clickCount = this.state.click_count + 1
        this.setState({
            click_count: clickCount
        })
        PubSub.publish('Dad count', clickCount)
    };

    children_buttons_to_html(data) {
        let result = [];
        for (let button of data) {
            result.push(<ChildButton name={button} key={button} children={this.state.children}/>)
        }
        result.push(<ListenButton name={'listen'} key={'listen'}/>)
        return result
    }

    childListen(channel, data) {
        console.log("child m", channel)//Dad count
        console.log("child d ", data)//count (like 1)
        let child_data = this.state.child_data
        child_data[channel] = data
        this.setState(child_data)
    }


    childrenString() {
        let s = ''
        console.log('this.state.child_data', this.state.child_data)
        for (let key of Object.keys(this.state.child_data)) {
            console.log('Cris', key)
            let val = this.state.child_data[key]
            console.log('Cris2', val)
            s = s + ' : ' + key + '::' + val + '; '
        }
        return s
    }

    componentDidMount() {
        let result = [];
        for (let child of this.state.children) {
            PubSub.subscribe(child, this.childListen);
        }
    }

    render() {
        return (
            <div>
                <Button raised
                    onClick={this.parentClick}>Dad {this.state.click_count} {this.childrenString()}
                </Button>
                {console.log("Rendering main")}
                {this.children_buttons_to_html(this.state.children)}
            </div>
        )
    }
}