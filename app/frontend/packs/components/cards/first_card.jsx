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
                <h3>This is the Material-UI Dialog Card</h3>
                {/*this is the {this.props.id} card*/}
                <hr/>
                <SimpleDialog />
            </div>
        )
    }
}

export default First
