.. _python_os.environ_os.getenv:

===================================================
Python ``os.environ`` 对象 和 ``os.getenv()`` 方法
===================================================

``os.environ``
=================

在 Python 中 ``os.environ`` 是一个用户环境变量的映射对象(mapping object)。它返回的是一个 :ref:`python_dictionary` ，其中用户的环境变量作为键(key)，其值作为值(value)。由于 ``os.environ`` 是一个Python字典，所以可以执行字典的 ``get`` 和 ``set``

注意，虽然可以修改 ``os.environ`` ，但是 **任何 os.environ 修改只在当前进程有效，而不会持久化生效**

- 获取环境变量的代码片段案例:

.. literalinclude:: python_os.environ_os.getenv/environ_home.py
   :language: python
   :caption: 打印输出操作系统 **所有** 环境变量

环境变量获取空 ``null`` 问题
===============================

我在实践 :ref:`pyodps_startup` 遇到一个小白问题，运行 ``odps`` 测试程序报，调试发现并没有获得指定环境变量，原因就是在使用 ``os.environ`` 或者 ``os.getenv()`` ，一定要明确配置 ``export`` 指定环境变量，否则即使登陆 :ref:`bash` 看上去环境变量生效，实际 Python程序运行还是拿不到环境变量:

.. literalinclude:: ../../big_data/maxcompute/pyodps/pyodps_startup/odps_env
   :caption: ODPS相关环境变量设置
   :emphasize-lines: 4

参考
=====

- `Python | os.environ object <https://www.geeksforgeeks.org/python-os-environ-object/>`_
- `Python | os.getenv() method <https://www.geeksforgeeks.org/python-os-getenv-method/>`_
