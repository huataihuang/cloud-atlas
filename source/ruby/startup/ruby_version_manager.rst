.. _ruby_version_manager:

=====================
Ruby版本管理器
=====================

在 `Download Ruby <https://www.ruby-lang.org/en/downloads/>`_ 官方下载页面介绍中可以知晓，除了Linux/UNIX发行版提供的Ruby安装包，另一种常用的Ruby安装方式是采用 ``Ruby版本管理器`` 安装:

- Ruby版本管理器就类似于 ``npm`` 之于 :ref:`javascript` ，可以在系统中安装不同版本的Ruby并提供切换能力，这样不同的应用可以采用不同的Ruby版本运行来满足特定需求
- 由于Ruby是不断发展的语言，所以编写的程序可能需要特定的Ruby版本运行，所以Ruby版本管理器非常适合这种场景
- 在多个Ruby应用程序的运行环境中，同一台服务器上可能需要不同的Ruby版本来支持不同的Ruby应用

目前常用的Ruby版本管理器有两种:

- RVM
- rbenv

这两个Ruby版本管理器工作原理不同，但是结果是相同的。

在Linux平台， ``RVM`` 被广泛接受为标准，很大程度上是因为它提供了广泛的toolkit(工具包)；但是， :ref:`rbenv` 凭借其轻量级的方法成为强有力的竞争者。

此外，在 :ref:`macos` 平台，由于系统内置了旧版本Ruby，会导致RVM存在一些问题，所以更推荐通过 :ref:`homebrew` 安装 :ref:`rbenv` 来管理Ruby版本。

Under the Hood(工作原理)
===========================

- ``RVM`` 通过覆盖 ``cd`` :ref:`shell` 命令来加载当前的Ruby环境变量。这种直接粗暴覆盖的风险是可能会导致意外行为，并且还意味着切换目录时会加载 ``ruby`` 以及 ``gemset`` 
- ``rbenw`` 则相对轻柔很多:

  - 在 ``PATH`` 的前面部分插入一个 ``~/.rbenv/shims`` (目录垫片, a directory of shims)
  - 在这个目录下保存了每个Ruby命令的 ``shim``
  - 操作系统搜索与命令名字匹配的 ``shim`` ，然后将其传递给 ``rbenv`` 来确定要执行的Ruby版本
  - 提供了一个 ``RBENV_VERSION`` 变量来快速指定Ruby默认版本(排在第一位)

.. _rvm:

RVM
=======

- 典型的 ``rvm`` 目录存储了不同的Ruby版本，类似:

.. literalinclude:: ruby_version_manager/rvm_dir
   :caption: 典型的 ``rvm`` 目录结构

- RVM的核心是一组目录，RVM在目录中储存了所有Ruby版本以及相关工具(gem和irb)，每个目录都针对特定的Ruby版本
- RVM定义了一个名为 ``rvm`` 的 :ref:`shell` 函数，这样shell会优先使用这个函数而不是执行磁盘中的 ``rvm`` 命令(原因是函数可以修改环境，但是基于磁盘的命令则不能)
- 当运行 ``rvm use VERSION`` 来修改Ruby版本时，实际上调用了 ``rvm`` 函数来修改环境，以便各种 ``ruby`` 命令调用正确的版本: 例如 ``rvm use 2.2.2`` 会修改 ``PATH`` 变量，以便使用 ``ruby`` 命令是使用安装在 ``ruby-2.2.2`` 目录中的 ruby (还有一些其他修改，但最主要是修改 ``PATH`` )

安装
------

- 参考官方文档 `Installing RVM <https://rvm.io/rvm/install>`_ 安装RVM:

.. literalinclude:: ruby_version_manager/rvm_install_ruby
   :language: bash
   :caption: 使用 ``rvm install`` 安装ruby
   :emphasize-lines: 4

安装完成后(我这里的案例是安装 ``master`` 分支，并且同时安装 :ref:`rails` )输出类似:

.. literalinclude:: ruby_version_manager/rvm_install_ruby_output
   :language: bash
   :caption: 使用 ``rvm install`` 安装ruby的输出信息

.. note::

   :ref:`ubuntu_linux` 发行版内置提供了 RVM

.. warning::

   ``get.rvm.io`` 实际上是 ``raw.githubusercontent.com`` 重定向，所以在墙内是无法直接执行上述安装脚本的。解决的方法是使用 :ref:`curl_proxy` 结合 :ref:`ssh_tunneling` (socks代理) 或者 :ref:`squid_socks_peer` ，总之，需要 "梯子"

使用
------

安装多版本ruby
~~~~~~~~~~~~~~~

- 检查系统已经安装的ruby版本:

.. literalinclude:: ruby_version_manager/rvm_list
   :caption: 使用 ``rvm list`` 列出系统中已经安装的ruby版本

输出信息:

.. literalinclude:: ruby_version_manager/rvm_list_output
   :caption: 使用 ``rvm list`` 列出系统中已经安装的ruby版本，输出案例

- 安装特定版本(举例 3.1.4 这里选择 3.1.4 是因为当前Gentoo官方提供的安装包就是选择3.1.4，我想既然我安装了最新版本的3.3.0，那么也有必要安装一下主流stable版本):

.. literalinclude:: ruby_version_manager/rvm_install_special_version
   :caption: 使用 ``rvm install`` 安装指定版本 Ruby

- 再次检查系统已经安装的ruby版本( ``rvm list`` )，就会发现当前有2个版本已经完成安装:

.. literalinclude:: ruby_version_manager/rvm_list_output_multi
   :caption: 使用 ``rvm list`` 列出系统中已经安装的ruby版本，可以看到刚安装的 3.1.4 被设置为当前版本，默认版本则是 3.3.0
   :emphasize-lines: 1,2

设置当前ruby版本
~~~~~~~~~~~~~~~~~

- ``rvm use XXXX`` 可以指定当前会话的ruby版本，以下为将当前版本3.1.4切换到3.3.0:

.. literalinclude:: ruby_version_manager/rvm_use
   :caption: ``rvm use`` 用于切换当前会话的ruby版本，也可以指定默认版本 ( ``--default`` )

此时检查 ``rvm list`` 可以看到输出已经是采用 3.3.0 版本:

.. literalinclude:: ruby_version_manager/rvm_use_output
   :caption: ``rvm use`` 切换版本到3.3.0后检查 ``rvm list`` 输出
   :emphasize-lines: 2

.. note::

   设置完成后检查 ``env`` 输出信息就可以看到 ``RVM`` 修改了用户的环境变量 ``PATH`` ::

      PATH=/home/admin/.rvm/gems/ruby-3.3.0/bin:/home/admin/.rvm/gems/ruby-3.3.0@global/bin:/home/admin/.rvm/rubies/ruby-3.3.0/bin:/home/admin/.rvm/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/opt/bin

设置项目使用的ruby版本
-----------------------

在Ruby程序的项目目录下执行 ``rvm --ruby-version use XXX`` 指定版本后， ``RVM`` 会在当前的项目目录下创建一个 ``.ruby-version`` 文件，这个文件内容就是项目期望的ruby版本。这样就不需要每次为项目通过 ``rvm use`` 来切换Ruby了:

.. literalinclude:: ruby_version_manager/rvm_project_use
   :caption: 为ruby项目指定ruby版本
   :emphasize-lines: 6

此时检查项目当前目录，会看到一个 ``.ruby-version`` 文件，内容哥就是指定的ruby版本:

.. literalinclude:: ruby_version_manager/rvm_project_use_output
   :caption: 为ruby项目指定ruby版本，项目当前目录下增加一个 ``.ruby_version`` 文件包含版本信息

现在来演练一下，先离开项目目录，执行 ``ruby --version`` 就会看到默认的ruby版本3.3.0，当重新回到该项目目录，则 ``ruby --version`` 就立即显示(切换)成该目录下 ``.ruby-version`` 指定的版本:

.. literalinclude:: ruby_version_manager/ruby_version_with_project_dir
   :caption: 随着进入和离开ruby项目目录，默认的ruby版本会跟随切换
   :emphasize-lines: 5,10,15
   
.. note::

   ``RVM`` 通过在目录下创建一个 ``.ruby-version`` 文件(内容是ruby版本，类似于Python的 requirements.txt)。则每次用户进入该目录，则 ``ruby`` 版本会自动切换到 ``.ruby-version`` 文件指定的版本。这样就避免用户反复手工设置调整 ``RVM`` 指定ruby版本(也很容易忘记)。

   实现的原理是 ``RVM`` 将shell中的 ``cd`` 命令替换成 shell 函数，该函数调用真正的 ``cd`` 命令，然后检查 ``.ruby-version`` 文件是否存在，如果存在，则从该文件检索版本号，并以 ``rvm`` 函数相同的方式修改环境变量以正确运行Ruby版本。

- 通过 ``rvm info rvm`` 命令可以获取 ``RVM`` 详细的信息:

.. literalinclude:: ruby_version_manager/rvm_info_rvm
   :caption: 执行 ``rvm info rvm`` 可以获得RVM详细信息

在不同目录下，注意 ruby 版本不同(项目目录下有 ``.ruby-version`` 配置文件):

.. literalinclude:: ruby_version_manager/rvm_info_rvm_output
   :caption: 执行 ``rvm info rvm`` 可以获得RVM详细信息

- 简单的 ``rvm info`` 命令可以输出系统的详细信息:

.. literalinclude:: ruby_version_manager/rvm_info_output
   :caption: 执行 ``rvm info`` 可以获得完整的RVM相关(包含ruby)信息

RVM的困扰
------------

``RVM`` 实际上比较复杂(shell函数代替了shell命令)，有时候会出现异常:

- 需要 **确保目录名称不包含任何空格** ，也包括上级目录: ``RVM`` 当前不支持带空格的目录名称
- ``type cd | head -1 ; type rvm | head -1``  可以看到 ``cd`` 和 ``rvm`` 都是shell函数 **如果输出不是如下内容，则表明RVM的shell设置出现了问题** ::

   cd is a function
   rvm is a function

- ``echo $PATH`` 确保 ``{RVM PATH}/rubies-{VERSION}/bin`` 和 ``{RVM PATH}/gem/rubies-{VERSION}/bin`` 已经设置在 ``PATH`` 环境变量中。并且比其他目录(可能包含相同程序名)列在前面

- 其他检查信息的方法:

.. literalinclude:: ruby_version_manager/rvm_check
   :caption: ``rvm`` 检查信息的方法列表

Uninstall RVM
---------------

``RVM`` 提供了一个自己卸载的方法:

.. literalinclude:: ruby_version_manager/rvm_implode
   :caption: ``RVM`` 卸载

输出显示:

.. literalinclude:: ruby_version_manager/rvm_implode_output
   :caption: ``RVM`` 卸载
   :emphasize-lines: 4

只需要输入 ``yes`` 就能自动完成，必要时按照提示手工移除 ``~/.rvm`` 目录

.. _rbenv:

rbenv
==========

- 典型的 ``rbenv`` 目录结构:

.. literalinclude:: ruby_version_manager/rbenv
   :caption: ``rbenv`` 的典型目录结构

- ``rbenv`` 的核心是一组与 ``RVM`` 核心目录非常相似的目录
- 然而，在底层， ``rbenv`` 管理 ``Rubies`` 的方式与 ``RVM`` 的管理方式有很大不同:

  - ``rbenv`` 不是直接修改用户的 ``PATH`` 环境变量，而是在用户 ``PATH`` 中插入一组 ``shims`` 小脚本，类似于包装
  - 当运行 ``ruby`` 或 ``Gems`` 时，系统会执行 ``shim`` 脚本，然后 ``shim`` 脚本会依次执行 ``rbenv exec PROGRAM`` ，该命令确定应该使用哪个版本的Ruby

- ``rbenv`` 的优点是:

  - 可以在任何类Unix系统的任何shell中工作，唯一依赖是 :ref:`bash` 解释器
  - ``rbenv`` 只完成最低限度工作，其余部分留给插件生态系统

- ``rbenv`` 的缺点是:

  - 由于 ``rbenv`` 会拦截对 ruby 的每次调用，因此它可能会给 ruby 执行时间增加约 ``50 毫秒的开销`` ，对于速度至关重要的时候可能会导致问题
  - 由于 ``rbenv`` 在项目之间严格版本隔离，可能会导致难以保留"全局"(系统级)Ruby工具调用，并且无法简单从一个Ruby版本的项目直接 ``shell out`` 到另外一个Ruby版本的脚本
  - 无法感知安装到用户主目录的 ``gems`` : ``rbenv`` 无法阿发现使用 ``--user-install`` 安装的 ``gems`` 可执行文件，即安装在 ``~/.gem`` 或者 ``~/.local/share/gem`` 目录下的可执行文件(解决方法是避免依赖 ``rbenv`` 管理项目中的这些 ``gem`` 或者手动将相应的 ``~/.local/share/gem/<engine>/<version>/bin`` 添加到路径中)

安装
-------

- 在 :ref:`macos` 中使用 :ref:`homebrew` 安装 ``rbenv`` :

.. literalinclude:: ruby_version_manager/rbenv_install
   :caption: 在 :ref:`macos` 中使用 :ref:`homebrew` 安装 ``rbenv``

根据安装执行的 ``rbenv init`` 输出信息(以下是macOS Big Sur环境的zsh SHELL实行输出案例:

.. literalinclude:: ruby_version_manager/rbenv_install_output
   :caption: 在 :ref:`macos` zsh环境中中执行 ``rbenv init`` 输出提示

按提示在 ``~/.zshrc`` 中添加:

.. literalinclude:: ruby_version_manager/zshrc
   :caption: 添加 :ref:`macos` zsh环境变量( ~/.zshrc )




然后关闭当前终端窗口，并再次打开新终端窗口，则此时修改生效

- 另一种安装方式是使用git从官方源代码检出，然后配置shell环境:

.. literalinclude:: ruby_version_manager/rbenv_git_install
   :caption: 通过git方式源代码安装rbenv

使用
-----------

- ``rbenv`` 基本使用:

.. literalinclude:: ruby_version_manager/rbenv_use
   :caption: ``rbenv`` 基本使用

容器时代
===========

通过简单的尝试，我感觉:

- 如果在Linux平台为自己的部署开发环境，例如我采用 :ref:`gentoo_image` 运行 :ref:`gentoo_on_gentoo` ，那么使用 :ref:`rvm` 非常方便，也能够用于小型项目生产环境
- 如果在 :ref:`macos` 环境使用 :ref:`homebrew` 管理，那么 :ref:`rbenv` 或许是更方便的方式，不过按照官方文档，对于生产环境大压力需要考虑 ``rbenv`` 包装脚本的细微性能损失

现在随着容器技术的不断普及，生产和开发测试环境也大量使用容器，实际上对于Ruby应用，需要通过ruby版本管理器来区分和切换ruby版本的需求大为降低:

- 容器天然分隔了不同的应用程序运行环境
- 每个容器都有自己独立的定制版本，界面清晰
- 轻量级的容器(非 "富容器")资源占用低，无版本干扰且必定是准确配置ruby版本

所以后续在容器化运行，乃至 :ref:`kubernetes` 化运行Ruby应用，可以替代本文的ruby版本管理器。

参考
======

- `Ruby Version Managers <https://launchschool.com/books/core_ruby_tools/read/ruby_version_managers>`_
- `GitHub: rbenv/rbenv >> Comparison of version managers <https://github.com/rbenv/rbenv/wiki/Comparison-of-version-managers>`_
- `Choosing a Ruby Version Management Tool: rbenv vs RVM <https://metova.com/choosing-a-ruby-version-management-tool-rbenv-vs-rvm/>`_
