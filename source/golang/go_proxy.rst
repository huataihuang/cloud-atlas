.. _go_proxy:

======================
配置Go程序代理服务器
======================

Go程序可以理解环境变量 ``http_proxy`` 和 ``no_proxy`` ，但是当使用 ``go get`` 和 ``go install`` 都是使用SCM来完成的，所以还需要配置 :ref:`git_proxy` 。目前我实践下来需要以下步骤:

- 配置 ``http_proxy`` 和 ``https_proxy`` 环境变量;

.. literalinclude:: ../devops/git/go_proxy/env
   :language: bash
   :caption: 配置代理环境变量

- 配置 :ref:`git_proxy` :

.. literalinclude:: git_proxy/git_config_http.proxy
   :language: bash
   :caption: 全局配置git使用HTTP/HTTPS代理

归档
========

.. warning::

   我最近一次 :ref:`homebrew_init` 实践安装 :ref:`colima` 遇到问题，似乎通过 ``alias`` 方式设置 ``go`` 命令没有成功，所以这段设置方法暂时废弃(归档)。实际使用方法暂时以上文设置环境变量 ``http_proxy`` 和 ``https_proxy`` 为准。

HTTP代理

比较简单的方法是在执行 ``go`` 命令时直接传递代理配置::

   http_proxy=192.168.10.9:3128 go get golang.org/x/tools/gopls@v0.7.1

为了方便使用，可以使用 ``alias`` :

.. literalinclude:: go_proxy/alias_go_proxy.sh
   :language: bash
   :caption: alias设置go代理

Socks代理
------------

socks代理:

.. literalinclude:: go_proxy/alias_go_socks_proxy
   :language: bash
   :caption: alias设置go socks代理


参考
======

- `How do I configure go command to use a proxy? <https://stackoverflow.com/questions/10383299/how-do-i-configure-go-command-to-use-a-proxy>`_
