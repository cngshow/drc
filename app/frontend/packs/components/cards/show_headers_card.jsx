import React from 'react';
// import {AgGridReact, AgGridColumn} from 'ag-grid-react';
import axios from 'axios'
import GH from '../helpers/gon_helper'
import ReactTable from 'react-table'
import 'react-table/react-table.css'

class ShowHeaders extends React.Component {
    constructor() {
        super();
        this.state = {
            rowData: [],
        };
        this.loadHeaderData = this.loadHeaderData.bind(this);
    }

 /*   onGridReady(params) {
        this.gridApi = params.api;
        this.columnApi = params.columnApi;
        this.gridApi.sizeColumnsToFit();
    }*/

    loadHeaderData(headers) {
        this.setState({rowData: headers})
    };

    componentDidMount() {
        let loadHeaderData = this.loadHeaderData;

        axios.get(gon.routes.show_headers_path)
            .then(function (response) {
                console.log('header data is', response.data);
                loadHeaderData(response.data);
            })
            .catch(function (error) {
                console.log(error);
            });
    }

    componentWillUnmount() {
        console.log("show headers will unmount ok!");
    }

     render() {
        const { rowData } = this.state;
        return (
            <div>
                <ReactTable
                    data={rowData}
                    columns={[
                        {
                            Header: "Header Key",
                            accessor: "header_key"
                        },
                        {
                            Header: "Header Value",
                            accessor: "header_value"
                        },
                    ]}
                    defaultPageSize={10}
                    className="-striped -highlight"
                />
                <br />
            </div>
        );
    }
    render2() {
        let containerStyle = {
            height: '100%',
            backgroundColor: 'gray',

        };
/*
        return (
            <div style={containerStyle} className="ag-theme-fresh">
                this is a test
            </div>
        )
*/

        return (
            <div style={containerStyle}>
                <div className="ag-theme-fresh">
                    <AgGridReact
                        rowData={this.state.rowData}
                        onGridReady={this.onGridReady}
                        enableSorting
                    >
                        <AgGridColumn field="header_key"/>
                        <AgGridColumn field="header_value"/>
                    </AgGridReact>
                </div>
            </div>
        )
    }

    myrender() {
        let h = this.state.headers;
        let items = Object.keys(h).map((header) => {
            return (<li><strong>{header}</strong> = {h[header]}</li>)
        });

        return (
            <div>
                <h1>Headers Are:</h1>
                <ul>
                    {items}
                </ul>
            </div>
        )
    }
}

export default ShowHeaders
