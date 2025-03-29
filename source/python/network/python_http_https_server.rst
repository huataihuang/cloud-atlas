.. _python_http_https_server:

=============================
Python HTTP/HTTPS 服务器
=============================

在日常运维工作中，经常需要启动一个简单的HTTP/HTTPS服务

HTTP服务
==========

Python 3.x
--------------

- 在 Python 3中启动HTTP服务使用 ``http`` 模块:

.. literalinclude:: python_http_https_server/python3_http_server
   :language: bash
   :caption: 使用 ``http`` 模块在Python3中启动一个WEB服务器

Python 2.x
--------------

- 早期的 Python 2使用 ``SimpleHTTPServer`` 模块:

.. literalinclude:: python_http_https_server/python2_http_server
   :language: bash
   :caption: 使用 ``SimpleHTTPServer`` 模块在Python2中启动一个WEB服务器

HTTPS服务
============

Python 3.x (早期版本)
-----------------------

- 在Python 3早期版本可以使用以下代码片段来实现一个HTTPS服务:

.. literalinclude:: python_http_https_server/python3_https_server.py
   :language: python
   :caption: 早期Python3启动HTTPS服务代码片段

- 生成服务器密钥和证书:

.. literalinclude:: python_http_https_server/openssl_generate_key_cert
   :language: bash
   :caption: 生成服务器密钥和证书

.. warning::

   这段代码在现在的 Python 3.11 已经报错

Python 3.x
-------------

- 改为 ``SSLContext.wrap_socket`` 的Python 3.x代码片段:

.. literalinclude:: python_http_https_server/python3.x_https_server.py
   :language: python
   :caption: 现在的Python3启动HTTPS服务代码片段

.. warning::

   这段代码还有bug，待修正

- 生成合并cert.pm:

.. literalinclude:: python_http_https_server/openssl_generate_cert
   :language: bash
   :caption: 生成服务器cert.pm(单个文件包含key和cert)

Pythone 2.x(待验证)
--------------------

- Python 2.x实现HTTPS代码片段:

.. literalinclude:: python_http_https_server/python2_https_server.py
   :language: python
   :caption: Python2启动HTTPS服务代码片段

- 生成服务器密钥和证书:

.. literalinclude:: python_http_https_server/openssl_generate_key_cert
   :language: bash
   :caption: 生成服务器密钥和证书

参考
=====

- `Python HTTP(S) Server — Example <https://anvileight.com/blog/posts/simple-python-http-server/>`_
- `Python Simple HTTP Server With SSL Certificate (Encrypted Traffic) <https://plainenglish.io/blog/python-simple-http-server-with-ssl-certificate-encrypted-traffic-73ffd491a876>`_
