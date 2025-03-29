.. _ncdu:

======================
ncdu磁盘使用排查工具
======================

编译安装
=============

- 系统需要安装 ``ncurses-devel`` ::

   sudo yum install ncurses-devel

- 编译安装::

   ./configure --prefix=/usr
   make
   make install
