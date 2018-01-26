import React from 'react';
import Button from 'material-ui/Button';
import VsoMainMenu from '../header/vso_main_menu'
import axios from 'axios'

class VsoHeader extends React.Component {
    swapText(args) {
        axios.get(getRoute('fetch_text_path'), {
            params: {}
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
                    <img src={getImagePath('VA-header.png')} alt="VA Header Image"/>
                </div>
                <div className="inline_block">
                    <VsoMainMenu />
                </div>
                <div className="inline_block">
                    <Button raised onClick={this.swapText.bind(this)}>hello</Button>
                    <Button raised onClick={this.swapText.bind(this)}>goodbye</Button>
                </div>
            </div>
        )
    }
}

export default VsoHeader;