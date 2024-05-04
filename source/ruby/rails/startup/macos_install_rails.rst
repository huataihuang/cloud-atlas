.. _macos_install_rails:

=============================
macOS环境安装Ruby on Rails
=============================

在macOS环境安装Ruby on Rails的主要方法是:

- :ref:`homebrew` 安装基础环境，例如 :ref:`nvim` 等
- 使用 :ref:`homebrew` 在 :ref:`macos_install_ruby`

实践环境
=========

我在 :ref:`whats_past_is_prologue` 之后的旅行途中，使用的是我很久以前购买的公司退役二手 :ref:`mba13_early_2014` ，所以只能最高安装macOS 11.7 Big Sur版本。但是，基本安装思路和方法应该适用于后续 :ref:`macos` 版本。

- 默认SHELL是zsh
- 已经完成 :ref:`big_sur_homebrew` ，也就是通过以下命令完成 :ref:`homebrew` 初始化( **注意: 实际由于GFW影响安装还是很折腾的** ):

.. literalinclude:: ../../../apple/macos/homebrew/install_homebrew
   :language: bash
   :caption: 通过网络安装Homebrew

rbenv
==========

为了能够在个人工作环境中安装和管理不同的Ruby版本(用于开发和验证)，建议使用 :ref:`rbenv` 来完成RUBY版本的安装和管理，这是 :ref:`macos` 平台最常用的 :ref:`ruby_version_manager` ；另外一个在Linux平台流行的工具是 :ref:`rvm` :

.. literalinclude:: ../../startup/ruby_version_manager/rbenv_install
   :caption: 在 :ref:`macos` 中使用 :ref:`homebrew` 安装 ``rbenv``

按提示在 ``~/.zshrc`` 中添加:

.. literalinclude:: ../../startup/ruby_version_manager/zshrc
   :caption: 添加 :ref:`macos` zsh环境变量( ~/.zshrc )

安装ruby
================

- 通过 ``rbenv`` 来安装最新的ruby版本，并且将这个版本设置为默认版本:

.. literalinclude:: macos_install_rails/rbenv_install_ruby
   :caption: 通过 ``rbenv`` 来安装ruby

完成后通过 ``ruby -v`` 检查版本信息

安装Rails
============

- 执行 ``gem install`` 命令来安装:

.. literalinclude:: macos_install_rails/install_rails
   :caption: 通过 ``rbenv`` 来安装ruby

注意 ``rbenv`` 需要执行过 ``rbenv rehash`` 之后才能感知到刚才安装的 ``rails`` 新版本，否则会提示以下错误显示rails还没有安装(实际已经安装):

.. literalinclude:: macos_install_rails/rbenv_before_rehash
   :caption: 没有执行 ``rbenv rehash`` 之前没有感知到新安装的rails

刷新后，可以检查已经安装的rails: ``rails -v``

安装数据库
===========

在没有使用复杂的关系型数据库 :ref:`mysql` 或 :ref:`pgsql` 之前，通常(也是推荐)使用 :ref:`sqlite` ，方便进行初始开发工作，也适合小型程序开发:

.. literalinclude:: macos_install_rails/sqlite
   :caption: 安装sqlite3

Rails默认采用 :ref:`sqlite` 3作为数据库，不过通过简单配置也可以使用更为复杂适合大型项目的 :ref:`mysql` 或 :ref:`pgsql` :

- :ref:`rails_mysql`
- :ref:`rails_pgsql`

参考
=====

- `GO RAILS网站提供的安装指南 <https://gorails.com/setup/>`_ GO RAILS网站提供RAILS学习和培训，该网站提供了主要平台安装RoR的分步指导(交互方式选择操作系统版本就能提供对应安装步骤)，非常适合初学者
