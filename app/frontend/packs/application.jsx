import React from 'react';
import ReactDOM from 'react-dom';
import SimpleDialogDemo from './components/dialog/dialog'
import VsoHeader from './components/header/header'
import VsoFooter from './components/layout/footer'
import VsoMain from './components/layout/main'
import PubSub from 'pubsub-js'




export default class Application extends React.Component {
    constructor(props) {
        super(props);
    }

    render() {
        return (
            <div>
                <VsoHeader className="kheader"/>
                <VsoMain className="kmain"/>
                <VsoFooter className="kfooter"/>
            </div>
        )
    }
}

document.addEventListener('DOMContentLoaded', () => {
    ReactDOM.render(<Application />, document.getElementById('app'));
});
