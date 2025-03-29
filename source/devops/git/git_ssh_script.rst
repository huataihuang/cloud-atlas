.. _git_ssh_script:

=======================
git SSH操作脚本
=======================

在脚本中使用git，需要面对和解决以下问题:

- 避免面对新的git仓库服务器时需要交互确认接受HOST主机密钥(例如从github clone，首次操作需要交互确认接受)
- 不同的git服务器可能使用了不同的密钥对，通常出于安全，不会把主密钥的公钥用于git仓库，而是生成不同的密钥对用于不同的生产git仓库

.. note::

   我在 :ref:`debian_tini_image` 实践中，使用了本文方法来解决Dockerfile中执行 git SSH 的问题

命令行
==========

解决方法是定制 ``core.sshCommand`` 命令参数:

.. literalinclude:: git_ssh_script/git_core.sshCommand
   :caption: 通过定制SSH命令来确保项目(命令需要在git目录下)使用了特定密钥，并且忽略HOST主机密钥确认(可选，仅用于脚本)

配置方法
============

更为灵活的配置，是在 ``~/.ssh/config`` 中添加:

.. literalinclude:: git_ssh_script/ssh_config
   :caption: 在 ``~/.ssh/config`` 配置指定git密钥以及忽略主机密钥确认
   :emphasize-lines: 3-4

参考
=======

- `How to configure command line git to use ssh key <https://stackoverflow.com/questions/23546865/how-to-configure-command-line-git-to-use-ssh-key>`_
