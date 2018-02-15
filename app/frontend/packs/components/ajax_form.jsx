import React from 'react';
import ReactDOM from 'react-dom';
import axios from 'axios'

class AjaxForm extends React.Component {
    constructor() {
        super();
        // this.resetForm = this.resetForm.bind(this);
        // this.submitForm = this.submitForm.bind(this);
        //
        // this.state = {
        //     inputs: [],

    // }
    }

    componentWillMount() {
    }

/*
    changedz(e) {
        let inputs = this.state.inputs;
        let idx = 0;
        for (let i = 0; i < inputs.length; i++) {
            if (inputs[i]['id'] === e.target.id) {
                idx = i;
            }
        }

        inputs[idx]['value'] = e.target.value;
        this.setState({inputs: inputs});
    }
*/

/*
    resetForm() {
        console.log("reset");
        React.Children.map(this.props.children, child => {
            console.log("resetting child ", child);
            child.value = '';
        })
    }
*/

    handleChange = event => {
        console.log("form changing...");
        this.setState({ [event.target.name]: event.target.value });
    };

    changeHandler(e) {
        console.log("change handler in parent form");
    }

    submitForm(e) {
        e.preventDefault();
        let that = this;
        let form = this.refs[this.props.form_name];
        let data = this.toJSONString(form);
        let data2 = this.state;
/*

        console.log("====================== json is ", j);
        let data = {};
        let reset_inputs = []
        this.state.inputs.forEach(function(input) {
            data[input.id] = input.value;
            let reset_input = input;
            reset_input.value = '';
            reset_inputs.push(reset_input);
        });
*/

        axios({
            method: 'post',
            url: this.props.action_path,
            data: data
            })
            .then(function (response) {
                console.log('response data is', response.data);
                that.props.onsuccess(response.data);
                form.reset();
                that.initFocus();

                // that.setState({inputs: reset_inputs});
            })
            .catch(function (error) {
                console.log(error);
                that.props.onerror(error);
            });
    }

    render() {
        return (
            <div className="">
                <form ref={this.props.form_name} onSubmit={(e) => this.submitForm(e)} onChange={(e) => this.handleChange(e)} >
                    {this.props.children}
                </form>
            </div>
        )
    }

    toJSONString( form ) {
        const obj = {};
        const elements = form.querySelectorAll("input, select, textarea");
        for(let i = 0; i < elements.length; ++i ) {
            const element = elements[i];
            const name = element.name;
            const value = element.value;

            if( name ) {
                obj[ name ] = value;
            }
        }

        return obj;
    }

    initFocus() {
        let form = this.refs[this.props.form_name];
        let input = this.props.focus;
        const elements = form.querySelectorAll("input, select, textarea");

        for(let i = 0; i < elements.length; ++i ) {
            const element = elements[i];
            const id = element.name;

            if( id === input) {
                element.focus();
                return true;
            }
        }
    }

    componentDidMount() {
        this.initFocus();
    }

    /*
    componentDidMount() {
        let inputs = [];
        React.Children.map(this.props.children, (child, index) => {

            console.log("has children? " + child.props.children);
            if (child.props.children !== undefined && child.props.children instanceof Object ) { //Array.isArray(child.props.children)) {
                console.log("we got some...");
            }
            // console.log("child ", child);
            // if (child.type === 'input' ||  child.props.inputProps) {
                if (child.props.id) {
                let input = {};
                input['id'] = child.props.id;
                input['value'] = '';
                inputs.push(input);
            }
        });
        console.log("initial data is ", JSON.stringify(inputs));
        this.setState({inputs: inputs})
    }
*/

    componentWillReceiveProps(nextProps) {
    }

    componentWillUpdate(nextProps, nextState) {

    }

    componentDidUpdate(prevProps, prevState) {
        console.log("updated...", this.state);

    }

    componentWillUnmount() {
    }
}

export default AjaxForm
