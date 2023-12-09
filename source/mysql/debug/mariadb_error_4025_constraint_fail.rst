.. _mariadb_error_4025_constraint_fail:

======================================================
MariaDB ``ERROR 4025 (23000): CONSTRAINT ...``
======================================================

MariaDB支持在 ``CREATE TABLE`` 或 ``ALTER TABLE`` 状态下数据表级别的约束( ``constraint`` )检查。这种 ``table constraint`` 检查可以在用户添加数据时防止输入错误数据，这样就可以在数据库级别强制执行数据完整性校验，而不是通过应用程序限制。当语句违反约束(contraint)时，MariaDB会抛出错误:

- InnoDB引擎支持外键约束(foreign key constraints)
- 通过表达式检查约束(例如限制输入数据的值大小范围)
- 在bin log数据库复制: 当基于行日志(Row-Based Logging)复制时，检查主键(master)约束；当基于语句日志(Statement-Based Logging)复制时，还检查从键(slaves)
- ``auto_increment`` 字段不支持约束检查

案例
=======

当 :ref:`using_json_in_mariadb` 时，如果插入数据库的数据不是正确的JSON格式(可以使用 :ref:`jq` 工具校验)，则会提示错误::

   ERROR 4025 (23000): CONSTRAINT `users.details` failed for `mydb`.`users`

参考
=======

- `Information Schema CHECK_CONSTRAINTS Table <https://mariadb.com/kb/en/information-schema-check_constraints-table/>`_
- `MariaDB Knowledge Base >> CONSTRAINT <https://mariadb.com/kb/en/constraint/>`_
