.. _ceph_disk_health_smart_mon:

=========================
Ceph磁盘健康度SMART监控
=========================

我在观察Ceph集群节点的系统日志，发现有::

   May 16 08:04:51 z-b-data-3 sudo[153388]:     ceph : TTY=unknown ; PWD=/ ; USER=root ; COMMAND=/usr/sbin/smartctl -a --json=o /dev/nvme0n1
   May 16 08:04:51 z-b-data-3 sudo[153388]: pam_unix(sudo:session): session opened for user root by (uid=0)
   May 16 08:04:51 z-b-data-3 sudo[153388]: pam_unix(sudo:session): session closed for user root
   May 16 08:04:52 z-b-data-3 sudo[153391]: pam_unix(sudo:auth): conversation failed
   May 16 08:04:52 z-b-data-3 sudo[153391]: pam_unix(sudo:auth): auth could not identify password for [ceph]
   May 16 08:04:52 z-b-data-3 sudo[153391]:     ceph : command not allowed ; TTY=unknown ; PWD=/ ; USER=root ; COMMAND=nvme samsung smart-log-add --json /dev/nvme0n1
   May 16 08:04:56 z-b-data-3 sudo[153393]:     ceph : TTY=unknown ; PWD=/ ; USER=root ; COMMAND=/usr/sbin/smartctl -a --json=o /dev/
   May 16 08:04:56 z-b-data-3 sudo[153393]: pam_unix(sudo:session): session opened for user root by (uid=0)
   May 16 08:04:56 z-b-data-3 sudo[153393]: pam_unix(sudo:session): session closed for user root

可以看到 Ceph 采用了 SMART 技术来监控磁盘是否存在异常

参考
=======

- `New in Nautilus: device management and failure prediction <https://ceph.io/en/news/blog/2019/new-in-nautilus-device-management-and-failure-prediction/>`_
- `Bug 1837645 - ceph device get-health-metrics does not work when smartctl command throws non-zero error code <https://bugzilla.redhat.com/show_bug.cgi?id=1837645>`_
