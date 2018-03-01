import React from 'react';
import ReactDOM from 'react-dom';
import SimpleDialogDemo from './components/dialog/dialog'
import DrcHeader from './components/layout/header'
import DrcFooter from './components/layout/footer'
import DrcMain from './components/layout/main'
import DrcAppBar from './drc_app_bar'
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
                <DrcHeader className="kheader"/>
                <DrcMain className="kmain"/>
                <DrcFooter className="kfooter"/>
            </div>
        )
    }
}

document.addEventListener('DOMContentLoaded', () => {
    ReactDOM.render(<Application />, document.getElementById('app'));
});


window.axios = require('axios');

window.axios.defaults.headers.common = {
    'X-Requested-With': 'XMLHttpRequest',
    'X-CSRF-TOKEN' : document.querySelector('meta[name="csrf-token"]').getAttribute('content')
};
