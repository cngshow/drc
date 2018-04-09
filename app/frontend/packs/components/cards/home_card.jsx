import React from 'react';

class Home extends React.Component {
    componentDidMount() {
        console.log(this.props.id + " is now mounted!");
    }

    componentWillUnmount() {
        console.log(this.props.id + " will unmount!");
    }

    render() {
        let axios_string = '';

        if (this.props.axios != undefined) {
            axios_string = 'axios returned ' + this.props.axios;
        }
        return (
            <div className="">
                this is the {this.props.id} card
                <br/>
                {axios_string}
            </div>
        )
    }
}

export default Home
