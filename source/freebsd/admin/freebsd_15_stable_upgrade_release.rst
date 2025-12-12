.. _freebsd_15_stable_upgrade_release:

=======================================
FreeBSD 15 STABLE更新和升级到RELEASE
=======================================

我为了能够 :ref:`bhyve_nvidia_gpu_passthru_freebsd_15` ，在9月中旬FreeBSD 15处于Alpha 1阶段时安装了这个最新版本。之后，由于非RELEASE版本都需要从源代码编译升级，所以在 :ref:`freebsd_15_alpha_update_upgrade` 过程中，我始终在STABLE分支的源代码编译升级。

2025年12月2日，FreeBSD终于发布了 ``15.0-RELEASE`` 版本，所以我需要将当前的非发布分支 ``STABLE`` 切换升级到 ``RELEASE``

- 注意，由于非 ``RELEASE`` 分支，不能使用 :ref:`freebsd_update_upgrade` 中 ``freebsd-update`` 命令，例如 ``freebsd-update fetch`` 会提示错误:

.. literalinclude:: freebsd_15_stable_upgrade_release/freebsd-update_no_release
   :caption: 对于非RELEASE版本使用 ``freebsd-update`` 会提示错误

**需要将当前STABLE分支切换到RELEASE分支** ，参考 `Updating the Source <https://docs.freebsd.org/en/books/handbook/cutting-edge/#updating-src-obtaining-src>`_ 可以看到有3个分支:

.. csv-table:: FreeBSD分支
   :file: freebsd_15_stable_upgrade_release/freebsd_version_branches.csv
   :widths: 10,10,80
   :header-rows: 1

- 将当前 ``STABLE`` 源代码分支切换到 ``releng/15.0`` :

.. literalinclude:: freebsd_15_stable_upgrade_release/checkout_release_15
   :caption: 切换 ``releng/15.0``

- 编译内核以及userland(world):

.. literalinclude:: ../build/freebsd_build_from_source/build
   :caption: 编译和安装

- 升级完成后，需要确保 ``/etc`` 目录下配置文件更新为符合新的upserspace:

.. literalinclude:: ../build/freebsd_build_from_source/etcupdate
   :caption: 更新 ``/etc`` 目录下配置

- 检查新版本不需要的文件并删除:

.. literalinclude:: ../build/freebsd_build_from_source/clean_old
   :caption: 清理就文件和库

- 最后检查 ``uname -r`` 可以看到系统已经是 ``15.0-RELEASE`` ，此时就能够实现通过 ``freebsd-update`` 完成 :ref:`freebsd_update_upgrade`
