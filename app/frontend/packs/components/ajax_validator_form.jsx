import React from 'react';
import ReactDOM from 'react-dom'
import { ValidatorForm } from 'react-material-ui-form-validator';
import axios from 'axios'

class AjaxValidatorForm extends React.Component {

    constructor(props) {
        super(props);
        this.state = {};
        this.handleChange = this.handleChange.bind(this);
        this.handleSubmit = this.handleSubmit.bind(this);
        this.reset = this.reset.bind(this);
    }

    handleChange(event) {
        let v = event.target.value;
        this.setState({[event.target.name]: v});
    }

    reset() {
        let reset_state = {};
        let form = this.refs[this.props.formName];

        Object.keys(this.state).forEach(function(key) {
            reset_state[key] = '';
        });

        this.setState(reset_state);
        form.resetValidations();
    }

    handleSubmit(e) {
        e.preventDefault();
        let that = this;
        let form = this.refs[this.props.formName];
        let data = this.toJSONString();
        axios({
            method: 'post',
            url: this.props.action_path,
            data: data
        })
        .then(function (response) {
            console.log('response data is', response.data);
            that.props.onsuccess(response.data);
            // that.setState({email: null, cris: null});
            // resetValidations built in function with <FormValidator>
            // TODO: isolate "state" of form inputs in order to not delete ALL state
            that.reset();
        })
        .catch(function (error) {
            console.log(error);
            that.props.onerror(error);
        });

    }

    toJSONString() {
        const obj = {};
        let form = this.refs[this.props.formName];
        // let form = this._inputForm;
        // return obj;

        const inputs = form.childs;

        for(let i = 0; i < inputs.length; ++i ) {
            obj[ inputs[i].props.name ] = inputs[i].props['value'];
        }
        return obj;
    }

    initFocus() {
        // console.log("form name is " + this.props.formName);
        // let form = this.refs[this.props.formName];
        // console.log("form refs is ", form.childs);
        // form.childs[0].focus();
        return false;

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

    render() {
        let children = React.Children.map(this.props.children, child => {
            let refName = child.props.name;
            console.log("child ref name is " + refName);
            return React.cloneElement(child, {
                ref: refName,
                value: this.state[child.props.name] || ''
            });
        });
        return (
            <div>
                <ValidatorForm
                    ref={this.props.formName}
                    onSubmit={(e) => this.handleSubmit(e)}
                    onChange={(e) => this.handleChange(e)}
                    onError={errors => console.log(errors)}
                >
                    {children}
                </ValidatorForm>
            </div>
        );
    }
}

export default AjaxValidatorForm
