.. _install_hugo:

================
Hugo安装
================

Hugo有3个版本:

- standard: 核心功能
- extended: 增加了 WebP 图像处理解码 + Transpile Sass to CSS
- extended/deploy: 在extended基础上增加了直接部署到Google Cloud bucket, AWS S3 bucket, Azure存储容器

通常建议使用 ``extended`` 版本

macOS
==========

- 直接使用 :ref:`homebrew` 安装可能是最简单的方法了:

.. literalinclude:: install_hugo/brew
   :caption: 使用 :ref:`homebrew` 安装Hugo

Linux
=========

- 通过发行版可以直接安装 Hugo

.. literalinclude:: install_hugo/apt
   :caption: :ref:`debian` 系安装Hugo

.. literalinclude:: install_hugo/pacman
   :caption: :ref:`arch_linux` 系安装Hugo

参考
=======

- `Hugo Installation <https://gohugo.io/installation/>`_
