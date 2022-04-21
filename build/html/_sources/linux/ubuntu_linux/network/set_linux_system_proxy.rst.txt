.. _set_linux_system_proxy:

============================
config linux system proxy
============================

debian/ubuntu system-wide proxy
=====================================

在Debian 11/10 环境中，如果使用标准 :ref:`bash` ，则可以通过配置 ``/etc/profile.d/proxy.sh`` :

.. literalinclude:: set_linux_system_proxy/proxy.sh
   :language: bash
   :caption: 通过 /etc/profile.d/proxy.sh 配置全局代理

- 并设置脚本可执行::

   sudo chmod +x /etc/profile.d/proxy.sh

- 然后重新登陆，或者直接 ``source`` 一次该文件使得runtime能够使用这个proxy设置::

   source /etc/profile.d/proxy.sh

- 然后通过以下命令确认环境变量生效::

   env | grep -i proxy

.. note::

   :ref:`apt` 也可以设置代理，详见 :ref:`apt` 文档

注意，实际上，上述配置脚本就是为了设置用户的SHELL的环境变量。但是，对于 :ref:`zsh` 上述设置没有效果。所以，可以将上述脚本配置内容配置到用户目录下的zsh配置文件 ``~/.zshrc`` 效果相同。

参考
=======

- `How to Set System Proxy on Debian 11/10 <https://distroid.net/set-system-proxy-debian/>`_
