.. _pyodps_startup:

=====================
PyODPS快速起步
=====================

PyODPS是MaxCompute的Python版本的SDK:

- 简单方便的Python编程接口:

  - 编写MaxCompute作业
  - 查询MaxCompute表和视图
  - 管理MaxCompute资源

PyODPS支持在本地环境、DataWorks、PAI Notebooks中使用

安装PyODPS
=============

- 使用 :ref:`pip` 安装 ``PyODPS`` :

.. literalinclude:: pyodps_startup/install_pyodps
   :caption: :ref:`pip` 安装 ``PyODPS``

- 安装以后通过以下命令检查验证是否安装成功，没有报错信息则表示成功:

.. literalinclude:: pyodps_startup/check_pyodps_install
   :caption: 验证 ``PyODPS`` 安装

简单查询
=========

官方文档提供了一个简单的查询案例，我简单复述如下:

.. literalinclude:: pyodps_startup/odps_select.py
   :language: python
   :caption: 验证odps查询的python案例

这里我运行案例遇到一个报错:

.. literalinclude:: pyodps_startup/odps_select.py_output
   :caption:  验证odps查询的python案例报错

这个报错有点迷惑，但是实际上通过一条条命令排查，会发现实际上 :ref:`python_os.environ_os.getenv` 返回的指定环境变量 ``ALIBABA_CLOUD_ACCESS_KEY_ID`` 和 ``ALIBABA_CLOUD_ACCESS_KEY_SECRET`` 是空的( ``Non`` )

原因说来很简单，原来在 ``bash`` 的 ``~/.bash_profile`` 中缺少 ``export`` 命令来明确输出环境变量就会导致 Python 的 :ref:`python_os.environ_os.getenv` 无法获得该环境变量，所以一定要规范配置环境变量:

.. literalinclude:: pyodps_startup/odps_env
   :caption: ODPS相关环境变量设置
   :emphasize-lines: 4


参考
========

- `PyODPS概述 <https://www.alibabacloud.com/help/zh/maxcompute/user-guide/overview-3>`_
- `安装PyODPS <https://www.alibabacloud.com/help/zh/maxcompute/user-guide/install-pyodps>`_

