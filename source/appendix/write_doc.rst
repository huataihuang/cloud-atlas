.. _write_doc:

=============
写文档
=============

正如我在撰写 :ref:`cloud_atlas` ，文档是我梳理知识和想法最好的方式。我采用以下方式撰写文档:

- Sphinx Doc
- MkDocs
- GitBook

GitBook是我最早撰写 :ref:`cloud_atlas` 的 `Cloud Atlas 草稿 <https://github.com/huataihuang/cloud-atlas-draft>`_ 时使用的文档撰写平台。但我感觉GitBook采用Node.js来生成html，效率比较低，对于大量文档生成非常缓慢。所以我仅更新源文件，很少再build生成最终的html文件。

Sphinx Doc是我撰写 :ref:`cloud_atlas` 的文档平台，我是模仿Kernel Doc的结构来撰写文档的，现在已经使用比较得心应手，感觉作为撰写书籍，使用Sphinx Doc是比较好的选择。

不过，Sphinx采用的reStructureText格式比较复杂(功能强大)，日常做快速笔记不如MarkDown格式。我发现MkDocs比较符合我的需求：

- 美观
- MarkDown语法
- 文档生成快速

我目前结合Sphinx 和 MkDoc 来完成日常工作学习的笔记:

- Sphinx用于撰写集结成册的技术手册
- MkDoc用于日常工作笔记，记录各种资料信息采集

.. note::

   Sphinx Doc 和 MkDocs 都采用Python编写，可以共用Python virtualenv环境，这也是我比较喜欢这两个文档撰写工具的原因。

Vim设置
==========

为了方便使用vim进行文档撰写和编写代码，请参考 `使用vim作为macos平台的IDE <https://github.com/huataihuang/cloud-atlas-draft/blob/master/develop/vim/using_vim_as_ide_in_macos.md>`_ 中我的实践，这是一个非常快捷初始化工作环境的方法::

   git clone --depth=1 https://github.com/amix/vimrc.git ~/.vim_runtime
   sh ~/.vim_runtime/install_awesome_vimrc.sh

Python Virtualenv
===================

.. note::

   如果是Linux环境，请参考 `在CentOS上安装 Python3 virtualenv <https://github.com/huataihuang/cloud-atlas-draft/blob/master/develop/python/startup/install_python_3_and_virtualenv_on_centos.md>`_

- 安装 `Homebrew <https://brew.sh>`_ ::

   /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

- 通过Homebrew安装Python3 ::

   brew install python3

.. note::

   安装在目录 ``/usr/local/bin/pyton3`` ，执行时使用 ``python3``

- 升级pip版本::

   sudo -H pip3 install --upgrade pip

- 安装virtualenv ::

   sudo -H ip3 install virtualenv

- 创建工作目录下的Python 3 Virtualenv::

   cd ~
   virutalenv venv3

- 使用Virtualenv (每次使用Python3 Virtualenv之前要激活，后续所有基于文档撰写都使用此环境) ::

   . ~/venv3/bin/activate

Sphinx Doc
============

- 安装Sphinx 以及 rtd ::

   pip install sphinx
   pip install sphinx_rtd_theme

- 初始化和创建sphinx文档项目::

   mkdir cloud-atlas
   cd cloud-atlas
   sphinx-quickstart

接下来就是文档撰写了，撰写在 ``source`` 目录下，结构请参考 `我的云图项目 <https://github.com/huataihuang/cloud-atlas>`_`

MkDoc
=========

- 继承已经安装部署的Python3 Virtualenv环境，安装 mkdocs ::

   pip install mkdocs
   pip install mkdocs-material

.. note::

   采用Google Material Design风格的theme `Material for MkDocs <https://squidfunk.github.io/mkdocs-material/>`_`

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

参考
=========

- `使用vim作为macOS的IDE <https://github.com/huataihuang/cloud-atlas-draft/blob/master/develop/vim/using_vim_as_ide_in_macos.md>`_
- `在macOS上安装Python3 virtualenv <https://github.com/huataihuang/cloud-atlas-draft/blob/master/develop/python/startup/install_python_3_and_virtualenv_on_macos.md>`_
- `使用Sphinx撰写python文档 <https://github.com/huataihuang/cloud-atlas-draft/blob/master/develop/doc/sphinx/sphinx_for_python_doc.md>`_
