import React from 'react';
import First from '../cards/first_card'
import Account from '../cards/account_card'
import Logout from '../cards/logout_card'
import ShowHeaders from '../cards/show_headers_card'

class DrcMain extends React.Component {
    constructor() {
        super();
        this.state = {
            card: 'default card'
        };
        this.headerClickSwapText = this.headerClickSwapText.bind(this);
    }

    headerClickSwapText(channel, data) {
        console.log("data is ", data);
        this.setState({card: data.text});
    }

    shouldComponentUpdate (nextProps, nextState) {
        return this.state.card !== nextState.card;
    }

    componentDidMount() {
        PubSub.subscribe('HeaderClick', this.headerClickSwapText);
    }

    render () {
        let active_card = this.state.card;
        let curr = new Date().getTime();
        console.log("active card will be " + active_card);
        let cards = {
            first: <First id="first"/>,
            account: <Account id="account"/>,
            logout: <Logout id="logout"/>,
            show_headers: <ShowHeaders id="show_headers"/>,
        };

        return (
            <div className="kmain">
                load time is {curr}
                <br/>
                {(active_card in cards) ? cards[active_card] : 'Invalid Card Id passed: ' + active_card}
            </div>
        )
    }
}

export default DrcMain;