.. _gentoo_ccache:

==================
Gentoo ccache
==================

``ccache`` 是非常重要的的编译加速工具(毕竟Gentoo就是依赖源代码编译不断滚动升级)，通过从缓存目录获取结果来帮助避免对相同的 C 和 C++ 对象文件进行重复重新编译。

编译器缓存通常用于:

- 多次重建相同/相似代码库并使用 ``/etc/portage/patches`` 来测试补丁的开发人员
- **经常更改 USE 标志并最终多次重建相同包的用户**
- 广泛使用 ``live ebuild`` 的用户
- **安装非常大的 ebuild** ，例如 ``Chromium`` 或 ``LibreOffice`` ，无需担心因失败而丢失多个小时的代码编译

.. note::

   对于我们这样不断折腾系统的人来说， ``ccache`` 简直是 `居家旅行 杀人灭口 必备良药 <https://movie.douban.com/subject/1306249/>`_

安装和配置
=============

- 安装 ``dev-util/ccache`` :

.. literalinclude:: gentoo_ccache/install_ccache
   :caption: 安装 ccache

- 激活 ``ccache`` 非常简单，主要就是在 ``/etc/portage/make.conf`` 激活，例如在 :ref:`install_gentoo_on_mbp` 过程中，先安装部署 ``ccache`` 并启用配置:

.. literalinclude:: install_gentoo_on_mbp/make.conf
   :caption: 启用 ccache
   :emphasize-lines: 25,26

- 此外 ``/etc/ccache.conf`` 提供了一些控制参数，例如限制缓存磁盘大小:

.. literalinclude:: gentoo_ccache/ccache.conf
   :caption: 调整ccache的缓存大小
   :emphasize-lines: 2

``ccache.conf`` 还支持压缩功能，且可以设置压缩级别:

.. literalinclude:: gentoo_ccache/ccache_compression.conf
   :caption: ccache 支持内容压缩

参考
======

- `gentoo linux wiki: ccache <https://wiki.gentoo.org/wiki/Ccache>`_
