.. _go_proxy:

======================
配置Go程序代理服务器
======================

Go程序可以理解环境变量 ``http_proxy`` 和 ``no_proxy`` ，但是当使用 ``go get`` 和 ``go install`` 都是使用SCM来完成的，所以还需要配置 :ref:`git_proxy`

比较简单的方法是在执行 ``go`` 命令时直接传递代理配置::

   http_proxy=192.168.10.9:3128 go get golang.org/x/tools/gopls@v0.7.1

为了方彼岸使用，可以使用 ``alias`` :

.. literalinclude:: go_proxy/alias_go_proxy.sh
   :language: bash
   :caption: alias设置go代理

参考
======

- `How do I configure go command to use a proxy? <https://stackoverflow.com/questions/10383299/how-do-i-configure-go-command-to-use-a-proxy>`_
