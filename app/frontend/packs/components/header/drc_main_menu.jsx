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

class DrcMainMenu extends React.Component {
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
                        style={{zIndex:1000}}
                    >
                        <ClickAwayListener onClickAway={this.handleClose.bind(this)}>
                            <Grow in={open} id="menu-list" style={{ transformOrigin: '0 0 0' }}>
                                <Paper>
                                    <MenuList role="menu">
                                        <MenuItem onClick={this.handleClose.bind(this, {action: 'first'})}>First</MenuItem>
                                        <MenuItem onClick={this.handleClose.bind(this, {action: 'account'})}>Account</MenuItem>
                                        <MenuItem onClick={this.handleClose.bind(this,  {action: 'logout'})} >Logout</MenuItem>
                                        <MenuItem onClick={this.handleClose.bind(this,  {action: 'show_headers'})} >Show Headers</MenuItem>
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

DrcMainMenu.propTypes = {
    classes: PropTypes.object.isRequired,
};

export default withStyles(styles)(DrcMainMenu);
