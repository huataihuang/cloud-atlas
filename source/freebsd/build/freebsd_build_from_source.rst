.. _freebsd_build_from_source:

=========================
从源代码编译构建FreeBSD
=========================

我在 :ref:`freebsd_15_alpha_update_upgrade` 遇到当前Alpha 2尚未发布更新，需要从源代码编译升级

获取源代码
=============

- 参考 `26.6.3. Updating the Source <https://docs.freebsd.org/en/books/handbook/cutting-edge/#updating-src-obtaining-src>`_ 根据 ``uname -r`` 获取当前安装的RELEASE，例如 ``14.3-RELEASE`` ，则下载对应的源代码分支:

.. literalinclude:: freebsd_build_from_source/freebsd_src
   :caption: 获取 freebsd 源代码

- 如果是获取STABLE分支:

.. literalinclude:: freebsd_build_from_source/freebsd_src_stable
   :caption: 获取 ``STABLE`` 分支 freebsd 源代码

- 如果是获取CURRENT分支:

.. literalinclude:: freebsd_build_from_source/freebsd_src_current
   :caption: 获取 ``CURRENT`` 分支 freebsd 源代码

获取 ``STABLE/15``
-------------------

方法一
~~~~~~~

- git clone出源代码，然后checkout出 ``stable/15`` 分支:

.. literalinclude:: freebsd_build_from_source/freebsd_src_stable_15
   :caption: 获取 ``stable/15`` 分支 freebsd 源代码

方法二
~~~~~~~~

使用 ``shallow Git clone`` 可以下载更少的数据也更快(不包含整个仓库的历史记录): 只需要特定构建的源代码，并且不打算跟踪分支的长期变化

.. literalinclude:: freebsd_build_from_source/freebsd_src_git_shallow
   :caption: 使用 shallow clone 获取 ``stable/15`` 分支最新版本

编译安装
=========

在下载源代码之后，就可以执行编译内核或userland(world):

.. literalinclude:: freebsd_build_from_source/build
   :caption: 编译和安装

更新配置
============

- ``etcupdate`` 工具能够确保 ``/etc`` 目录下配置文件更新为符合新的upserspace:

.. literalinclude:: freebsd_build_from_source/etcupdate
   :caption: 更新 ``/etc`` 目录下配置

- 然后检查新版本不需要的文件并删除

.. literalinclude:: freebsd_build_from_source/clean_old
   :caption: 清理就文件和库

- 最后更新EFI boot系统(这步似乎不需要，我没有看到系统中有 ``/boot/efi/EFI/FREEBSD/LOADER.EFI`` )::

   cp /boot/loader.efi /boot/efi/EFI/FREEBSD/LOADER.EFI

从源代码构建FreeBSD release介质
================================

上述构建和安装系统是从源代码编译完成，但是只能在本机完成，而且是源代码编译，非常花费时间。

FreeBSD还提供了一个构建 ``.iso`` 和 ``.img`` 文件功能，适合后续批量安装系统:

.. literalinclude:: freebsd_build_from_source/make_release
   :caption: 制作release镜像

完成后，在 ``/usr/obj/usr/src/amd64.amd64/release/`` 目录下(根据硬件架构)会生成iso文件以及 ``base.txz`` 等文件。

为方便查找，可以使用 ``make install`` 将镜像文件复制到统一的目录:

.. literalinclude:: freebsd_build_from_source/make_iso
   :caption: 将构建的镜像复制到指定目录 ``/usr/obj/release``

此时镜像安装都会集中到 ``/usr/obj/release``  目录下，方便下载和刻录:

.. literalinclude:: freebsd_build_from_source/make_iso_output
   :caption: iso安装镜像

参考
=====

- `RIP Tutorial: FreeBSD Build from source <https://riptutorial.com/freebsd/topic/7062/build-from-source>`_ 
- `Build FreeBSD from Source <https://www.wisellama.rocks/posts/2025-04-26-build-freebsd/>`_
- `26.6.3. Updating the Source <https://docs.freebsd.org/en/books/handbook/cutting-edge/#updating-src-obtaining-src>`_
