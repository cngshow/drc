import React from 'react';
import SimpleDialog from '../dialog/dialog'

class First extends React.Component {
    componentDidMount() {
        console.log(this.props.id + " is now mounted!");
    }

    componentWillUnmount() {
        console.log(this.props.id + " will unmount!");
    }

    render() {
        return (
            <div className="">
                this is the {this.props.id} card
                <hr/>
                <SimpleDialog />
            </div>
        )
    }
}

export default First
