import React from 'react';

export default class GoodbyeRow extends React.Component {
    constructor(props) {
        super(props);
    }

    render() {
        return (
            <div>See you later!!!! {this.props.name}</div>
        )
    }

}