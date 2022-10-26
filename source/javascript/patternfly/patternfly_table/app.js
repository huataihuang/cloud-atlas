import * as React from "react";
import "@patternfly/react-core/dist/styles/base.css";
import { Table, TableHeader, TableBody } from "@patternfly/react-table";
import { Pagination } from '@patternfly/react-core';
import { columns, defaultRows } from './data';

const App = () => {
  const defaultPerPage = 2;
  const [numPerPage, setNumPerPage] = React.useState(defaultPerPage);
  const [currentPage, setCurrentPage] = React.useState(1);
  const [rows, setRows] = React.useState(defaultRows.slice(0, defaultPerPage));
  const handlePerPageSelect = (_evt, newPerPage, newPage = 1, startIdx, endIdx) => {
    setNumPerPage(newPerPage);
    setRows(defaultRows.slice(startIdx, endIdx));
  };
  const handleSetPage = (_evt, newPage, perPage, startIdx, endIdx) => {
    setCurrentPage(newPage);
    setRows(defaultRows.slice(startIdx, endIdx));
  }
  return (
    <React.Fragment>
      <Pagination
        onSetPage={handleSetPage}
        onPerPageSelect={handlePerPageSelect}
        perPageOptions={[{ title: "2", value: 2 }, { title: "3", value: 3 }]}
        page={currentPage}
        perPage={numPerPage}
        itemCount={defaultRows.length} />
      <Table variant="compact" caption="PatternFly React Table" cells={columns} rows={rows}>
        <TableHeader />
        <TableBody />
      </Table>
    </React.Fragment>
  );
};

export default App;

