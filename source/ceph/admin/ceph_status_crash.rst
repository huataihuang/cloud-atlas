.. _ceph_status_crash:

=============================================
Cetph状态警告"daemons have recently crashed"
=============================================

在Ceph的日常维护中，难免会遇到服务crash的情况，此时使用 ``ceph -s`` 检查状态，会看到虽然当前服务都正常，但是有一个状态告警显示 ``X daemons have recently crashed`` :

.. literalinclude:: ceph_status_crash/ceph_health_warn
   :caption: ``ceph -s`` 显示近期有daemons出现crash
   :emphasize-lines: 3,4

`不要怕，是技术性调整 <https://zh.moegirl.org.cn/%E4%B8%8D%E8%A6%81%E6%80%95%EF%BC%8C%E6%98%AF%E6%8A%80%E6%9C%AF%E6%80%A7%E8%B0%83%E6%95%B4>`_

.. figure:: ../../_static/ceph/admin/dingxie.jpg

上述状态警告标识最近(默认是 **2周** 内)出现过Ceph服务crash，并且这个crash尚未被归档(archived)，也就是尚未被管理员标记为"已知"(acknowledged)。

这标识了一个软件bug，或者硬件问题(例如故障的磁盘)，也可能是其他问题。总之，需要检查一下。

- 检查最新的crash记录:

.. literalinclude:: ceph_status_crash/ceph_crash_ls
   :caption: 检查最新ceph crash记录

输出可能类似:

.. literalinclude:: ceph_status_crash/ceph_crash_ls_output
   :caption: 检查最新ceph crash记录案例
   :emphasize-lines: 3,4

- 检查crash记录的详情:

.. literalinclude:: ceph_status_crash/ceph_crash_info
   :caption: 检查指定ceph crash记录详情

- 检查以后(排查完)就可以将crash记录归档(标识为管理员已经检查过)，这样后续就不会再出现该条crash记录对应的警告信息:

.. literalinclude:: ceph_status_crash/ceph_crash_archive
   :caption: 指定ceph crash记录归档(消除对应告警信息)

或者直接将所有crash告警信息归档:

.. literalinclude:: ceph_status_crash/ceph_crash_archive_all
   :caption: 所有ceph crash记录归档(消除对应告警信息)

- 归档以后， ``ceph crah ls`` 仍然可以看到所有crash记录，不过 ``ceph crash ls-new`` 则不会显示

- 默认 ``recent`` 是两周，这个参数可以通过 ``mgr/crash/warn_recent_interval`` 修改

.. literalinclude:: ceph_status_crash/ceph_config_get_mgr_crash_warn_recent_interval
   :caption: 检查ceph crash配置的recent间隔值

默认输出是::

   1209600

- 也可以完全关闭crash记录告警:

.. literalinclude:: ceph_status_crash/disable_ceph_status_crash_warn
   :caption: 彻底关闭ceph crash记录近期告警



参考
======

- `ceph-mgr : Why does ceph status shows '1 daemons have recently crashed'? <https://access.redhat.com/solutions/5506031>`_
