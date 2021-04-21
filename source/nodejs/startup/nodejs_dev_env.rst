.. _nodejs_dev_env:

=====================
Node.js开发环境
=====================

Node Version Manager (nvm) 是 node.js 的版本管理器，可以工作在任何 POSIX兼容的shell环境，运行于unix, macOS 和 Windoes WSL。

这个工具可以管理和切换 Node.js 版本，以便测试和开发。 （例如，我在使用 `hexo <https://hexo.io>`_ 作为自己的blog撰写平台，就遇到过部分插件对nodejs版本的兼容性要求）

安装nvm
==========

- 执行安装脚本::

   curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.38.0/install.sh | bash

上述命令脚本将clone一个nvm代码仓库到 ``~/.nvm`` ，并尝试在profile环境中加入一下内容(我手工加到 ``~/.zshrc`` )::

   export NVM_DIR="$HOME/.nvm"
   [ -s "$NVM_DIR/nvm.sh"  ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
   [ -s "$NVM_DIR/bash_completion"  ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

- 然后执行命令 ``nvm`` 可以看到输出就是正常完成了安装

安装node
==========

- 安装最新版本node::

   nvm install node

默认安装的版本就是current最新版本，输出类似::

   Downloading and installing node v15.5.1...
   Downloading https://nodejs.org/dist/v15.5.1/node-v15.5.1-darwin-x64.tar.xz...
   ######################################################################### 100.0%
   Computing checksum with shasum -a 256
   Checksums matched!
   Now using node v15.5.1 (npm v7.3.0)

- ``nvm`` 支持在系统中安装多个Node.js版本，例如我们可以同时安装稳定版本，并做切换。我们可以检查所有版本进行选择::

   nvm ls-remote

输出类似::

   ...
          v14.14.0
          v14.15.0   (LTS: Fermium)
          v14.15.1   (LTS: Fermium)
          v14.15.2   (LTS: Fermium)
          v14.15.3   (LTS: Fermium)
          v14.15.4   (Latest LTS: Fermium)
           v15.0.0
           v15.0.1
           v15.1.0
           v15.2.0
           v15.2.1
           v15.3.0
           v15.4.0
           v15.5.0
   ->      v15.5.1

上述可以看到，我们已经安装了最新版本 ``v15.5.1`` ，而当前稳定版本是 ``v14.15.4`` (LTS) ，所以我们可以

- 指定指定S版本::

   nvm install 14.15.4

- 安装LTS版本::

   nvm install --lts

- 检查已经安装的版本::

   nvm ls

- 我们可以在运行时指定我们需要运行的node版本，这样很容易进行切换测试::

   nvm exec --lts node --version

则可以看到系统切换到LTS版本执行::

   Running node latest LTS -> v14.15.4 (npm v6.14.10)
   v14.15.4

执行结束之后，还会回到默认版本(这里就是current版本 v15.5.1)。

- nvm支持将子shell切换到指定版本(这样后续只要子shell没有关闭，就一直是指定版本)::

   nvm use node --lts

此时看到切换到v14.15.4 LTS版本::

   Now using node v14.15.4 (npm v6.14.10)

由于处于子shell中，接下来没有指定node版本就会一直使用LTS版本

- 要在shell中使用默认的Node版本，使用别名 ``default`` ::

   nvm alias default 14.15.4

则默认切换到使用 ``v14.15.4`` 
   

参考
========

- `GitHub nvm README.md <https://github.com/nvm-sh/nvm>`_
