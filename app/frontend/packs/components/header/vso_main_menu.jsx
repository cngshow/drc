import React from 'react';
import PropTypes from 'prop-types';
import classNames from 'classnames';
import Button from 'material-ui/Button';
import { MenuItem, MenuList } from 'material-ui/Menu';
import Grow from 'material-ui/transitions/Grow';
import Paper from 'material-ui/Paper';
import { withStyles } from 'material-ui/styles';
import { Manager, Target, Popper } from 'react-popper';
import ClickAwayListener from 'material-ui/utils/ClickAwayListener';

const styles = {
    root: {
        display: 'flex',
    },
    popperClose: {
        pointerEvents: 'none',
    },
};

class VsoMainMenu extends React.Component {
    state = {
        open: false,
    };

    handleClick = () => {
        this.setState({ open: true });
    };

    handleClose(id) {
        this.setState({ open: false });

        if (id.action === undefined) {
            return false;
        }
        console.log("id is "+ id.action);
        console.log("c is "+ id.component);
        PubSub.publish('HeaderClick', {text: id.action});
    };

    render() {
        const { classes } = this.props;
        const { open } = this.state;
        return (
            <div className={classes.root}>
                <Manager>
                    <Target>
                        <Button
                            aria-owns={open ? 'menu-list' : null}
                            aria-haspopup="true"
                            onClick={this.handleClick}
                        >
                            Open Menu
                        </Button>
                    </Target>
                    <Popper
                        placement="bottom-start"
                        eventsEnabled={open}
                        className={classNames({ [classes.popperClose]: !open })}
                    >
                        <ClickAwayListener onClickAway={this.handleClose.bind(this)}>
                            <Grow in={open} id="menu-list" style={{ transformOrigin: '0 0 0' }}>
                                <Paper>
                                    <MenuList role="menu">
                                        <MenuItem onClick={this.handleClose.bind(this, {action: 'first', component: 'First'})}>First</MenuItem>
                                        <MenuItem onClick={this.handleClose.bind(this, {action: 'acct', component: 'Account'})}>Account</MenuItem>
                                        <MenuItem onClick={this.handleClose.bind(this,  {action: 'logout', component: 'Logout'})} >Logout</MenuItem>
                                    </MenuList>
                                </Paper>
                            </Grow>
                        </ClickAwayListener>
                    </Popper>
                </Manager>
            </div>
        );
    }
}

VsoMainMenu.propTypes = {
    classes: PropTypes.object.isRequired,
};

export default withStyles(styles)(VsoMainMenu);
