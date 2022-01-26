.. _redis_dev_python:

==================
Redis开发(Python)
==================

在 :ref:`priv_cloud_infra` 中采用 :ref:`fedora_dev_init` 部署 :ref:`z-dev` 开发环境。

Redis的主要开发方式:

- ``redis-py`` : 在Python中使用Redis，是C客户端 ``hiredis`` 的包装
- ``hiredis`` : 官方提供C库，支持整个命令集合，pipelining(一次发送多个指令)，甚至驱动编程

安装Redis
===========

开发环境 :ref:`install_redis_startup` 即可，并简单配置认证安全

安装Python开发
=================

- :ref:`fedora_dev_python` ，使用 :ref:`virtualenv` (项目名称 ``ria`` ) ::

   python3 -m venv ria_venv
   source ria_venv/bin/activate

- 安装Python语言Redis客户端库::

   python -m pip install redis

Python Redis客户端库， ``redis-py`` 可以高效完成开发，这个Pthon库包装了一个连接Redis服务器端TCP连接，并使用 Redis Serialization Protocol(Redis序列化协议, RESP)发送底层命令。

``parser`` (语法分析器)是截获底层响应然后转换成客户端能够理解内容的请求响应工具。 ``redis-py`` 自身有一个纯Python实现的 ``PythonParser`` 解析器。不过，这个纯Python解析器效率相对较低，所以在实际生产环境，会使用C编写的底层苦4 ``Hiredis`` ，提供了高性能Redis命令加速。

只要安装了 ``hiredis`` 这个Python模块， ``redis-py`` 就会首先尝试调用 ``Hiredis`` 来完成解析，也就是能够加速redis处理。

- 所以，我们通常会同时再安装 ``hiredis`` Python模块::

   python -m pip install hiredis

安装以后， ``redis-py`` 调用 ``Hiredis`` 是完全透明的，也就是编程没有任何区别， ``redis-py`` 会尝试 ``import`` hiredis，并使用 ``HiredisParser`` 类来处理，除非失败才会使用 ``PythonParser`` 来代替。

.. note::

   安装 ``hiredis`` Python模块，需要编译C库，所以需要操作系统首先安装 ``python3-devel`` 软件包，否则安装会失败。

验证
=======

.. note::

   Redis 服务器已经按照 :ref:`install_redis_startup` 完成账号密码配置，所以这里验证需要提供连接账号配置

通过交互方式输入以下代码进行验证::

   >>> import redis
   >>> r = redis.Redis(
   ... host='192.168.6.253',
   ... port=6379,
   ... password='AuthPassword')
   >>> r.mset({"Croatia": "Zagreb", "Bahamas": "Nassau"})
   True
   >>> r.get("Bahamas")
   b'Nassau'

参考
======

- 「Redis实战」
- `How to Use Redis With Python <https://realpython.com/python-redis>`_
- `Redis with Python <https://docs.redis.com/latest/rs/references/client_references/client_python/>`_
