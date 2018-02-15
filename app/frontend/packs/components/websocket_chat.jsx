import React from 'react';
import ReactDOM from 'react-dom';
import PropTypes from 'prop-types';
import { withStyles } from 'material-ui/styles';
import TextField from 'material-ui/TextField';
import Button from 'material-ui/Button';
import WebSocketHelper from '../../packs/utilities/websocket'
import PubSub from 'pubsub-js'
import MyForm from '../components/crap'
import AjaxForm from '../components/ajax_form'
import AjaxValidatorForm from '../components/ajax_validator_form'
import { TextValidator } from 'react-material-ui-form-validator';

import GH from '../components/helpers/gon_helper'
import Select from 'material-ui/Select';
import { FormControl, FormLabel, FormControlLabel, FormHelperText } from 'material-ui/Form';
import Input, { InputLabel } from 'material-ui/Input';
import Radio, { RadioGroup } from 'material-ui/Radio';
const styles = theme => ({
    container: {
        display: 'flex',
        flexWrap: 'wrap',
    },
    textField: {
        marginLeft: theme.spacing.unit,
        marginRight: theme.spacing.unit,
        width: 200,
    },
    formControl: {
        margin: theme.spacing.unit *2,
        minWidth: 120,
    },
    group: {
        margin: `${theme.spacing.unit}px 0`,
    },
});

const Message2 = (props) => {
    return (
        <li><p>{props.username}: {props.content}</p></li>
    )
};

export class Message extends React.Component {
    constructor(props) {
        super(props);
        this.props = {id: null, username: '', content: ''}
    }

    render() {
        return (
            <li key={this.props.id}>
                <p>{this.props.username}: {this.props.content}</p>
            </li>
        )
    }
}
/*
const Message = ({chat, user}) => (
    <li>
        {chat.user}: {chat.content}
    </li>
);

export default Message;z
*/

class WebsocketChat extends React.Component {
     constructor(props) {
        super(props);

        this.state = {
            chats: [],
            form: {}
        };
        this.submitMessage = this.submitMessage.bind(this);
        this.onmessage = this.onmessage.bind(this);
        // this.buddy = this.buddy.bind(this);
    }

    onmessage(channel, msg) {
         console.log("received data on " + channel, msg);
        this.setState({
            chats: this.state.chats.concat([{ id: new Date().getTime(), user: "kevin", content: msg }])
        });

    }

    componentWillUpdate(nextProps, nextState) {
        console.log("component will update!!!");
    }

    componentDidMount() {
        PubSub.subscribe('myChannel', this.onmessage);
        this.websocket = new WebSocketHelper(gon.websocket_channel.ROOT_BEER, 'myChannel');
    }

    submitMessage(e) {
        e.preventDefault();
        let msg_ref = this.msg;
        this.websocket.chat(msg_ref.value);
        msg_ref.value = "";
        msg_ref.focus();
    }

    componentWillUnmount() {
        this.websocket.close();
    }

    buddy(e) {
         console.log("buddy is ", e.target.id);
         let doc = this.state.form;
         let key = e.target.id;
         doc[key] = e.target.value;
         this.setState(doc);
         console.log("form is ", this.state.form);
    }

/*
    resetForm() {
         this.setState({form: {}});
    }
*/

    /*checkChildren() {
         let f = this.refs._form;
         console.log("form is ", f);
        let msg_ref = this.msg;
        console.log("msg is ", msg_ref.value);
         let c = React.Children.map(this.props.children,  child => {
             console.log("form children are ", child);
         });

    }*/

    onsuccess(data) {
        console.log("in success callback with data ", JSON.stringify(data));
    }

    onerror(response) {
        console.log("onerror callback with response", JSON.stringify(response));
    }

    render() {
        const username = 'Greg';
        const { classes } = this.props;
        const { chats }= this.state;

        return (
            <div className="chatroom">
                <h3>Chilltime</h3>
                <ul className="chats" ref="chats">
                    {
                        chats.map((chat, idx) => {
                            // return <Message2 key={idx} username={chat.user} content={chat.content}/>;
                            return <li key={chat.id}><p>{chat.user}: {chat.content}</p></li>;
                        })
                    }
                </ul>
                <form ref="_form" className="input" onSubmit={(e) => this.submitMessage(e)}>
                    <TextField
                        id="msg"
                        // name="msg"
                        label="Enter your comment"
                        className={classes.textField}
                        // value={this.state.form.msg}
                        inputProps={{ref: node => this.msg = node}}
                        onChange={this.buddy.bind(this)}
                        margin="normal"
                    />

                    <Button raised="true" type="submit">Submit</Button>
                    {/*<Button raised=true type="button" onClick={this.checkChildren.bind(this)}>Check Children</Button>*/}
                </form>
                <MyForm/>

                <AjaxForm form_name="greg" action_path={GH.getRoute('submit_form_path')} onsuccess={this.onsuccess.bind(this)} onerror={this.onerror.bind(this)} focus="age-native-simple">
                    <TextField
                        name="bowman"
                        label="Last Name"
                        className={classes.textField}
                        // value={this.state.form.msg}
                        inputProps={{ref: node => this.bowman = node}}
                        // onChange={this.handleChange.bind(this)}
                        margin="normal"
                    />
                    <FormControl className={classes.formControl}>
                        <InputLabel htmlFor="age-native-simple">Age</InputLabel>
                        <Select
                            name="age-native-simple"
                            native
                            // value={10}
                            // onChange={this.handleChange('age')}
                            /*inputProps={{
                                id: 'age-native-simple',
                            }}
                            */
                        >
                            <option value=""/>
                            <option value={10}>Ten</option>
                            <option value={20}>Twenty</option>
                            <option value={30}>Thirty</option>
                        </Select>
                    </FormControl>
                    {/*<TextField*/}
                        {/*id="textarea1"*/}
                        {/*hintText="MultiLine with rows: 2 and rowsMax: 4"*/}
                        {/*multiLine={true}*/}
                        {/*rows={2}*/}
                        {/*rowsMax={4}*/}
                    {/*/>*/}
                    <FormControl component="fieldset" required className={classes.formControl}>
                        <FormLabel component="legend">Gender</FormLabel>
                        <RadioGroup
                            aria-label="gender"
                            name="gender1"
                            className={classes.group}
                            // value={this.state.value}
                            // onChange={this.handleChange}
                        >
                            <FormControlLabel value="male" control={<Radio />} label="Male" />
                            <FormControlLabel value="female" control={<Radio />} label="Female" />
                            <FormControlLabel value="other" control={<Radio />} label="Other" />
                            {/*<FormControlLabel value="disabled" disabled control={<Radio />} label="Disabled" />*/}
                        </RadioGroup>
                    </FormControl>
                    <TextField
                        id="date"
                        name="bday"
                        label="Birthday"
                        type="date"
                        // defaultValue="2017-05-24"
                        className={classes.textField}
                        InputLabelProps={{
                            shrink: true,
                        }}
                    />
                    <input type="text" name="another"/>
                    <input type="hidden" name="hideIt" value="wtf"/>
                    <Button raised="true" type="submit">Submit</Button>
                </AjaxForm>
                <AjaxValidatorForm formName="gregger" action_path={GH.getRoute('submit_form_path')} onsuccess={this.onsuccess.bind(this)} onerror={this.onerror.bind(this)} focus="email">
                    <TextValidator
                        label="Email"
                        name="email"
                        validators={['required', 'isEmail']}
                        errorMessages={['this field is required', 'email is not valid']}
                    />
                    <TextValidator
                        label="Cris"
                        name="cris"
                        validators={['required']}
                        errorMessages={['this field is required']}
                    />
                    <Button raised="true" type="submit">Submit</Button>
                </AjaxValidatorForm>
            </div>
        );
    }
}

WebsocketChat.propTypes = {
    classes: PropTypes.object.isRequired,
};

export default withStyles(styles)(WebsocketChat);
