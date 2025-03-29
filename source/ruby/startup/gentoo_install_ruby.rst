.. _gentoo_install_ruby:

=====================
Gentoo安装Ruby
=====================

Gentoo中安装Ruby可以使用发行版内置的ebuild完成，也可以采用 :ref:`rvm` 完成:

- 对于 :ref:`docker_images` 容器化运行环境(生产)，采用直接安装ruby，通过容器来隔离和提供不同ruby版本的运行环境
- 对于开发测试环境，如果没有 :ref:`docker_images` 容器化运行或者就是想快速切换，则采用 :ref:`rvm`

USE flags
===========

安装
=======

- 执行 ``emerge`` 安装ruby，默认安装稳定版本:

.. literalinclude:: gentoo_install_ruby/emerge_ruby
   :caption: ``emerge`` 安装ruby

当前(2023年12月)默认安装 ``ruby 3.1.4`` 稳定版本

此时执行 ``eselect`` 检查列表:

.. literalinclude:: gentoo_install_ruby/eselect_ruby
   :caption: 检查系统中安装ruby列表

显示是 ``ruby31`` :

.. literalinclude:: gentoo_install_ruby/eselect_ruby_output
   :caption: 检查系统中安装ruby列表可以看到是 ``ruby31``

- 如果要实现ruby版本更新， :strike:`例如需要从 Ruby 3.1.4 升级到 Ruby 3.3.0 (2023年12月的最新release版本)` ，那么需要在 ``/etc/protage/make.conf`` 中添加 ``RUBY_TARGETS`` 变量:

.. literalinclude:: gentoo_install_ruby/ruby_make.conf
   :caption: 在 ``/etc/protage/make.conf`` 配置Ruby目标版本

- 执行 Ruby base 包升级:

.. literalinclude:: gentoo_install_ruby/update_ruby
   :caption: 使用 ``emerge`` 升级ruby base包

.. warning::

   目前我实践发现，上述 Ruby base 包升级只限于稳定版本，也就是当前稳定版本是 ``ruby31`` ，而 ``ruby33`` 尚未进入稳定版本，则 ``emerge --ask --oneshot --update dev-lang/ruby`` 实际没有效果。

   以后再验证

- (尚未实践)选择新安装的版本:

.. literalinclude:: gentoo_install_ruby/eselect_ruby
   :caption: 通过 ``eselect`` 选择安装版本

- 最后执行一次完整系统升级，遮掩够可以避免一些bug，并且会emerge ruby实现，强制所有依赖包重建并使用新安装的ruby进行重构:

.. literalinclude:: gentoo_install_ruby/emerge_world
   :caption: 最后重建world

参考
======

- `gentoo linux wiki: Ruby <https://wiki.gentoo.org/wiki/Ruby>`_
