.. _git_config:

=====================
git配置
=====================

``git config`` 命令可以方便用于配置Git配置变量，并且可以在全局或本地项目范围配置。这些变量配置对应了 ``.gitconfig`` 文本，执行 ``git config`` 将修改配置文件。通常我们需要设置用户名，电子优点等。

快速配置
=========

简单来说，对于个人开发者，刚上手git的工作环境简单配置如下:

.. literalinclude:: git_config/git_config_init
   :caption: 简单的初始化git配置

提交人信息
=============

最基本的 ``git config`` 配置变量是使用 ``.`` 分隔的配置变量名， ``.`` 符号前面是 ``section`` 后面是 ``key`` ，例如 ``user.email`` ::

   git config user.email

配置级别:

- ``--local`` 本地级别只影响当前仓库，配置存放在当前仓库 ``.git/config`` 中
- ``--global`` 全局级别配置存储在用户目录下 ``~/.gitconfig``
- ``--system`` 系统级别配置作用域整个主机，配置存储在 ``$(prefix)/etc/gitconfig``

举例::

   git config --global user.email "your_email@example.com"

``core.editor``
==================

大多数Git命令会加载一个文本编辑器来进行输入，需要配置 ``git config`` 的 ``core.editor`` 来指定编辑器。我使用 ``vim`` ::

   git config --global core.editor "vim"

``merge.tools``
==================

当发生合并冲突是，git会加载一个 ``merge tool``，默认使用内置当Unix ``diff`` 工具。不过这个工具比较简单，可能不如第三方工具更为直观。可以配置第三方合并工具，例如 ``kdiff3`` ::

   git config --global merge.tool kdiff3

``alias`` (别名)
==================

git提供了一个方便命令别名方式，用于缩短输入，例如::

   git config --global alias.ci commit

则执行::

   git ci

相当于执行::

   git commit

而且还支持命令别名的别名::

   git config --global alias.amend ci --amend

则执行::

   git amend

相当于::

   git commit --amend

参考
======

- `git config <https://www.atlassian.com/git/tutorials/setting-up-a-repository/git-config>`_
