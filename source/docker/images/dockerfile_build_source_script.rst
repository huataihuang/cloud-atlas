.. _dockerfile_build_source_script:

==============================
在Dockerfile脚本中source脚本
==============================

我在构建 :ref:`debian_tini_image` 时，尝试使用 :ref:`rvm` 方式来安装一个ruby运行环境。简单来说，在通常服务器上执行以下命令来使用 ``rvm`` :

.. literalinclude:: ../../ruby/startup/ruby_version_manager/rvm_install_ruby_rails
   :caption: 安装rvm，并通过rvm安装ruby和RoR

当我将上述命令嵌入到 Dockerfile :

.. literalinclude:: dockerfile_build_source_script/Dockerfile_source
   :language: dockerfile
   :caption: 最初直接使用rvm安装命令嵌入到Dockerfile
   :emphasize-lines: 4-6

Dockerfile使用 ``/bin/sh`` 执行
================================

首先遇到的错误是执行 ``source`` 指令报错:

.. literalinclude:: dockerfile_build_source_script/source_err
   :caption: ``/bin/sh`` 不支持 ``source`` (bash) 内置指令
   :emphasize-lines: 4,10

原因是Dockerfile是使用 ``/bin/sh`` 来执行的，这个 ``sh`` SHELL不支持 BASH 中常用的内置指令 ``source`` ，需要改成 ``.``

不过后面又遇到一个问题 ``rvm`` 脚本需要 ``bash`` 的 ``builtin`` 工具，使用 ``/bin/sh`` 会报错。见下文

Dockerfile每个 ``RUN`` 命令都是一个独立的容器
=================================================

接下来的报错是，即使使用了 ``.`` 来引入 ``rvm`` 脚本，但是在下一个命令中使用 ``rvm`` 却找不到指令:

.. literalinclude:: dockerfile_build_source_script/rvm_err
   :caption: 由于Dockerfile每个RUN命令都是一个容器，所以下一步命令找不到 ``rvm``
   :emphasize-lines: 11,15

原因是每个 ``RUN`` 命令实际上是一个容器，所以下一个命令是无法看到上一个命令的引入环境变量或者脚本的

尝试 ``.`` 引入环境和运行指令在一行 ``RUN``
-----------------------------------------------

我尝试改动了一下Dockerfile:

.. literalinclude:: dockerfile_build_source_script/Dockerfile_oneline
   :language: dockerfile
   :caption: 将 ``.`` 引入脚本和后续执行命令合并成一行

这样解决问题了么？

还有报错:

.. literalinclude:: dockerfile_build_source_script/Dockerfile_oneline_err
   :caption: 出现新的报错显示 ``rvm`` 脚本执行时没有找到 ``buildin``
   :emphasize-lines: 4

这里可以看到BASH内置的 ``buildin`` 工具不能被 ``/bin/sh`` 支持

解决之道: 使用 ``bash -c``
----------------------------

既然 :ref:`rvm` 必须使用BASH，而且BASH又可以使用习惯的 ``source`` 指令，那么最终的解决方法是:

- 在 RUN 中使用 ``bash -c 'xxx && yyy && zzz'`` 来完成BASH运行环境
- 并且在一行中使用多个命令，确保共享了同一个运行SHELL环境

改进后验证成功的Dockerfile:

.. literalinclude:: dockerfile_build_source_script/Dockerfile
   :language: dockerfile
   :caption: 最终改进成一行运行多个指令，并且使用 ``bash -c`` 运行确保环境共享
   :emphasize-lines: 10

参考
======

- `How to source a script with environment variables in a docker build process? <https://stackoverflow.com/questions/55921914/how-to-source-a-script-with-environment-variables-in-a-docker-build-process>`_
- `Need for the 'builtin' builtin <https://unix.stackexchange.com/questions/427683/need-for-the-builtin-builtin>`_
