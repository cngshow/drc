import React from 'react';
import Button from 'material-ui/Button';
import VsoMainMenu from '../header/vso_main_menu'
import { ButtonDropdown, DropdownToggle, DropdownMenu, DropdownItem } from 'reactstrap';

class VsoHeader extends React.Component {
    swapText() {
        fetch(gon.routes.fetch_text_path)
            .then(checkStatus)
            .then(parseJSON)
            .then(function (data) {
                PubSub.publish('HeaderClick', data);
            }).catch(function (error) {
            console.log('request failed', error)
        });
    }

    render () {
        return (
            <div className="kheader">
                <div className="inline_block">
                    <img src={img_path} alt="VA Header Image"/>
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