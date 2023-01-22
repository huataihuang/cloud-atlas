.. _macos_homebrew_nginx:

==============================
macOS中使用Homebrew部署nginx
==============================

在 :ref:`macos` 中通过 :ref:`homebrew` 构建 :ref:`macos_studio` ，在 ``brew`` 安装完 ``nginx`` 软件包之后，通过简单配置就可以开始 :ref:`sphinx_doc` 笔记:

默认的 :ref:`homebrew` 安装 ``nginx`` 的配置目录是 ``/opt/homebrew/etc/nginx`` ，默认WEB目录是 ``/opt/homebrew/var/www`` ，默认端口 ``8080``

- 修改 ``/opt/homebrew/etc/nginx/nginx.conf`` :

.. literalinclude:: macos_homebrew_nginx/nginx.conf
   :language: bash
   :caption: 简单修订 /opt/homebrew/etc/nginx/nginx.conf 启用 Sphinx doc 访问
   :emphasize-lines: 13,16
