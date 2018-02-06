import React from 'react';
import ReactDOM from 'react-dom';
import SimpleDialogDemo from './components/dialog/dialog'
import VsoHeader from './components/layout/header'
import VsoFooter from './components/layout/footer'
import VsoMain from './components/layout/main'
import VsoAppBar from './vso_app_bar'
import AppHeaderBar from './components/header/app_header_bar'

import PubSub from 'pubsub-js'
import fontawesome from '@fortawesome/fontawesome'


// fix for IE11 allowing us to use axios/fetch for ajax calls
import { promise, polyfill } from 'es6-promise'; polyfill();
import faCoffee from '@fortawesome/fontawesome-free-solid/faCoffee'
import faCheckSquare  from '@fortawesome/fontawesome-free-solid/faCheckSquare'
fontawesome.library.add(faCoffee, faCheckSquare);

export default class Application extends React.Component {
    constructor(props) {
        super(props);
    }

    render() {
        return (
            <div>
                {/*<AppHeaderBar/>*/}
                {/*<hr/>*/}
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
