.. _install_pgsql:

==========================
安装PostgreSQL
==========================

macOS安装PostgreSQL
======================

第三方安装
----------------

- `enterprisedb 提供EDB版本 <https://www.enterprisedb.com/downloads/postgres-postgresql-downloads>`_ 下载安装PostgreSQL
- `Postgres.app <https://postgresapp.com/>`_ 提供一个简单原生的macOS应用，无需installer，可以直接运行PostgreSQL服务器

:ref:`homebrew` 安装
----------------------

- 在 :ref:`macos` 平台，最简单的还是使用 :ref:`homebrew` 安装，不过，安装时需要指定安装主版本号，以下是安装最新的 ``17`` 系列:

.. literalinclude:: install_pgsql/brew_install_postgresql
   :caption: 使用 :ref:`homebrew` 安装PostgreSQL

安装后的提示:

.. literalinclude:: install_pgsql/brew_install_postgresql_output
   :caption: 使用 :ref:`homebrew` 安装PostgreSQL

- 根据提示，在 ``~/.zshrc`` 中添加如下内容:

.. literalinclude:: install_pgsql/zshrc_postgresql
   :caption: 在 ``~/.zshrc`` 中添加PostgreSQL相关配置

- 启动有两种方式

使用 ``brew`` 服务启动:

.. literalinclude:: install_pgsql/brew_service_postgresql
   :caption: 使用 ``brew`` 服务启动 PostgreSQL

或者命令行前台启动:

.. literalinclude:: install_pgsql/command_postgresql
   :caption: 使用命令启动 PostgreSQL

参考
======

- `PostgreSQL Download > macOS packages <https://www.postgresql.org/download/macosx/>`_
