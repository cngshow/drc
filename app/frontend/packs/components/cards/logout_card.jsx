import React from 'react';

class Account extends React.Component {
    componentDidMount() {
        console.log(this.props.id + " is now mounted!");
    }

    componentWillUnmount() {
        console.log(this.props.id + " will unmount!");
    }

    render() {
        let style = {
            backgroundColor: 'red',
            width: '50%',
            height: '100%'
        };
        return (
            <div style={style}>
                this is the {this.props.id} card
            </div>
        )
    }
}

export default Account
