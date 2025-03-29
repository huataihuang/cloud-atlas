.. _pgsql_in_jail:

==================================
在FreeBSD Jail中运行PostgreSQL
==================================

此外通过 :ref:`bastille` 可以快速 :ref:`pgsql_jail_with_bastille` 

参考
=======

- `FreeBSD 14.2 Host-Managed ZFS datasets auto-mounted With jexec inside a jail - native ZFS solution <https://forums.freebsd.org/threads/freebsd-14-2-host-managed-zfs-datasets-auto-mounted-with-jexec-inside-a-jail-native-zfs-solution.96178/>`_  非常好的参案例，通过ZFS dataset为Jail中运行的 :ref:`pgsql` 提供存储
- `FreeBSD 13: How to Install PostgreSQL (in a Jail) <https://herrbischoff.com/2023/11/freebsd-13-how-to-install-postgresql-in-a-jail/>`_
- `Upgrading A PostgreSQL Jail <https://www.brianlane.com/post/upgrade-postgres-jail/>`_ 非常有意思，通过zfs快照更新pgsql
