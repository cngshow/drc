import React from 'react';
import PropTypes from 'prop-types';
import { withStyles } from 'material-ui/styles';
import Drawer from 'material-ui/Drawer';
import Button from 'material-ui/Button';
import List, { ListItem, ListItemIcon, ListItemText } from 'material-ui/List';
import Divider from 'material-ui/Divider';
import InboxIcon from 'material-ui-icons/Inbox';
import DraftsIcon from 'material-ui-icons/Drafts';

const styles = {
    list: {
        width: 250,
    },
};

class HeaderDrawerMenu extends React.Component {
    state = {
        left: false,
    };

    toggleDrawer = (side, open) => () => {
        this.setState({
            [side]: open,
        });
    };

    render() {
        const { classes } = this.props;

        return (
            <div>
                <Button onClick={this.toggleDrawer('left', true)}>Open Left</Button>

                <Drawer open={this.state.left} onClose={this.toggleDrawer('left', false)}>
                    <div
                        tabIndex={0}
                        role="button"
                        onClick={this.toggleDrawer('left', false)}
                        onKeyDown={this.toggleDrawer('left', false)}
                    >
                        <div className={classes.list}>
                        <List component="nav">
                            <ListItem button>
                                <ListItemIcon>
                                    <InboxIcon />
                                </ListItemIcon>
                                <ListItemText primary="Inbox" />
                            </ListItem>
                            <ListItem button>
                                <ListItemIcon>
                                    <DraftsIcon />
                                </ListItemIcon>
                                <ListItemText primary="Drafts" />
                            </ListItem>
                        </List>
                        <Divider />
                        <List component="nav">
                            <ListItem button>
                                <ListItemText primary="Trash" />
                            </ListItem>
                            <ListItem button component="a" href="#simple-list">
                                <ListItemText primary="Spam" />
                            </ListItem>
                        </List>
                    </div>
                    </div>
                </Drawer>
            </div>
        );
    }
}

HeaderDrawerMenu.propTypes = {
    classes: PropTypes.object.isRequired,
};

export default withStyles(styles)(HeaderDrawerMenu);
