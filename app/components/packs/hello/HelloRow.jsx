import React from 'react';
import ReactDOM from 'react-dom'
import GoodbyeRow from '../goodbye/GoodbyeRow'
import JqxButton from 'jqwidgets-framework/jqwidgets-react/react_jqxbuttons'
// import JqxButton from 'jqwidgets-framework/jqwidgets/jqxcore'

export default class HelloRow extends React.Component {
    constructor(props) {
        super(props);
        console.log("in the constructor");
    }

    render() {
        console.log("we are in the render baby!");
        return (
            <div>
                <h1>{this.props.name}</h1>
                <GoodbyeRow name={this.props.name}/>
                <div>
                    <JqxButton ref='myButton' value='Button' width={120} height={40} />
                </div>
            </div>
        )
    }
}
document.addEventListener('DOMContentLoaded', () => {
    ReactDOM.render(
        <HelloRow name="cris and greg"/>,
        document.body.appendChild(document.createElement('div')),
    );
});
