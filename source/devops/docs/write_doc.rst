.. _write_doc:

=============
写文档
=============

Vim设置
==========

为了方便使用vim进行文档撰写和编写代码，请参考 `使用vim作为macos平台的IDE <https://github.com/huataihuang/cloud-atlas-draft/blob/master/develop/vim/using_vim_as_ide_in_macos.md>`_ 中我的实践，这是一个非常快捷初始化工作环境的方法::

   git clone --depth=1 https://github.com/amix/vimrc.git ~/.vim_runtime
   sh ~/.vim_runtime/install_awesome_vimrc.sh

.. note::

   默认开启了代码折叠功能，但是我觉得非常不好用，所以设置 `~/.vimrc` 默认关闭:

      set foldlevelstart=99

Python Virtualenv
===================

.. note::

   如果是Linux环境，请参考 `在CentOS上安装 Python3 virtualenv <https://github.com/huataihuang/cloud-atlas-draft/blob/master/develop/python/startup/install_python_3_and_virtualenv_on_centos.md>`_

macOS安装
----------

早期版本(需要安装python3)
~~~~~~~~~~~~~~~~~~~~~~~~~~

- 安装 `Homebrew <https://brew.sh>`_ ::

   /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

- 如果使用一段时间可能需要升级Homebrew::

   brew upgrade

- 通过Homebrew安装Python3 ::

   brew install python3

如果系统中已经安装过python3，则可能会提示::

   Warning: python@3.9 3.9.6 is already installed, it's just not linked.

则执行创建链接::

   brew link python@3.9

如果之前已经有软链接存在，可以使用强制覆盖::

   brew link --overwrite python@3.9

.. note::

   安装在目录 ``/usr/local/bin/pyton3`` ，执行时使用 ``python3``

- 升级pip版本::

   sudo -H pip3 install --upgrade pip

- 安装virtualenv ::

   sudo -H pip3 install virtualenv

现在(高版本 :ref:`macos` 内置python3)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

现在最新的 :ref:`macos` 内置的开源软件已经接近追平Linux，内置了 python3.9.6 ，同时提供了 ``pip3`` ，所以构建 :ref:`virtualenv` 非常容易。

.. noge::

   不过我为了统一环境，还是采用 :ref:`homebrew` 完成安装

Arch Linux安装
-----------------

Arch Linux默认安装了Python3，所以仅需要安装pip::

   sudo pacman -S python-pip

安装virtualenv::

   sudo pacman -S python-virtualenv

Ubuntu Linux安装
---------------------

Ubuntu Linux现在默认安装了Python3，所以也仅安装pip::

   sudo apt install python3-pip

安装virtualenv::

   sudo apt install python3-venv

设置virtualenv
----------------

- 创建工作目录下的Python 3 Virtualenv:

.. literalinclude:: ../../python/startup/virtualenv/venv
   :language: bash
   :caption: venv初始化

- 使用Virtualenv (每次使用Python3 Virtualenv之前要激活，后续所有基于文档撰写都使用此环境) :

.. literalinclude:: ../../python/startup/virtualenv/venv_active
   :language: bash
   :caption: 激活venv

Sphinx Doc
============

- 安装Sphinx 以及 rtd :

.. literalinclude:: write_doc/install_sphinx_doc
   :language: bash
   :caption: 通过virtualenv的Python环境安装sphinx doc

- 初始化和创建sphinx文档项目::

   mkdir cloud-atlas
   cd cloud-atlas
   sphinx-quickstart

接下来就是文档撰写了，撰写在 ``source`` 目录下，结构请参考 `我的云图项目 <https://github.com/huataihuang/cloud-atlas>`_

.. note::

   Sphinx撰写时经常需要引用代码片段，请参考 `sphinx插入代码 <https://www.cnblogs.com/youxin/p/3653027.html>`_ 和 `展示示例代码 <https://zh-sphinx-doc.readthedocs.io/en/latest/markup/code.html>`_

- 撰写文档之后，通过以下命令生成html和epub最终文档(使用epub方便分发和移动设备阅读)::

   make html
   make epub

.. note::

   我发现epub不支持html中的一些图片格式，例如 ``.webp`` 和 ``.dms`` 图片，所以建议转换成 ``.png`` 格式较为通用，方便生成epub文件。

MkDoc
=========

- 继承已经安装部署的Python3 Virtualenv环境，安装 mkdocs ::

   pip install mkdocs
   pip install mkdocs-material

.. note::

   采用Google Material Design风格的theme `Material for MkDocs <https://squidfunk.github.io/mkdocs-material/>`_

- 创建项目::

   mkdocs new works
   cd works

在项目目录下有一个 ``mkdocs.yml`` 配置文件，修订::

   site_name: 我的工作
   nav:
     - Home: index.md
     - About: about.md
   theme: 'material'

- 启动服务::

   mkdocs serv

然后撰写的文档可以通过 http://127.0.0.1:8000 看到实时更新

- 如果要build文档::

   mkdocs build

.. note::

   如果你想看看mkdocs的网站案例，可以参考一下 `Argo CD 官方文档 <https://argoproj.github.io/argo-cd/>`_ ，提供了一个生动形象的 `Argo CD 手册案例 <https://github.com/argoproj/argo-cd/blob/master/mkdocs.yml>`_ 。

GitBook
===========

- 安装 nvm 来管理node.js版本 ::

   curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.35.2/install.sh | bash

.. note::

   安装脚本会在用户目录下的shell profile文件中添加加载nvm的配置，但是如果用户目录下没有任何profile，则添加会失败。所以建议至少要touch一个空的profile，或者类似我在macOS环境下使用zsh，采用 `oh-my-zsh <https://github.com/robbyrussell/oh-my-zsh>`_ 先生成环境配置::

      sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"

   然后再执行上述按章nvm的脚本。

- 使用 nvm 安装node.js稳定版::

   nvm install stable

- 使用npm安装Gitbook::

   npm install gitbook-cli -g
   npm install gitbook -g

.. note::

   如果要升级版本，可以采用::

      npm update -g
      gitbook update

- 安装插件disques::

   npm install react react-dom react-disqus-thread gitbook-plugin-disqus -g

- 初始化目录::

   gitbook init cloud-atlas-draft

- 在生成的 `cloud-atlas-draft` 目录下创建配置文件 `book.json` 配置启用插件::

   {
     "plugins": ["disqus"],
     "pluginsConfig": {
       "disqus": {
         "shortName": "huatai-gitbooks"
       }
     }
   }

.. note::

   这里 `shortName` 是你在disqus 网站上申请的论坛名称，将附加到你的gitbook上。

- 请参考我的文档项目 `Cloud Atlas 草稿 <https://github.com/huataihuang/cloud-atlas-draft>`_ ，关键文件是 `SUMMARY.md` ，用于生成文档导航，引用的就是markdown格式的文档。

- 编译::

   gitbook build ./ --log=debug --debug

或者使用::

   gitbook build ./ --timing

可以debug编译的过程以及每个文档的时间，这样容易发现存在问题的文档。

- 直接将内容推送到github仓库，并在gitbook官方网站上连接github仓库，就可以在推送github仓库时自动生成gitbook网站的书籍文档。

Markdown和reStructuredText转换格式
===================================

同时使用gitbook和sphinx撰写文档就有一个困扰，两者使用的文档格式不同，有时候需要互相转换。这时候就需要强大的开源工具 ``pandoc`` 。

首先通过Homebrew安装pandoc::

   brew install pandoc

然后就可以使用如下命令转换格式(案例是markdown转换成rst)::

   pandoc --from=markdown --to=rst --output=README.rst README.md

参考
=========

- `使用vim作为macOS的IDE <https://github.com/huataihuang/cloud-atlas-draft/blob/master/develop/vim/using_vim_as_ide_in_macos.md>`_
- `在macOS上安装Python3 virtualenv <https://github.com/huataihuang/cloud-atlas-draft/blob/master/develop/python/startup/install_python_3_and_virtualenv_on_macos.md>`_
- `使用Sphinx撰写python文档 <https://github.com/huataihuang/cloud-atlas-draft/blob/master/develop/doc/sphinx/sphinx_for_python_doc.md>`_
- `Arch Linux社区文档 - Python/Virtual environment <https://wiki.archlinux.org/index.php/Python/Virtual_environment>`_
- `Converting Markdown to reStructuredText <https://bfroehle.com/2013/04/26/converting-md-to-rst/>`_
- `python3 + virtualenv + ubuntu <https://naysan.ca/2019/08/05/install-python-3-virtualenv-on-ubuntu/>`_
