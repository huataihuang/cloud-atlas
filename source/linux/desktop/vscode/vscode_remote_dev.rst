.. _vscode_remote_dev:

================
VS Code远程开发
================

VS Code Remote Development允许使用container容器，远程服务器或者Windows Subsystem for Linux (WSL)作为全功能开发环境:

- 可以在和部署环境完全相同的操作系统中开发，或者使用更为强劲或特殊的硬件
- 开发环境沙箱化可以避免影响本地主机配置
- 更容易让那个新的开发者起步和保持一致的环境
- 使用的工具或者云心管ing不再受限雨本地操作系统，或者能够管理运行环境的多个版本
- 可以在云计算环境中开发Linux部署应用
- 可以在不同主机或环境下访问相同的开发环境
- 随时随地可以在客户站点或者云计算环境中调试运行程序

本地不需要任何源代码存储，在远程开发扩展包中的每个扩展都能够运行命令以及在容器或远程主机中直接使用，就好像本地运行一样。

.. figure:: ../../../_static/linux/desktop/vscode/vscode_remote_dev.png
   :scale: 60

.. note::

   另一种远程服务器上运行大型图形程序的方法是使用 :ref:`xpra` ，可以方便在远程服务器上调试和运行大型图形程序，并且网络断开也不影响服务器端运行

远程开发扩展包(Remote Development extension pack)
==================================================

`Remote Development extension pack <https://aka.ms/vscode-remote/download/extension>`_ 包含3个扩展:

- :ref:`vscode_remote_dev_ssh`
- :ref:`vscode_remote_dev_containers`
- `Remote - WSL <https://code.visualstudio.com/docs/remote/wsl>`_

.. note::

   我主要实践在 :ref:`priv_cloud_infra` 通过 :ref:`kvm` 和 :ref:`docker` 来完成，所以将实践上述:

   - :ref:`vscode_remote_dev_ssh`
   - :ref:`vscode_remote_dev_containers`

此外，微软还提供了 `vscode.dev <https://vscode.dev/>`_ SaaS服务(收费)， 实现浏览器中开发调试本地代码或者直接调试github中代码。不过，也有第三方开发了基于node.js部署的 :ref:`code-server` ，可以作为远程开发的平台。

:ref:`code-server`
============================

微软开发了一个 **闭源 (受官方许可协议约束)** 的 VS Code Server，能够让VC Code客户端远程连接进行服务器开发，而无需上述的ssh访问。虽然VS Code Server是微软官方开发的 **原生远程框架** ，将VS Code拆分成 "本地UI" 和 "远程Server"非常灵活，但是该VS Code Server只提供给 **个人** 远程调试自己的机器，而不是作为一个多租户(Multi-tenant)的PaaS平台。

根据微软官方许可协议，禁止将VS Code Server部署为PaaS服务!

开源社区通过逆向工程，基于VS Code的全开源版本(Code-OSS)构建了 ``code-server`` ，重新实现了一套Web包装层，绕过了微软的私有运行环境限制。所以，现在使用MIT开源协议的 :ref:`code-server` 可以被 :ref:`kubernetes` 编排，实现一人一个Pod，每个Pod跑一个 :ref:`code-server` 实现云开发环境。

参考
=========

- `VS Code Remote Development <https://code.visualstudio.com/docs/remote/remote-overview>`_
- `Remote Development tutorials <https://code.visualstudio.com/docs/remote/remote-tutorials>`_
