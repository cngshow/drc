import React from 'react';
import PropTypes from 'prop-types';
import { withStyles } from 'material-ui/styles';
import AppBar from 'material-ui/AppBar';
import Toolbar from 'material-ui/Toolbar';
import Typography from 'material-ui/Typography';
import Button from 'material-ui/Button';
import IconButton from 'material-ui/IconButton';
import MenuIcon from 'material-ui-icons/Menu';
import GH from './components/helpers/gon_helper'

const styles = {
    root: {
        width: '100%',
    },
    flex: {
        flex: 1,
        paddingLeft: 10
    },
    menuButton: {
        marginLeft: -12,
        marginRight: 20,
    },
};

function handleClose(action) {
    console.log("we are closing...." + action);
}

class VsoAppBar extends React.Component {
    handleClose = (action) => {
        console.log("we are closing...." + action);
    };

    render() {
        const {classes} = this.props;
        return (
            <div className={classes.root}>
                <AppBar position="static" style={{backgroundColor: 'cornsilk', color: 'navy'}}>
                    <Toolbar>
                        <IconButton className={classes.menuButton} color="inherit" aria-label="Menu">
                            <MenuIcon onClick={this.handleClose.bind(this, {action: 'show_headers'})}/>
                        </IconButton>
                        <img src={GH.getImagePath('VA-header.png')} alt="VA Header Image"/>
                        <Typography type="title" color="inherit" className={classes.flex}>
                            VSO Title
                        </Typography>
                        <Button color="inherit">Login</Button>
                    </Toolbar>
                </AppBar>
            </div>
        )
    }
}
/*
VsoAppBar.propTypes = {
    classes: PropTypes.object.isRequired,
};
*/

export default withStyles(styles)(VsoAppBar);