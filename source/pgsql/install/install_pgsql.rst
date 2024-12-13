.. _install_pgsql:

==========================
安装PostgreSQL
==========================

.. _install_pgsql_debian:

:ref:`debian` 安装PostgreSQL
==============================

发行版安装
-------------

- :ref:`debian` 发行版包含了PostgreSQL，版本稍微低一些，例如当前PostgreSQL的current是17.2，而Debian 12(bookworm)则提供PostgreSQL 15:

.. literalinclude:: install_pgsql/apt_install_pgsql
   :caption: 通过 :ref:`debian` 发行版安装PostgreSQL

``postgresql-contrib`` 是社区捐赠软件包提供了有用的扩展和工具

- 然后可以设置启动:

.. literalinclude:: install_pgsql/enable_pgsql
   :caption: 设置PostgreSQL自动启动

使用官方软件仓库安装
-----------------------

PostgreSQL Apt仓库提供了更新的PostgreSQL版本以及补丁管理继承，可以自动完成所有PostgreSQL生命周期的所有版本更新: `PostgreSQL Downlaad > Linux downloads (Debian) <https://www.postgresql.org/download/linux/debian/>`_ 提供了详细支持OS版本和架构，例如我在 :ref:`pi_5` 实际是 :ref:`debian` bookworm(12.x)以及架构 ``arm64`` 都是官方支持的，所以通过以下方式安装:

自动仓库配置安装
~~~~~~~~~~~~~~~~~~

简单执行以下命令就可以完成仓库配置:

.. literalinclude:: install_pgsql/auto_repo_config
   :caption: 自动完成仓库配置

手工配置仓库安装
~~~~~~~~~~~~~~~~~~

执行以下命令配置Apt仓库:

.. literalinclude:: install_pgsql/manual_repo_config_install
   :caption: 手工完成仓库配置并安装

使用PostgreSQL的官方仓库进行安装的PostgreSQL是设置为自动启动服务，所以可以看到:

.. literalinclude:: install_pgsql/check_pgsql
   :caption: 检查PostgreSQL
   :emphasize-lines: 12-17

.. _install_pgsql_macos:

:ref:`macos` 安装PostgreSQL
==============================

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

- 创建 ``postgres`` 用户( :ref:`pgadmin` 使用这个角色访问):

.. literalinclude:: install_pgsql/brew_pgsql_createuser
   :caption: 通过 :ref:`homebrew` 安装的PostgreSQL，需要创建一个 ``postgres`` 系统用户角色

下一步
==========

完成PostgreSQL之后，就可以 :ref:`access_pgsql` (包括设置权限)

参考
======

- `PostgreSQL Download > macOS packages <https://www.postgresql.org/download/macosx/>`_
- `PostgreSQL Downlaad > Linux downloads (Debian) <https://www.postgresql.org/download/linux/debian/>`_
- `How to Install PostgreSQL on Debian 12: A Step-by-Step Tutorial <https://www.sqliz.com/posts/install-postgresql-on-debian-12/>`_
