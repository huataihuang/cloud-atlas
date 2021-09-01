.. _install_python3_centos6:

=========================
CentOS 6环境安装Python 3
=========================

:ref:`prepare_kernel_dev` 因为需要早期Linux环境来学习内核和系统开发，所以需要 :ref:`install_vim_centos6` 。不过，CentOS 6时代Python 3尚未成为主流，所以操作系统软件仓库未包含Python 3。

在 CentOS 6 上安装Python 3，可以通过源代码编译，或者使用第三方软件仓库如EPEL（Python 3.4 ）。所以先 :ref:`fix_centos6_repo` ，然后再执行安装::

   sudo yum install python34 python34-devel

参考
=========

- `How to install the latest Python 3.x in CentOS 6 <https://www.2daygeek.com/install-python-3-on-centos-6/>`_