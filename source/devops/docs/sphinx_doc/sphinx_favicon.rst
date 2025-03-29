.. _sphinx_favicon:

==================
Sphinx favicon
==================

`cloud-atlas.io <https://cloud-atlas.io>`_ Nginx日志时，可以看到每次浏览器请求都会记录

.. literalinclude:: ../../../web/nginx/nginx_favicon/error
   :caption: Nginx日志显示每次访问都缺少 ``favicon.ico`` 文件

虽然没有太大影响，但是每次看到页面加载时候 ``Load`` 箭头在转动感觉也很难受，所以检查如何解决

- 如果页面头部没有嵌入指定合适的 ``favicon`` ，那么默认浏览器会去下载WEB服务器根部的 ``favicon.ico`` 文件，这也是一种托底方案: :ref:`nginx_favicon`
- 比较优雅的方案还是在Sphinx内部解决，在 ``conf.py`` 中添加如下代码:

.. literalinclude:: sphinx_favicon/favicon.py
   :caption: 添加 favicon 配置

.. note::

   `favicon.io <https://favicon.io/>`_ 提供了非常好的在线转换，不仅可以转换图片，还能转换文字和Emoji。例如，我简单用它的 ``TEXT -> ICO`` 转换了 ``云`` 字

参考
======

- `Sphinx Configuration > html_favicon <https://www.sphinx-doc.org/en/master/usage/configuration.html#confval-html_favicon>`_
