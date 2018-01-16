import React from 'react';
import ReactDOM from 'react-dom';
import ParentButton from './buttons/parent'
import PubSub from 'pubsub-js'

export default class Application extends React.Component {
    constructor(props) {
        super(props);
    }

    render() {
        return (
            <ParentButton />
        )
    }
}

document.addEventListener('DOMContentLoaded', () => {
    ReactDOM.render(
        <Application />, document.getElementById('app')
    )
});
