.. _macos_nfs3:

============================
macOS系统 ``NFS v3`` 服务
============================

考虑到 :ref:`macos_nfs4` 可能在 :ref:`colima_nfs` 环境中和 NFS v3差别不大，在排查NFS挂载问题时，我也尝试了 NFS v3配置来作为对比。

- ``/etc/nfs.conf`` :

.. literalinclude:: macos_nfs3/nfs.conf
   :caption: NFS v3 ``/etc/nfs.conf``

- ``/etc/epxorts`` :

.. literalinclude:: macos_nfs3/exports
   :caption: 输出 ``/etc/exports``

- 完成后重启 ``nfsd`` :

.. literalinclude:: macos_nfs4/restart_nfsd
   :caption: 重启nfsd

重启nfsd之后，通过 ``rpcinfo -p`` 观察，可以看到 ``nfsd`` 服务仅提供 ``v2`` 和 ``v3`` 版本的NFS服务

如果没有达到预期的清理掉NFS v4配置，则采用以下彻底重启方法：

.. literalinclude:: macos_nfs4/restart_nfsd_final
   :caption: 彻底重启nfsd

性能优化
============

为了在 :ref:`colima_nfs` 中提供更好的NFS性能，优化 ``/etc/nfs.conf`` :

.. literalinclude:: macos_nfs3/nfs_tunning.conf
   :caption: 性能优化的NFS v3 ``/etc/nfs.conf``

.. note::

   确保文件末尾留有一个干净的空行，防止 macOS 解析器静默忽略最后一行！


