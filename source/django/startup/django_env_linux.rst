.. _django_env_linux:

=======================
Django开发环境(linux)
=======================

在 :ref:`centos` 环境上部署Django开发运行环境，基本和 :ref:`django_env_macos` 相同，细节差异:

- 生产环境采用了古老的CentOS 7.2环境，实际我为了能够追平最新的运行开发环境，采用了 :ref:`build_python3_in_centos7`
- :ref:`virtualenv` 环境采用 :ref:`rebuild_virtualenv` 
- 由于数据库后端采用 :ref:`mysql` ，所以需要安装 ``mysqlclient`` 模块

构建步骤
===========

- 完成 :ref:`build_python3_in_centos7` 准备工作

- 创建 :ref:`virtualenv` (这里项目名为 ``onesre`` ):

.. literalinclude:: django_mysql/virtualenv_onesre
   :caption: 构建一个 ``onesre`` 项目运行环境

- 需要安装 mysql 开发包，例如 ``mariadb-devel`` ，安装以后系统会有 ``mysql_config`` 工具:

.. literalinclude:: django_mysql/install_mysql-devel
   :caption: 需要提前安装 ``mysql-devel`` 或 ``mariadb-devel`` 才能执行 ``pip install mysqlclient``

- 在项目目录下重新恢复 

.. literalinclude:: ../../python/startup/rebuild_virtualenv/pip_install_requirements
   :language: bash
   :caption: 根据requirements.txt恢复virtualenv依赖模块包

解决 ``mysqlclient`` 模块安装
------------------------------

这次遇到一个报错，和之前 :ref:`django_mysql` 不同:

.. literalinclude:: django_env_linux/mysqlclient_error
   :caption: ``pip`` 安装 ``mysqlclient`` 报错
   :emphasize-lines: 10-13

这里可以看到 ``pkg-config --exists mysqlclient`` 和 ``pkg-config --exists mariadb`` 都是返回 ``1`` (失败)。我手工执行了一下，确实 ``echo $?`` 显示 ``1``

仔细一看，原来这个  ``pkg-config`` 是操作系统默认的 ``/usr/bin/pkg-config`` 。这里通过 ``rpm -qf /usr/bin/pkg-config`` 可以看出是属于 ``pkgconfig-0.27.1-4.1.alios7.x86_64`` ，显然不会获得正确的包信息

`PyMySQL / mysqlclient / README.md <https://github.com/PyMySQL/mysqlclient/blob/main/README.md>`_ 提供了一个线索:

.. literalinclude:: django_env_linux/pkg-config_mysqlclient
   :caption: 定制编译时指定环境变量

既然由于操作系统的 ``pkg-config`` 无法正常工作，那么该如何设置环境变量呢?

我找了自己部署的一台 :ref:`fedora` 开发环境(吐槽一下公司魔改的CentOS)，可以看到:

.. literalinclude:: django_env_linux/pkg-config_mariadb
   :caption: 在正确的环境中执行 ``pkg-config`` 获取环境变量
   :emphasize-lines: 2,4

- 所以修正安装方法:

.. literalinclude:: django_env_linux/pkg-config_mariadb_env
   :caption: 设置正确 ``mysqlclient`` 环境变量

- 然后再次执行就可以完成:

.. literalinclude:: ../../python/startup/rebuild_virtualenv/pip_install_requirements
   :language: bash
   :caption: 根据requirements.txt恢复virtualenv依赖模块包

解决 ``pip`` 下载失败(手工下载安装)
-------------------------------------

墙内的杯具就是，在线安装的灵活方便往往会被GFW干成生不如死: ``pip install`` 过程中，遇到 ``Babel-2.12.1-py3-none-any.whl`` 下载始终中断的问题。解决的方法： :ref:`pip_offline`

- 通过 ``pip downlaod`` 命令下载指定软件包(版本)，这里举例 ``Babel-2.12.1-py3-none-any.whl`` :

.. literalinclude:: ../../python/startup/pip_offline/pip_download
   :caption: ``pip download`` 可以下载指定版本python包

- 将下载好的 ``.whl`` python包复制到目标主机，然后就可以直接离线安装:

.. literalinclude:: ../../python/startup/pip_offline/pip_install_whl
   :caption: ``pip install`` 可以安装下载好的 ``.whl`` python包



参考
=====

- `PyMySQL / mysqlclient / README.md <https://github.com/PyMySQL/mysqlclient/blob/main/README.md>`_
