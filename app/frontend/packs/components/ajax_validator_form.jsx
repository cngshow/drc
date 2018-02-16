import React from 'react';
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
        this.setState({[event.target.name]: event.target.value});
    }

    reset() {
        let reset_state = {};

        Object.keys(this.state).forEach(function(key) {
            reset_state[key] = '';
        });

        this.setState(reset_state);
        this.initFocus();
    }

    handleSubmit(e) {
        e.preventDefault();
        let that = this;
        let data = this.toJSONString();
        let addl_headers = this.props.addlHeaders() || {};

        axios({
            method: 'post',
            url: this.props.action_path,
            data: data,
            headers: addl_headers
        })
        .then(function (response) {
            console.table(response.data);
            that.props.onsuccess(response.data);
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
        const inputs = form.childs;

        for(let i = 0; i < inputs.length; ++i ) {
            obj[ inputs[i].props.name ] = inputs[i].props['value'];
        }
        return obj;
    }

    initFocus() {
        let g = document.getElementById(this.props.formName + '_' + this.props.focus);
        if (g) { g.focus() }
    }

    componentDidMount() {
        this.initFocus();
    }

    render() {
        let children = React.Children.map(this.props.children, child => {
            return React.cloneElement(child, {
                id: this.props.formName + '_' + child.props.name,
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
