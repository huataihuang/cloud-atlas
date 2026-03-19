.. _freebsd_vscode:

========================
FreeBSD平台VSCode
========================

虽然微软没有直接为FreeBSD提供预编译的二进制包，但是社区通过 :ref:`linuxulator` 兼容层 和 原生移植版(OSS版)解决了这个问题。

推荐使用原生移植版本呢(vscode-oss)，性能更好，并且能够顺畅访问FreeBSD网络栈。但是，由于package builder屏蔽了Electron，而这个Electron是VSCode的依赖，所以导致 ``pkg install vscode`` 目前无法直接执行来安装二进制包。

.. note::

   由于VS Code使用的Electron构建过程需要通过 ``npm`` 或脚本去GitHub/Google存储库动态下载成败上千个依赖包(如Node模块，Chromium源码片段。这种方式要求构建过程必须联网。

   而FreeBSD官方Package构建机制是在一个物理隔绝、禁止访问外部网络的Jail环境中运行的，以确保二进制是安全且可以复现的。

   Electron深度集成了Chromium，包含了一些受版权保护或分发受限的代码(如某些视频编码解码器)。官方Package库为了规避法律风险，有时会拒绝分发包含模糊和艘券的代码且无法通过脚本完全剥离的"全家桶"软件。

   此外，Electron/Chromium编译极度消耗资源，常常阻塞其他软件包更新。

   综上，FreeBSD的包关系系统已经从自动化流水线剔除了Electron。

不过，对于个人而言，由于编译过程通常是联网的，并且Ports维护者编写了大量的补丁，将Electron原先针对Linux的调用重定向到FreeBSD的系统调用(例如将epool修改为kqueue)，这些补丁在实时编译时生效。并且Ports系统会在本地主机先构建好匹配FreeBSD 15架构的特定版Node.js和Python环境，然后再以此为基础构建VS Code。

- 编译VS Code

.. literalinclude:: freebsd_vscode/install
   :caption: 在FreeBSD上安装vscode-oss

.. warning::

   为了能够保持我本地笔记本FreeBSD环境简洁高效，我放弃安装VS Code，准备后续采用 :ref:`freebsd_vscode_code-server` 来远程使用VS Code。

   另外，考虑到轻量级开发能够支持 :ref:`ollama` 提供AI辅助编程，我选择 :ref:`helix` 作为后续的开发IDE

参考
=====

- `vscode Visual Studio Code - Open Source ("Code - OSS") <https://www.freshports.org/editors/vscode/>`_
- `How to use VS Code on FreeBSD <https://freebsdfoundation.org/resource/how-to-use-vs-code-on-freebsd/>`_
