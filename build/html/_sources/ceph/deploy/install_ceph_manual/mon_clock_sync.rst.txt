.. _mon_clock_sync:

======================
Ceph Monitor时钟同步
======================

在完成 :ref:`add_ceph_mons` 添加第二个 ``z-b-data-2`` monitor节点之后，我注意到 ``ceph -s`` 提示第二个节点时间异常::

   clock skew detected on mon.z-b-data-2

其实这两个虚拟机 ``z-b-data-1`` 和 ``z-b-data-2`` 是位于同一个物理服务器 ``zcloud`` 上，KVM提供了虚拟化时钟，理论上应该两者一致。但是为何还会有警告呢？

通过ssh到服务器上检查，发现KVM虚拟机确实存在微小的时间差异::

   huatai@zcloud:~$ date;for i in 192.168.6.204 192.168.6.205 192.168.6.206;do ssh $i 'hostname;date';done
   Sat 04 Dec 2021 01:42:52 PM CST
   z-b-data-1
   Sat 04 Dec 2021 01:42:53 PM CST
   z-b-data-2
   Sat 04 Dec 2021 01:42:55 PM CST
   z-b-data-3
   Sat 04 Dec 2021 01:43:03 PM CST
   huatai@zcloud:~$ date;for i in 192.168.6.204 192.168.6.205 192.168.6.206;do ssh $i 'hostname;date';done
   Sat 04 Dec 2021 01:42:54 PM CST
   z-b-data-1
   Sat 04 Dec 2021 01:42:54 PM CST
   z-b-data-2
   Sat 04 Dec 2021 01:42:56 PM CST
   z-b-data-3
   Sat 04 Dec 2021 01:43:05 PM CST

最小时间差异2秒，最大11秒。而且物理主机时间和最接近的虚拟机时间似乎也相差半秒到1秒。

.. note::

   实际上Ubuntu默认已经安装了 ``systemd-timesyncd`` 服务并默认启动，不过，我的KVM虚拟机 ``z-b-data-X`` 都是内网虚拟机，不能直接连接Internet，所以导致长时间运行后时间偏移。这里我需要解决在本地物理服务器上提供NTP服务(物理服务器直连Internet可以实时同步时间)，来校准虚拟机的时钟。

这让我有点诧异，我原本以为KVM时钟至少本机能提供比较精确的时间，看来还是需要在我的 :ref:`priv_cloud_infra` :

- 在物理主机 ``zcloud`` 上面向整个 :ref:`priv_kvm` 集群 :ref:`deploy_ntp`
- 所有虚拟机都启用 :ref:`systemd_timesyncd` 同步时钟

部署 chrony 服务器
=======================

- 登陆 ``zcloud`` 物理服务器，执行以下命令安装::

   sudo apt install chrony

- 编辑 ``/etc/chrony/chrony.conf`` 添加服务配置::

   allow 192.168.6.0/24

.. note::

   其他配置保持默认

- 启动服务::

   sudo systemctl restart chrony.service
   sudo systemctl enable chrony.service

- 检查服务状态正常::

   sudo systemctl status chrony.service

配置客户机Systemd Timesyncd服务
==================================

.. note::

   详情参考 :ref:`systemd_timesyncd`

- 登陆所有KVM虚拟机，执行安装::

   sudo apt install systemd-timesyncd

.. note::

   操作系统默认已经安装和启动 ``systemd-timesyncd`` ，但是需要配置采用前述部署的局域网内部NTP服务器

- ``/etc/systemd/timesyncd.conf`` 修改::

   [Time]
   NTP=192.168.6.200

- 重启 ``systemd-timesyncd`` 服务::

   systemctl restart systemd-timesyncd

然后检查同步配置::

   timedatectl show-timesync --all

可以看到::

   LinkNTPServers=
   SystemNTPServers=192.168.6.200
   FallbackNTPServers=ntp.ubuntu.com
   ServerName=192.168.6.200
   ServerAddress=192.168.6.200
   RootDistanceMaxUSec=5s
   PollIntervalMinUSec=32s
   PollIntervalMaxUSec=34min 8s
   PollIntervalUSec=32s
   NTPMessage={ Leap=0, Version=4, Mode=4, Stratum=2, Precision=-24, RootDelay=37.094ms, RootDispersion=350us, Reference=CA701FC5, OriginateTimestamp=Sat 2021-12-04 22:24:01 CST, ReceiveTimestamp=Sat 2021-12-04 22:24:00 CST, TransmitTimestamp=Sat 2021-12-04 22:24:00 CST, DestinationTimestamp=Sat 2021-12-04 22:24:01 CST, Ignored=no PacketCount=1, Jitter=0  }
   Frequency=0

时钟服务器已经指向 ``192.168.6.200`` 也就是 ``zcloud`` 服务器上自建的NTP服务器

.. note::

   注意需要修订 ``z-ubuntu20`` 模版服务器的配置，方便后续创建虚拟机直接生效

检查
========

- 完成时钟同步之后，再次检查可以看到虚拟机时间已经完全一致::

   date;for i in 192.168.6.204 192.168.6.205 192.168.6.206;do ssh $i 'hostname;date';done

输出显示::

   Sat 04 Dec 2021 10:29:04 PM CST
   z-b-data-1
   Sat 04 Dec 2021 10:29:04 PM CST
   z-b-data-2
   Sat 04 Dec 2021 10:29:04 PM CST
   z-b-data-3
   Sat 04 Dec 2021 10:29:04 PM CST

- 此时检查 Ceph集群健康状态，可以看到时钟差异告警已经消失
