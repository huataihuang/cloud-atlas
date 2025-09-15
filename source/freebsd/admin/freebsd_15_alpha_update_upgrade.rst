.. _freebsd_15_alpha_update_upgrade:

==================================
FreeBSD 15 Alphas更新和升级
==================================

我为了能够 :ref:`bhyve_nvidia_gpu_passthru_freebsd_15` ，在9月中旬FreeBSD 15处于Alpha 1阶段时安装了这个最新版本。

按照 :ref:`freebsd_update_upgrade` 工具 ``freebsd-update`` 说明，该二进制升级是支持 ALPHA, BETA, RC 和 RELEASE 版本的。但是，我执行:

.. literalinclude:: freebsd_update/fetch
   :caption: 获取完整的Core OS软件系统索引

提示报错:

.. literalinclude:: freebsd_15_alpha_update_upgrade/fetch_error
   :caption: 在FreeBSD 15 Alpha 1 上执行 ``freebsd-update`` 报错
   :emphasize-lines: 9,13

我看了一下 `FreeBSD 15.0 Release Process <https://www.freebsd.org/releases/15.0R/schedule/>`_ :

- `ALPHA2 builds` 是9月12日开始构建，9月14日完成
- 当前是9月15日(北京时间)

看起来现在还没有来得及发布更新二进制包，所以当前更新需要采用 :ref:`freebsd_build_from_source` 完成升级安装:

.. literalinclude:: ../build/freebsd_build_from_source/freebsd_src_git_shallow
   :caption: 使用 shallow clone 获取 ``stable/15`` 分支最新版本

- 执行编译内核或userland(world):

.. literalinclude:: ../build/freebsd_build_from_source/build
   :caption: 编译和安装

- 确保 ``/etc`` 目录下配置文件更新为符合新的upserspace:

.. literalinclude:: ../build/freebsd_build_from_source/etcupdate
   :caption: 更新 ``/etc`` 目录下配置

- 然后检查新版本不需要的文件并删除

.. literalinclude:: ../build/freebsd_build_from_source/clean_old
   :caption: 清理就文件和库

- 最后检查 ``uname -r`` 可以看到系统已经升级到 ``15.0-ALPHA2``
