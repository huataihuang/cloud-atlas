.. _zrep_arch:

=======================
ZREP架构解析
=======================

ZREP是 :ref:`zfs` 的replication和failver脚本，可以在两个系统见进行同步。这样可以实现一个数据持续备份和恢复，进而实现系统容灾。虽然这个工具仅仅是shell脚本，但是值得学习借鉴，以实现搞可用系统。

参考
======

- `ZREP ZFS replication and failover <http://www.bolthole.com/solaris/zrep/>`_ zrep的早期网页，有相关介绍和信息索引
- `GitHub: bolthole/zrep <https://github.com/bolthole/zrep>`_ 目前zrep已经转到github上继续开发，持续有修复更新
