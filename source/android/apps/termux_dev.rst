.. _termux_dev:

=================
Termux开发环境
=================

在探索 :ref:`android_mobile_work` ，我采用在 :ref:`termux` 中安装必要的软件并配置适合工作的环境

安装软件包
=============

- 安装工具:

.. literalinclude:: termux_dev/termux_apt_tool
   :language: bash
   :linenos:
   :caption: termux中安装软件包(apt)

环境配置
============

- 将默认SHELL改成 :ref:`termux_zsh`

- :ref:`ssh_key` 配置

- :ref:`ssh_multiplexing` 配置


开发软件
===========

`Termux Development Environments <https://wiki.termux.com/wiki/Development_Environments>`_ 提供了termux软件开发，信息科学教育以及实验的软件列表:

- 安装 python , c , go , rust :

.. literalinclude:: termux_dev/termux_apt_dev
   :language: bash
   :linenos:
   :caption: termux中安装软件包(apt)

vim
=======

采用 :ref:`my_vimrc` 定制，但是需要安装编译依赖:

.. literalinclude:: termux_ycm/vimrc_termux_dep_dev
   :language: bash
   :caption: termux安装编译YCM依赖软件包

文档撰写
============

配置 :ref:`write_doc` 环境:

- :ref:`sphinx_doc`
- :ref:`mkdocs`
- :ref:`hugo`
