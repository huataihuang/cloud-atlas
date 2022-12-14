.. _debug_ceph_authenticate_time_out:

==========================================================
排查Ceph部署"monclient(hunting): authenticate timed out"
==========================================================

异常现象
=========

:ref:`install_mobile_cloud_ceph` 我遇到问题是虽然能启动第二和第三节点上的 ``ceph-mon`` ，但是

- 在 ``$HOST_1`` 完成 :ref:`mobile_cloud_ceph_mon` , :ref:`mobile_cloud_ceph_mgr` 和 :ref:`mobile_cloud_ceph_add_ceph_osds_lvm` 上执行 ``ceph -s`` 是正常的
- 但是在 ``$HOST_2`` 和 ``$HOST_3`` 上完成 :ref:`mobile_cloud_ceph_add_ceph_mons` 就发现 ``$HOST_1`` 上执行 ``ceph -s`` 没有响应，过了很久终端上显示::

   2022-12-14T08:58:38.817+0800 ffffb4ede1a0  0 monclient(hunting): authenticate timed out after 300
   2022-12-14T09:03:38.826+0800 ffffb4ede1a0  0 monclient(hunting): authenticate timed out after 300
   ...

- 执行 ``systemctl status ceph-mon@$(hostname -s)`` 

在 ``$HOST_1`` 上显示正常::

   Dec 14 00:54:48 a-b-data-1.dev.cloud-atlas.io systemd[1]: Started ceph-mon@a-b-data-1.service - Ceph cluster monitor daemon.

但是 ``$HOST_2`` 和 ``$HOST_3`` 则显示::

   Dec 14 00:55:34 a-b-data-2.dev.cloud-atlas.io systemd[1]: Started ceph-mon@a-b-data-2.service - Ceph cluster monitor daemon.
   Dec 14 00:55:34 a-b-data-2.dev.cloud-atlas.io ceph-mon[1506]: 2022-12-14T00:55:34.638+0800 ffff84a0b040 -1 WARNING: 'mon addr' config option v1:192.168.8.205:6789/0 does not match monmap file
   Dec 14 00:55:34 a-b-data-2.dev.cloud-atlas.io ceph-mon[1506]:          continuing with monmap configuration

尝试排查
===========

补全 ``ceph.con`` 配置中 ``mon host`` (无效)
-----------------------------------------------

- 最初我以为是忘记 "调整配置添加新增 ceph-mon 节点" ，所以修订每个服务器上的 ``/etc/ceph/ceph.conf`` 配置，将新增节点配置加入::

   [global]
   fsid = 598dc69c-5b43-4a3b-91b8-f36fc403bcc5
   mon initial members = a-b-data-1,a-b-data-2,a-b-data-3
   mon host = 192.168.8.204,192.168.8.205,192.168.8.206
   ...

然后重启 ``ceph-mon`` 服务。但是发现 ``ceph -s`` 依然卡住

回滚 ``auth_allow_insecure_global_id_reclaim`` 恢复 ``true`` (无效)
----------------------------------------------------------------------

参考 `Re: monclient(hunting): handle_auth_bad_method server allowed_methods [2] but i only support [2] <https://lists.ceph.io/hyperkitty/list/ceph-users@ceph.io/thread/K7LDVS7Y5XQV7ILHC5WUWMXVJ5HX4HU3/>`_ 提到:

ceph 升级到 14.2.20, 15.2.11 或者 16.2.1 版本，并且设置 ``auth_allow_insecure_global_id_reclaim`` 为 ``false`` 的时候，会出现上述报错。

我检查了我当前版本 ``ceph -v`` 显示为 ``17.2.5`` ，之前在 :ref:`zdata_ceph` 使用的版本是 ``17.2.0`` ，之所以没有遇到这个问题，是因为当时我已经完成了所有节点的 ``ceph-mon`` 配置并运行，然后再执行 :ref:`disable_insecure_global_id_reclaim` 就没有影响。

尝试解决步骤:

- 我首先想暂时恢复 ``auth_allow_insecure_global_id_reclaim`` ，所以在节点1上执行::

   sudo ceph config set mon auth_allow_insecure_global_id_reclaim true

但是很不幸，由于已经将节点2和3加入了 ``ceph-mon`` 的monmap，无法更新，一直卡住。怎么办呢?

参考 `After upgrade to 15.2.11 no access to cluster any more <https://lists.ceph.io/hyperkitty/list/ceph-users@ceph.io/thread/6OYOI7PCNBCC22OYLWUPLYRNCVP36MYC/>`_ 执行以下命令直接设置本机的ceph mon服务(需要在每个节点上分别执行)::

   sudo ceph daemon mon.`hostname -s` config set auth_allow_insecure_global_id_reclaim true

上述命令不会去连接集群的其他节点，所以能够正确执行，返回信息::

   {   
       "success": "auth_allow_insecure_global_id_reclaim = 'true' (not observed, change may require restart) "
   }

然后重启每个节点服务::

   sudo systemctl restart ceph-mon@`hostname -s`

没有解决

重新部署并排查
=====================

我重新部署了一遍，步骤中去掉了 :ref:`disable_insecure_global_id_reclaim` 但是报错依旧

发现 ``monmap`` 不一致
----------------------------

我发现存在一个蹊跷的地方::

   sudo ceph mon getmap -o /tmp/monmap
   monmaptool --print /tmp/monmap

显示输出::

   monmaptool: monmap file /tmp/monmap
   epoch 1
   fsid 598dc69c-5b43-4a3b-91b8-f36fc403bcc5
   last_changed 2022-12-12T23:28:26.845735+0800
   created 2022-12-12T23:28:26.845735+0800
   min_mon_release 17 (quincy)
   election_strategy: 1
   0: v1:192.168.8.204:6789/0 mon.a-b-data-1
   1: [v2:192.168.8.205:3300/0,v1:192.168.8.205:6789/0] mon.a-b-data-2
   2: [v2:192.168.8.206:3300/0,v1:192.168.8.206:6789/0] mon.a-b-data-3

奇怪，为何第一个部署节点使用的是 ``v1`` mon，而第二个节点和第三个节点既有 ``v1`` 又有 ``v2``

我马上到我之前 :ref:`install_ceph_manual` 成功的集群上检查发现，正常集群的3个节点 ``monmap`` 是一样的::

   monmaptool: monmap file /tmp/monmap
   epoch 4
   fsid 0e6c8b6f-0d32-4cdb-a45d-85f8c7997c17
   last_changed 2022-11-07T23:40:25.922046+0800
   created 2021-12-01T16:57:40.856830+0800
   min_mon_release 17 (quincy)
   election_strategy: 1
   0: [v2:192.168.6.204:3300/0,v1:192.168.6.204:6789/0] mon.z-b-data-1
   1: [v2:192.168.6.205:3300/0,v1:192.168.6.205:6789/0] mon.z-b-data-2
   2: [v2:192.168.6.206:3300/0,v1:192.168.6.206:6789/0] mon.z-b-data-3

参考 `Troubleshooting Ceph Monitors and Ceph Managers <https://documentation.suse.com/ses/7.1/html/ses-all/bp-troubleshooting-monitors.html>`_ 提到对于 ``ceph -s`` 没有相应的话，可以到每个节点执行 ``ceph tell mon.ID mon_status`` ( ID 是 monitor的identifier )，例如，我在执行::

   ceph tell mon.$(hostname -s) mon_status

不过，也卡住没有输出

尝试调整 ``ceph.conf`` 中 ``mon addr``
-----------------------------------------

我发现 ``systemctl status ceph-mon@$(hostname -s)`` 提示的是::

   WARNING: 'mon addr' config option v1:192.168.8.205:6789/0 does not match monmap file

那么我的 ``$HOST_2`` 节点既然从 ``monmap`` 显示有 ``v2:192.168.8.205:3300/0`` ，是不是要改成 ``192.168.8.205:3300`` 配置呢？

我将 ``/etc/ceph/ceph.conf`` 配置调整成::

   [mon.a-b-data-1]
   host = a-b-data-1
   mon addr = 192.168.8.204:6789

   [mon.a-b-data-2]
   host = a-b-data-2
   mon addr = 192.168.8.205:3300

   [mon.a-b-data-3]
   host = a-b-data-3
   mon addr = 192.168.8.206:3300

然后在 ``$HOST_2`` 重启 ``ceph-mon`` ，果然警告不一样了，显示::

   Dec 14 09:59:30 a-b-data-2.dev.cloud-atlas.io ceph-mon[2456]: 2022-12-14T09:59:30.837+0800 ffffbc2bb040 -1 WARNING: 'mon addr' config option v2:192.168.8.205:3300/0 does not match monmap file
   Dec 14 09:59:30 a-b-data-2.dev.cloud-atlas.io ceph-mon[2456]:          continuing with monmap configuration

但是我尝试调整::

   [mon.a-b-data-2]
   host = a-b-data-2
   mon addr = 192.168.8.205:3300,192.168.8.205:6789
   
提示信息显示语法错误::

   Dec 14 10:05:35 a-b-data-2.dev.cloud-atlas.io ceph-mon[2615]: 2022-12-14T10:05:35.457+0800 ffff8813b040 -1 WARNING: invalid 'mon addr' config option
   Dec 14 10:05:35 a-b-data-2.dev.cloud-atlas.io ceph-mon[2615]:          continuing with monmap configuration

很惊讶，我回头去看我曾经部署成功的 :ref:`install_ceph_manual` ，我发现当时是移除了 ``[mon.z-b-data-2]`` 等配置的，也就是说，根本没有 ``[mon.$(hostname -s)]`` 配置段落，所以也不会有WARNING

我清理掉 ``/etc/ceph/ceph.conf`` 中 ``[mon.$(hostname -s)]`` 配置段落，果然 ``systemcto status ceph-mon@$(hostname -s)`` 没有WARNING了::

   Dec 14 10:16:36 a-b-data-2.dev.cloud-atlas.io systemd[1]: Started ceph-mon@a-b-data-2.service - Ceph cluster monitor daemon.

不过 ``ceph -s`` 还没有解决卡住无输出的问题，继续探索

奇怪的DNS解析
================

我最初有点怀疑是三个节点的时钟不同步，不过 :ref:`mobile_cloud_ceph_mon_clock_sync` 配置过NTP，检查各个节点的时间也一致。

但是，我偶然在 ``$HOST_1`` 上查询::

   host a-b-data-1

发现在第一条记录显示后，出现超时::

   a-b-data-1 has address 192.168.8.204
   ;; communications error to 127.0.0.53#53: timed out
   ;; communications error to 127.0.0.53#53: timed out
   ;; no servers could be reached

不过，如果是完整域名::

   host a-b-data-1.dev.cloud-atlas.io

则响应正常快速::

   a-b-data-1.dev.cloud-atlas.io has address 192.168.8.204

如果在 ``a-b-data-1`` 上查询其他主机(短域名)，返回记录不存在::

   # host a-b-data-3
   a-b-data-3 has address 192.168.8.206
   Host a-b-data-3 not found: 3(NXDOMAIN)

这个问题在于，集群没有部署统一的DNS，而是依赖系统运行的 ``systemd-resolved`` 提供解析，实际上就是公网DNS解析。而我在每个服务器上 ``/etc/hosts`` 确实已经写好了每个主机的解析::

   192.168.8.204  a-b-data-1 a-b-data-1.dev.cloud-atlas.io
   192.168.8.205  a-b-data-2 a-b-data-2.dev.cloud-atlas.io
   192.168.8.206  a-b-data-3 a-b-data-3.dev.cloud-atlas.io

所以 ``hosts`` 查询DNS解析时候，从 ``/etc/hosts`` 可以读到主机名解析

但是，通过 :ref:`systemd_resolved` 解析， ``systemd-resolved``  服务会根据 ``/run/systemd/resolve/resolv.conf`` 查询上级DNS，也就是 :ref:`libvirt_nat_network` 网络提供的DNS。我检查发现服务器的 ``/run/systemd/resolve/resolv.conf`` 比较奇怪::

   nameserver 192.168.8.1
   search .

为何没有配置 ``search dev.cloud-atlas.io`` 域名？ (这个配置是装机时候配置的，难道我漏设置了?)

我对比了正常 :ref:`install_ceph_manual` 中的服务器 ``/run/systemd/resolve/resolv.conf`` ，发现包含了域名::

   nameserver 192.168.6.200
   search staging.huatai.me

注意，这个 ``/run/systemd/resolve/resolv.conf`` 不能直接修改，如果直接修改重启  ``systemd-resolved`` 也会覆盖。

修订 ``systemd-resolved`` 的 ``search`` 配置是修改 ``/etc/systemd/resolved.conf`` 配置::

   Domains=dev.cloud-atlas.io

然后重启 ``systemd-resolved`` ::

   systemctl restart systemd-resolved

这样现在执行::

   host a-b-data-1

就立即返回数据::

   a-b-data-1.dev.cloud-atlas.io has address 192.168.8.204

毫无阻碍

.. note::

   不过，此时还是没有解决 ``ceph -s`` 卡住问题

   这个步骤至少解决了域名解析的问题(虽然没有针对解决这个问题)

**悲剧** ``低级错误`` firewalld防火墙阻塞
===========================================

偶然看到有人提到服务器重启以后 ``ceph`` 命令无响应，通过关闭 ``firewalld`` 解决的。我倒，我马上看了一下::

   systemctl status firewalld

果然，是运行状态::

   ● firewalld.service - firewalld - dynamic firewall daemon
        Loaded: loaded (/usr/lib/systemd/system/firewalld.service; enabled; preset: enabled)
        Active: active (running) since Wed 2022-12-14 17:09:32 CST; 30s ago
          Docs: man:firewalld(1)
      Main PID: 1628 (firewalld)
         Tasks: 2 (limit: 6961)
        Memory: 23.6M
           CPU: 339ms
        CGroup: /system.slice/firewalld.service
                └─1628 /usr/bin/python3 -sP /usr/sbin/firewalld --nofork --nopid
   
   Dec 14 17:09:32 a-b-data-2.dev.cloud-atlas.io systemd[1]: Starting firewalld.service - firewalld - dynamic firewall daemon...
   Dec 14 17:09:32 a-b-data-2.dev.cloud-atlas.io systemd[1]: Started firewalld.service - firewalld - dynamic firewall daemon.

但是，

**firewalld不是iptables!!!**

**firewalld不是iptables!!!**

**firewalld不是iptables!!!**

其实我最初是检查过防火墙的，我的经验是 :ref:`iptables` ，所以我特意检查过::

   iptables -L

显示输出系统没有配置 ``iptables`` ，这个链表都是空的::

   Chain INPUT (policy ACCEPT)
   target     prot opt source               destination         

   Chain FORWARD (policy ACCEPT)
   target     prot opt source               destination         

   Chain OUTPUT (policy ACCEPT)
   target     prot opt source               destination

我大意了... 我没有想到 :ref:`fedora` 默认不启用 ``iptables`` (所以空表)，而是使用了 :ref:`firewalld` 防火墙。该死的， ``firewalld`` 是取代 :ref:`iptables` ( ``netfilter`` ) 的 ``nftables`` 实现 ，所以导致我没有意识到端口默认屏蔽。(不过，我为什么不早点测试端口连通性呢?)

- 查看 ``firewalld`` 配置:

.. literalinclude:: ../../../linux/redhat_linux/admin/firewalld/firewall_cmd_list
   :language: bash
   :caption: 检查主机所有firewalld配置概要

输出显示默认防火墙之开启了 ``cockpit dhcpv6-client ssh`` 服务器访问:

.. literalinclude:: debug_ceph_authenticate_time_out/firewall_cmd_list_output
   :language: bash
   :caption: 检查firewalld配置输出
   :emphasize-lines: 6

- 关闭 ``firewalld`` 防火墙，问题解决:

.. literalinclude:: ../../../linux/redhat_linux/admin/firewalld/stop_firewalld
   :language: bash
   :caption: 停止firewalld服务

参考
========

- `CEPH by hand <http://www.hep.ph.ic.ac.uk/~dbauer/cloud/iris/ceph.html>`_
