.. _blfs_system_utilities:

========================
BLFS系统工具
========================

.. _fcron:

Fcron
==========

定时任务，例如 :ref:`make-ca` 需要fcron来周期性更新证书

.. literalinclude:: blfs_system_utilities/fcron
   :caption: fcron

.. _blfs_cpio:

cpio
==========

.. literalinclude:: blfs_system_utilities/cpio
   :caption: cpio

hwdata
========

为 ``pciutils`` 提供支持: 包含当前PCI和厂商id数据

.. literalinclude:: blfs_system_utilities/hwdata
   :caption: hwdata

.. _blfs_pciutils:

pciutils
==========

依赖建议: ``hwdata`` 

.. literalinclude:: blfs_system_utilities/pciutils
   :caption: pciutils

which
==========

.. literalinclude:: blfs_system_utilities/which
   :caption: which

sysstat
===============

.. literalinclude:: blfs_system_utilities/sysstat
   :caption: sysstat

通过cron配置定时运行

参考
======

- `BLFS: 12. System Utilities <https://www.linuxfromscratch.org/blfs/view/stable/general/sysutils.html>`_
