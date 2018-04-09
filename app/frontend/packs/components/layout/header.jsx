import React from 'react';
import Button from 'material-ui/Button';
import DrcMainMenu from '../header/drc_main_menu'
import axios from 'axios'
import GH from '../helpers/gon_helper'

class DrcHeader extends React.Component {
    swapText(btn) {
        axios.get(gon.routes.fetch_text_path, {
            params: {btn: btn}
        })
        .then(function (response) {
            console.log(response);
            PubSub.publish('HeaderClick', response.data);
        })
        .catch(function (error) {
            console.log(error);
        });
    }

    render () {
        return (
            <div className="kheader">
                <div className="inline_block">
                    <img src={GH.getImagePath('VA-header.png')} alt="VA Header Image"/>
                </div>
                <div className="inline_block">
                    <DrcMainMenu />
                </div>
                <div className="inline_block">
                    <Button raised="true" onClick={this.swapText.bind(this, 'hello')}>Axios Hello</Button>
                    <Button raised="true" onClick={this.swapText.bind(this, 'goodbye')}>Axios Goodbye</Button>
                </div>
            </div>
        )
    }
}

export default DrcHeader;