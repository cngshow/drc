import React from 'react';
import Button from 'material-ui/Button';
import { TextValidator, ValidatorForm } from 'react-material-ui-form-validator';

export default class MyForm extends React.Component {

    constructor(props) {
        super(props);
        this.state = {};
        this.handleChange = this.handleChange.bind(this);
    }

    handleChange(event) {
        const email = event.target.value;
        this.setState({email});
    }

    handleSubmit() {
        // your submit logic
    }
    render() {
        const { email } = this.state;
        return (
            <ValidatorForm
                ref="form"
                onSubmit={this.handleSubmit}
                onError={errors => console.log(errors)}
            >
                <TextValidator
                    floatingLabelText="Email"
                    onChange={this.handleChange}
                    name="email"
                    value={email}
                    validators={['required', 'isEmail']}
                    errorMessages={['this field is required', 'email is not valid']}
                />
                <Button type="submit" >Billy</Button>
            </ValidatorForm>
        );
    }
}