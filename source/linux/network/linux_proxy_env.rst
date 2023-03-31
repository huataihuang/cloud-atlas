.. _linux_proxy_env:

===================
Linux代理环境变量
===================

如果你在墙内受到GFW的困扰，对于Linux平台，众多的软件，无论是 :ref:`curl` ,  :ref:`docker` ，其实都采用了Linux标准的环境变量设置:

.. literalinclude:: linux_proxy_env/env
   :language: bash
   :caption: Linux通用代理环境变量案例

参考
======

- `MicroK8s: Installing behind a proxy <https://microk8s.io/docs/install-proxy>`_
