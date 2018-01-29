import React from 'react';
import Button from 'material-ui/Button';
import VsoMainMenu from '../header/vso_main_menu'
import axios from 'axios'
import GH from '../helpers/gon_helper'

class VsoHeader extends React.Component {
    swapText(btn) {
        axios.get(GH.getRoute('fetch_text_path'), {
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
                    <VsoMainMenu />
                </div>
                <div className="inline_block">
                    <Button raised onClick={this.swapText.bind(this, 'hello')}>hello</Button>
                    <Button raised onClick={this.swapText.bind(this, 'goodbye')}>goodbye</Button>
                </div>
            </div>
        )
    }
}

export default VsoHeader;