.. _macos_install_mysql:

=================
macos安装MySQL
=================

macOS上安装MySQL
===================

MySQL官方安装包
----------------

MySQL官方提供了MySQL on macOS Native Packages，可以非常方便直接安装。

- 下载安装镜像(.dmg)文件，包含了MySQL软件安装共欧，双击dmg文件镜像
- 安装过程会提示输入root账号密码，输入root密码后自动安装
- 默认安装目录在 ``/usr/local/mysql`` ，所以需要将执行目录路径 ``/usr/local/mysql/bin`` 添加到环境变量 ``$PAHT`` 中

由于MySQL在macOS的安装路径 ``/usr/local/mysql/lib`` 不是系统默认的动态库加载目录，所以需要在环境变量中添加如下::

   export DYLD_LIBRARY_PATH=$DYLD_LIBRARY_PATH:/usr/local/mysql/lib

否则Python使用 ``mysqlclient`` 模块会报无法找到动态库错误(请参考 :ref:`django_app` )

Homebrew安装
-------------

- 首先安装 :ref:`homebrew`

- 安装mysql::

   brew install mysql

- 在用户路径中添加mysql::

   export PATH=$PATH:/usr/local/mysql/bin

- 启动数据库::

   brew services start mysql

- 数据库安全初始化::

   mysql_secure_installation

移除测试数据库和匿名账号，并设置一个复杂密码。

数据库初始化
==============

在 :ref:`django` 开发中，我采用了两种环境:

- :ref:`docker_compose_django` 是先 :ref:`install_docker_macos` ，然后通过 ``docker-compose`` 实现的MySQL容器化运行
- :ref:`django_env_macos` 是在macOS上通过Python virtualenv运行Django，连接的是本地运行的一个MySQL数据库
- :ref:`django_env_linux` 是在Linux上通过Python virtualenv运行Django，连接的是本地运行的一个MySQL数据库

前者通过 :ref:`docker` 的官方镜像，支持传递环境变量就可以自动配置好MySQL数据库；但是后者则是传统的数据库维护方式，需要我们做数据库初始化才能用于 :ref:`django` 开发。

- 在MySQL中创建数据库 ``mydb`` 并创建 ``myapp_user`` 账号及对应密码 ``myapp_passwd`` :

.. literalinclude:: install_mariadb/create_db_user
   :caption: 创建一个数据库并创建访问账号及授权

参考
========

- `Installing MySQL on macOS Using Native Packages <https://dev.mysql.com/doc/refman/8.0/en/osx-installation-pkg.html>`_
