import React from 'react';
import ReactDOM from 'react-dom';
import SimpleDialogDemo from './components/dialog/dialog'

export default class Application extends React.Component {
    constructor(props) {
        super(props);
    }

    render() {
        return (
            <SimpleDialogDemo />
        )
    }
}

document.addEventListener('DOMContentLoaded', () => {
    ReactDOM.render(
        <Application />, document.getElementById('app')
    )
});
