.. _hugo_startup:

================
Hugo快速起步
================

在完成 :ref:`install_hugo` 后，可以快速使用Hugo构建一个网站

.. literalinclude:: hugo_startup/new
   :caption: 创建 ``docs.cloud-atlas.io`` 网站

此时提示如下:

.. literalinclude:: hugo_startup/new_output
   :caption: 创建 ``docs.cloud-atlas.io`` 网站输出信息

Themes
=======

在 `Hugo Themes <https://themes.gohugo.io/>`_ 找到心仪的Theme

.. note::

   我这里选择 `Hugo Geekdoc <https://themes.gohugo.io/themes/hugo-geekdoc/>`_ 构建一个简单的 `docs.cloud-atlas.io <https://docs.cloud-atlas.io>`_ 页面来引导阅读我撰写的不同文档手册

   另外，对于个人网站导引，可以采用 `Hugo Lynx <https://themes.gohugo.io/themes/lynx/>`_

- 将下载的 ``hugo-geekdoc.tar.gz`` 存放到 ``themes`` 目录下创建的 ``Geekdoc`` 目录中

.. literalinclude:: hugo_startup/theme_geekdoc
   :caption: 安装Geekdoc theme

- 在 ``docs.cloud-atlas.io`` 项目根目录下的 ``hugo.toml`` 中添加一行 ``theme`` 配置，并相应编辑对应配置，类似如下:

.. literalinclude:: hugo_startup/hugo.toml
   :caption: ``hugo.toml``

运行
=======

- 执行以下命令启动hugo的web服务:

.. literalinclude:: hugo_startup/server
   :caption: 启动hugo server

撰写文档
=========

- 撰写一个页面内容:

.. literalinclude:: hugo_startup/content
   :caption: 发布一个页面

发布网站
=========

- 执行以下命令，将在 ``public/`` 目录下生成静态网站，然后通过 :ref:`rsync` 同步到 ``bcloud-w1-r`` 服务器的 :ref:`nginx` 的WEB目录下:

.. literalinclude:: hugo_startup/deploy
   :caption: 发布网站

目前看到的是一个基础的页面，没有内容:



参考
======

- `Hugo Quick start <https://gohugo.io/getting-started/quick-start/>`_
