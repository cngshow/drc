import React from 'react';
import Button from 'material-ui/Button';
import PropTypes from 'prop-types';
import { withStyles } from 'material-ui/styles';

class VsoHeader extends React.Component {
    swapText() {
        fetch("/fetch_text/fetch_text")
            .then(checkStatus)
            .then(parseJSON)
            .then(function (data) {
                console.log('request succeeded with JSON response', data);
                PubSub.publish('HeaderClick', data);
            }).catch(function (error) {
            console.log('request failed', error)
        });
    }

    render () {
        return (
            <div className="kheader">
                <img src={img_path} alt="VA Header Image"/>
                <div className="right">
                    <Button onClick={this.swapText.bind(this)}>hello</Button>
                </div>
            </div>
        )
    }
}

export default VsoHeader;