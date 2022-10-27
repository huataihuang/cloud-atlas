import * as React from "react";
import "@patternfly/react-core/dist/styles/base.css";
import { Table, TableHeader, TableBody } from "@patternfly/react-table"; // react 表支持
import { Pagination } from '@patternfly/react-core'; // react 分页支持
import { columns, defaultRows } from './data'; // data.js 包含TypeScript的对象数据

const App = () => {
  const defaultPerPage = 2; // 分页属性: 默认每页2行记录
  const [numPerPage, setNumPerPage] = React.useState(defaultPerPage); // 设置好默认分页
  const [currentPage, setCurrentPage] = React.useState(1);  // 启动时使用第一页
  const [rows, setRows] = React.useState(defaultRows.slice(0, defaultPerPage));
  const handlePerPageSelect = (_evt, newPerPage, newPage = 1, startIdx, endIdx) => {  // 处理每页选择
    setNumPerPage(newPerPage);
    setRows(defaultRows.slice(startIdx, endIdx));
  };
  const handleSetPage = (_evt, newPage, perPage, startIdx, endIdx) => {  // 处理分页的选项
    setCurrentPage(newPage);
    setRows(defaultRows.slice(startIdx, endIdx));
  }
  return (
    <React.Fragment>
      <Pagination
        onSetPage={handleSetPage}  // 设置分页时处理设置分页
        onPerPageSelect={handlePerPageSelect}  // 当分页功能选择时处理分页选择
        perPageOptions={[{ title: "2", value: 2 }, { title: "3", value: 3 }]}  // 设置可选的分页中记录数量
        page={currentPage}  // 当前显示页
        perPage={numPerPage} // 每页记录数量
        itemCount={defaultRows.length} />  // 表格记录数等于所有行
      <Table variant="compact" caption="PatternFly React Table" cells={columns} rows={rows}> // variant="compact" 表示表格压缩模式显示，比较好看 | cells={columns} rows={rows} 引入前面从 data.js import进来的数据
        <TableHeader />
        <TableBody />
      </Table>
    </React.Fragment>
  );
};

export default App;

