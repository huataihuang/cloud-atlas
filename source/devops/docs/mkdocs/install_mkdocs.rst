.. _install_mkdocs:

=====================
安装MkDocs
=====================

准备Python virtualenv
======================

- 构建虚拟沙箱环境非常简单:

.. literalinclude:: ../../../python/startup/virtualenv/venv
   :language: bash
   :caption: venv初始化

- 激活:

.. literalinclude:: ../../../python/startup/virtualenv/venv_active
   :language: bash
   :caption: 激活venv

安装MkDocs
==============

- 安装Python3模块mkdocs:

.. literalinclude:: install_mkdocs/install_mkdocs
   :language: bash
   :caption: 安装Python3的mkdocs模块

解决访问Google CSS和fonts
===========================

如果没有自由的互联网连接(需要能够直接访问Google服务)，就会发现 ``MkDocs`` 生成的 ``sites`` 静态网页访问非常缓慢。原因可以通过浏览器的 ``Web inspector`` 检查，就可以看到 ``fonts`` 和 ``CSS`` 都是从Google网站下载的。但是在墙内无法直接访问以下2个Google服务网址:

- https://fonts.gstatic.com/
- https://fonts.googleapis.com/

解决方法要么构建VPN，要么将引用上述两个Google的网址替换成国内镜像网站

