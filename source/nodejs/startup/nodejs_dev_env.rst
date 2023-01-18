.. _nodejs_dev_env:

=====================
Node.js开发环境
=====================

`Node Version Manager (nvm) <https://github.com/nvm-sh/nvm>`_ 是 node.js 的版本管理器，可以工作在任何 POSIX兼容的shell环境，运行于unix, macOS 和 Windoes WSL。

这个工具可以管理和切换 Node.js 版本，以便测试和开发。 （例如，我在使用 `hexo <https://hexo.io>`_ 作为自己的blog撰写平台，就遇到过部分插件对nodejs版本的兼容性要求）

.. note::

   对于node.js没有多版本要求的话，可以使用最新node.js版本，并且为了方便开发，可以采用 :ref:`fedora_dev_nodejs` 。目前，我的开发学习环境就建立在 :ref:`fedora` 。

.. _install_nvm:

安装nvm
==========

- 执行安装脚本:

.. literalinclude:: nodejs_dev_env/install_nvm
   :language: bash
   :caption: 安装nvm

上述命令脚本将clone一个nvm代码仓库到 ``~/.nvm`` ，并尝试在profile环境中加入一下内容(我手工加到 ``~/.zshrc`` )::

   export NVM_DIR="$HOME/.nvm"
   [ -s "$NVM_DIR/nvm.sh"  ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
   [ -s "$NVM_DIR/bash_completion"  ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

.. note::

   也可以下载脚本再进行安装(主要原因是nvm脚本仓库网站被GFW屏蔽了， :strike:`下载以后再安装就可以绕过这个问题` )::

      curl -sL https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.2/install.sh -o install_nvm.sh

   不过，如果GFW阻塞了安装，还是要找一个能够正常访问internet的主机安装好 ``nvm`` 之后，把整个 ``~/.nvm`` 复制到目标运行主机上再执行 ``nvm install node --lts`` (nodejs官方网站没有被屏蔽，所以可以正常安装) 

- 然后执行命令 ``nvm`` 可以看到输出就是正常完成了安装(注意，使用 ``which nvm`` 是看不到该命令的)

.. _nvm_install_nodejs:

安装node.js
==============

- 安装最新版本node:

.. literalinclude:: nodejs_dev_env/nvm_install_nodejs
   :language: bash
   :caption: nvm安装node.js

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

版本兼容性
==============

2022年，Node.js官方提供的LTS版本都已经不再支持 :ref:`redhat_linux` 的CentOS 7系列了，原因是CentOS 7的glibc库停留在 2.17 版本，运行 ``node`` 命令会提示信息::

   $ node --version
   node: /lib64/libm.so.6: version `GLIBC_2.27' not found (required by node)
   node: /lib64/libc.so.6: version `GLIBC_2.25' not found (required by node)
   node: /lib64/libc.so.6: version `GLIBC_2.28' not found (required by node)
   node: /lib64/libstdc++.so.6: version `CXXABI_1.3.9' not found (required by node)
   node: /lib64/libstdc++.so.6: version `GLIBCXX_3.4.20' not found (required by node)
   node: /lib64/libstdc++.so.6: version `GLIBCXX_3.4.21' not found (required by node)

参考 `node: /lib64/libm.so.6: version 'GLIBC_2.27' not found (required by node) #2972 <https://github.com/nvm-sh/nvm/issues/2972>`_ ，只能安装 node.js 17.x 系列版本( < 18 ) 。根据 ``nvm ls-remote1`` 提示 ``v16.19.0   (Latest LTS: Gallium)`` ，安装 ``16.19.0`` ::

   nvm install 16.19.0

验证安装
==========

- 简单的 ``hello.js`` ::

   console.log("hello from Node");

- 执行::

   node hello.js

输出显示::

   hello from Node

开发和部署
============

在 :ref:`patternfly` 开发，结合 :ref:`nginx` 部署: :ref:`nginx_reverse_proxy_nodejs`

参考
========

- `GitHub nvm README.md <https://github.com/nvm-sh/nvm>`_
- `Installing Node.js via package manager <https://nodejs.org/en/download/package-manager/>`_
- `How To Install Node.js on Ubuntu 20.04 <https://www.digitalocean.com/community/tutorials/how-to-install-node-js-on-ubuntu-20-04>`_
