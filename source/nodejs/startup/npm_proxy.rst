.. _npm_proxy:

====================
配置npm代理
====================

在 :ref:`my_vimrc` 安装 ``YouCompleteMe`` 插件时，会发现 :ref:`golang` 和 :ref:`nodejs` 使用的模块仓库都被GFW屏蔽了。所以，不仅需要 :ref:`go_proxy` ，也需要配置NPM代理服务器

我采用 ``alias`` 方式配置 ``npm`` 使用代理服务器:

.. literalinclude:: npm_proxy/npm_proxy
   :language: bash
   :caption: 设置npm代理

参考
======

- `Is there a way to make npm install (the command) to work behind proxy? <https://stackoverflow.com/questions/7559648/is-there-a-way-to-make-npm-install-the-command-to-work-behind-proxy>`_
