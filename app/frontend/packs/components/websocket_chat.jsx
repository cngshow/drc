import React from 'react';
import ReactDOM from 'react-dom';
import PropTypes from 'prop-types';
import { withStyles } from 'material-ui/styles';
import TextField from 'material-ui/TextField';
import Button from 'material-ui/Button';
import WebSocketHelper from '../../packs/utilities/websocket'
import PubSub from 'pubsub-js'

const styles = theme => ({
    container: {
        display: 'flex',
        flexWrap: 'wrap',
    },
    textField: {
        marginLeft: theme.spacing.unit,
        marginRight: theme.spacing.unit,
        width: 200,
    }
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
        this.websocket = new WebSocketHelper('root_beer');//todo #figure out a way to bind the channels to js dynamically via irb
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

    resetForm() {
         this.setState({form: {}});
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
                <form className="input" onSubmit={(e) => this.submitMessage(e)}>
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

                    <Button raised type="submit">Submit</Button>
                </form>
            </div>
        );
    }
}

WebsocketChat.propTypes = {
    classes: PropTypes.object.isRequired,
};

export default withStyles(styles)(WebsocketChat);
