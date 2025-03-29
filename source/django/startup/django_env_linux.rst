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

- 需要安装 mysql 开发包，例如 ``mariadb-devel`` ( ``警告，一定要安装MariaDB 最新版本例如 v10.11 ，否则编译会失败`` ) ，安装以后系统会有 ``mysql_config`` 工具:

.. literalinclude:: django_mysql/install_mysql-devel
   :caption: 需要提前安装 ``mysql-devel`` 或 ``mariadb-devel`` 才能执行 ``pip install mysqlclient``

- 在项目目录下重新恢复 

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

:ref:`mysql` 数据连接
========================

生产环境采用 :ref:`mysql` ，所以 :ref:`django_mysqlclient_config`  (这里包括数据库初始创建步骤):

参考
=====

- `PyMySQL / mysqlclient / README.md <https://github.com/PyMySQL/mysqlclient/blob/main/README.md>`_
