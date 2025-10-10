.. _metasploit_macos:

==========================
Metasploit macOS版本
==========================

在 `osx.metasploit.com <https://osx.metasploit.com/>`_ 提供了8个最新构建的macOS版本Metasploit，可以直接下载最新版本 `metasploitframework-latest.pkg <https://osx.metasploit.com/metasploitframework-latest.pkg>`_ 进行安装。

- 安装完成后需要将Metasploit执行目录添加到用户环境中(否则会提示找不到诸如 ``msfconsole`` 等):

.. literalinclude:: metasploit_macos/env
   :caption: 设置环境

- 首次启动 ``msfconsole`` 进行初始化:

.. literalinclude:: metasploit_macos/msfconsole
   :caption: 启动 ``msfconsole``

这里交互输入 ``yes`` 初始化一个 ``~/.msf4/db`` 数据库( :ref:`pgsql` 数据库)

.. literalinclude:: metasploit_macos/msfconsole_output
   :caption: 启动 ``msfconsole`` 输入 ``yes`` 初始化数据库
   :emphasize-lines: 4


参考
=====
