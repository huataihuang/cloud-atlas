.. _install_mysql:

=================
MySQL安装
=================

macOS上安装MySQL
===================

MySQL官方提供了MySQL on macOS Native Packages，可以非常方便直接安装。

- 下载安装镜像(.dmg)文件，包含了MySQL软件安装共欧，双击dmg文件镜像
- 安装过程会提示输入root账号密码，输入root密码后自动安装
- 默认安装目录在 ``/usr/local/mysql`` ，所以需要将执行目录路径 ``/usr/local/mysql/bin`` 添加到环境变量 ``$PAHT`` 中

参考
========

- `Installing MySQL on macOS Using Native Packages <https://dev.mysql.com/doc/refman/8.0/en/osx-installation-pkg.html>`_
