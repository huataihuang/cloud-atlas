.. _add_ceph_osds:

=======================
添加Ceph OSDs
=======================

在完成了初始 :ref:`install_ceph_mon` 之后，就可以添加 OSDs。只有完成了足够的OSDs部署(满足对象数量，例如 ``osd pool default size =2`` 要求集群至少具备2个OSDs)才能达到 ``active + clean`` 状态。在完成了 ``bootstap`` Ceph monitor之后，集群就具备了一个默认的 ``CRUSH`` map，但是此时 ``CRUSH`` map还没有具备任何Ceph OSD Daemons map到一个Ceph节点。

Ceph提供了一个 ``ceph-vlume`` 工具，用来准备一个逻辑卷，磁盘或分区给Ceph使用，通过增加索引来创建OSD ID，并且将新的OSD添加到CRUSH map。需要在每个要添加OSD的节点上执行该工具。

.. note::

   我有3个服务器节点提供存储，需要分别在这3个节点上部署OSD服务。

bluestore
============

:ref:`bluestore` 是最新的Ceph采用的默认高性能存储引擎，底层不再使用OS的文件系统，可以直接管理磁盘硬件。

需要部署OSD的服务器首先准备存储，通常采用LVM卷作为底层存储块设备，这样可以通过LVM逻辑卷灵活调整块设备大小(有可能随着数据存储增长需要调整设备)。不过，作为我的实践环境 :ref:`hpe_dl360_gen9` 每个 :ref:`ovmf` 虚拟机仅有一个pass-through PCIe NVMe存储，所以我没有划分不同存储设备来分别存放 ``block`` / ``block.db`` 和 ``block.wal`` 。并且也因为无法扩展存储，我就没有使用LVM卷，而直接采用磁盘分区。

.. note::

   生产环境请使用LVM卷作为底层设备 - 参考 :ref:`bluestore_config`

   我的部署实践是在3台虚拟机 ``z-b-data-1`` / ``z-b-data-2`` / ``z-b-data-3`` 上完成，分区完全一致

- 准备底层块设备，这里划分 GPT 分区1 ::

   parted /dev/nvme0n1 mklabel gpt
   parted -a optimal /dev/nvme0n1 mkpart primary 0% 700GB

完成后检查 ``fdisk -l`` 可以看到::

   Disk /dev/nvme0n1: 953.89 GiB, 1024209543168 bytes, 2000409264 sectors
   Disk model: SAMSUNG MZVL21T0HCLR-00B00
   Units: sectors of 1 * 512 = 512 bytes
   Sector size (logical/physical): 512 bytes / 512 bytes
   I/O size (minimum/optimal): 512 bytes / 512 bytes
   Disklabel type: gpt
   Disk identifier: E131A860-1EC8-4F34-8150-2A2C312176A1
   
   Device         Start        End    Sectors   Size Type
   /dev/nvme0n1p1  2048 1367187455 1367185408 651.9G Linux filesystem

.. note::

   以上分区操作在3台存储虚拟机上完成

尝试一: ``ceph-volume lvm create``
=====================================

- 创建第一个OSD，注意我使用了统一的 ``data`` 存储来存放所有数据，包括 ``block.db`` 和 ``block.wal`` ::

   sudo ceph-volume lvm create --data /dev/nvme0n1p1

.. note::

   实际上Ceph在底层就是使用LVM卷来作为存储，即使指定使用磁盘分区，也是在这个磁盘分区上创建一个 LVM 逻辑卷再用于BlueStore。这样的好处应该是后续可以通过扩容底层LVM卷，可以不断扩容BlueStore的OSD存储大小。

.. note::

   使用 ``ceph-volume lvm create`` 命令一次就可以完成OSD卷创建和激活。此外，也可以把命令拆分成先 ``prepare`` 再 ``activate`` 两个步骤::

      sudo ceph-volume lvm prepare --data /dev/nvme0n1p1
      sudo ceph-volume lvm list
      # sudo ceph-volume lvm activate {ID} {FSID}
      sudo ceph-volume lvm activate 0 a7f64266-0894-4f1e-a635-d0aeaca0e993

注意，这里由于我没有使用默认的 ``ceph`` 作为存储集群名字 ( ``zdata`` )，所以会导致报错::

   Running command: /usr/bin/ceph-authtool --gen-print-key
   -->  RuntimeError: No valid ceph configuration file was loaded.

``ceph-volume --help`` 显示这个命令提供了参数 ``[--cluster CLUSTER]``

我又尝试了::

   sudo ceph-volume lvm create --data /dev/nvme0n1p1 --cluster zdata

报错依旧::

   Running command: /usr/bin/ceph-authtool --gen-print-key
   Running command: /usr/bin/ceph --cluster ceph --name client.bootstrap-osd --keyring /var/lib/ceph/bootstrap-osd/ceph.keyring -i - osd new 732265cb-44fe-4d32-a92c-4d5ee4056c36
    stderr: Error initializing cluster client: ObjectNotFound('RADOS object not found (error calling conf_read_file)')
    -->  RuntimeError: Unable to create a new OSD id

在 `Manual deployment of an OSD failed <https://lists.ceph.io/hyperkitty/list/ceph-users@ceph.io/thread/KLHVIJCNUA5UP2FSY44UX3A67UFSNX5G/>`_ 讨论中，有人提出了只能使用 ``ceph`` 作为集群名字来避免问题，虽然提问人说他使用了 ``--cluster`` 参数::

   ceph-volume lvm create --data /dev/sdb --cluster euch01

他的报错和我相同

我注意到上述命令输出中始终参数是 ``--cluster ceph`` ，也就是说工具并没有获得传递的集群名字。在 `Red Hat Ceph Storage 3 Installation Guide > Appendix B. Manually Installing Red Hat Ceph Storage <https://access.redhat.com/documentation/en-us/red_hat_ceph_storage/3/html/installation_guide_for_red_hat_enterprise_linux/manually-installing-red-hat-ceph-storage>`_  提到::

   For storage clusters with custom names, as root, add the the following line:

   echo "CLUSTER=<custom_cluster_name>" >> /etc/sysconfig/ceph

但我在Ubuntu上无效

- 我发现此时 ``ceph -s`` 显示已经创建了一个 ``pools`` 但是没有osd::

   cluster:
     id:     53c3f770-d869-4b59-902e-d645eca7e34a
     health: HEALTH_WARN
             Reduced data availability: 1 pg inactive
             OSD count 0 < osd_pool_default_size 3
   services:
     mon: 1 daemons, quorum z-b-data-1 (age 31h)
     mgr: z-b-data-1(active, since 26h)
     osd: 0 osds: 0 up, 0 in
   data:
     pools:   1 pools, 1 pgs
     objects: 0 objects, 0 B
     usage:   0 B used, 0 B / 0 B avail
     pgs:     100.000% pgs unknown
              1 unknown

- 我这里做了一个尝试，手工建立了一个软链接(实际不行)::

   ln -s /etc/ceph/zdata.conf /etc/ceph/ceph.conf
   ln -s /etc/ceph/zdata.client.admin.keyring /etc/ceph/ceph.client.admin.keyring

然后执行 ``ceph-volume lvm create --data /dev/nvme0n1p1`` 虽然能绕过 ``ceph`` 命令的 ``--cluster ceph`` ，但是无法解决一系列的密钥查询(可能也可以为密钥建立软链接，但是不是正途)

对于错误失败(但是已经建立了Ceph LVM卷)采用如下命令抹除::

   sudo ceph-volume lvm zap --destroy /dev/nvme0n1p1

可以看到整个过程其实就是一个销毁卷信息的过程::

   --> Zapping: /dev/nvme0n1p1
   --> Zapping lvm member /dev/nvme0n1p1. lv_path is /dev/ceph-a6206131-bbff-4e20-a0ae-a1029e1c8484/osd-block-b8840e07-4061-4240-8247-30b8c4d22d1d
   --> Unmounting /var/lib/ceph/osd/ceph-0
   Running command: /usr/bin/umount -v /var/lib/ceph/osd/ceph-0
    stderr: umount: /var/lib/ceph/osd/ceph-0 unmounted
   Running command: /usr/bin/dd if=/dev/zero of=/dev/ceph-a6206131-bbff-4e20-a0ae-a1029e1c8484/osd-block-b8840e07-4061-4240-8247-30b8c4d22d1d bs=1M count=10 conv=fsync
    stderr: 10+0 records in
   10+0 records out
    stderr: 10485760 bytes (10 MB, 10 MiB) copied, 0.0246407 s, 426 MB/s
   --> Only 1 LV left in VG, will proceed to destroy volume group ceph-a6206131-bbff-4e20-a0ae-a1029e1c8484
   Running command: /usr/sbin/vgremove -v -f ceph-a6206131-bbff-4e20-a0ae-a1029e1c8484
    stderr: Removing ceph--a6206131--bbff--4e20--a0ae--a1029e1c8484-osd--block--b8840e07--4061--4240--8247--30b8c4d22d1d (253:0)
    stderr: Archiving volume group "ceph-a6206131-bbff-4e20-a0ae-a1029e1c8484" metadata (seqno 5).
    stderr: Releasing logical volume "osd-block-b8840e07-4061-4240-8247-30b8c4d22d1d"
    stderr: Creating volume group backup "/etc/lvm/backup/ceph-a6206131-bbff-4e20-a0ae-a1029e1c8484" (seqno 6).
    stdout: Logical volume "osd-block-b8840e07-4061-4240-8247-30b8c4d22d1d" successfully removed
    stderr: Removing physical volume "/dev/nvme0n1p1" from volume group "ceph-a6206131-bbff-4e20-a0ae-a1029e1c8484"
    stdout: Volume group "ceph-a6206131-bbff-4e20-a0ae-a1029e1c8484" successfully removed
   Running command: /usr/bin/dd if=/dev/zero of=/dev/nvme0n1p1 bs=1M count=10 conv=fsync
    stderr: 10+0 records in
   10+0 records out
    stderr: 10485760 bytes (10 MB, 10 MiB) copied, 0.0295389 s, 355 MB/s
   --> Destroying partition since --destroy was used: /dev/nvme0n1p1
   Running command: /usr/sbin/parted /dev/nvme0n1 --script -- rm 1
   --> Zapping successful for: <Partition: /dev/nvme0n1p1>

不过上述过程也会移除 ``/dev/nvme0n1p1`` 分区 ( ``Destroying partition since --destroy was used: /dev/nvme0n1p1`` ) ，或许下次可以试试不使用 ``--destory`` ，只执行 ``sudo ceph-volume lvm zap /dev/nvme0n1p1``

重新再使用 ``parted`` 划分分区::

   parted /dev/nvme0n1 mklabel gpt
   parted -a optimal /dev/nvme0n1 mkpart primary 0% 700GB

.. note::

   我仔细看了Red Hat的manual install文档，发现Red Hat文档拆解的命令更为详细，实际上只要把 ``ceph-volume`` 的包装的命令拆细成更多的实际命令，就可以绕过这个不传递cluster名字的问题。

   例如 ``ceph-volume`` 没有 ``--cluster`` 参数，但是被包装的 ``ceph`` 命令是有 ``--cluster`` 参数的，所以拆细以后的命令应该可以实现。最主要是分析 ``ceph-volume`` 实际操作命令

拆解命令尝试
===============

仔细看了 `Manual deployment of an OSD failed <https://lists.ceph.io/hyperkitty/list/ceph-users@ceph.io/thread/KLHVIJCNUA5UP2FSY44UX3A67UFSNX5G/>`_ 讨论，看起来方法是先执行 ``ceph-volume create`` 命令时带参数 ``--cluster <CLUSTER>`` ，然后对出错的子命令再单独单独执行，此时加上传递集群或配置文件的参数。

- 重新开始创建::

   sudo ceph-volume lvm create --data /dev/nvme0n1p1 --cluster zdata

提示信息::

   Running command: /usr/bin/ceph-authtool --gen-print-key
   Running command: /usr/bin/ceph --cluster ceph --name client.bootstrap-osd --keyring /var/lib/ceph/bootstrap-osd/ceph.keyring -i - osd new 5e95a8da-bae5-478d-a7e6-659e20dfb7ad
    stderr: Error initializing cluster client: ObjectNotFound('RADOS object not found (error calling conf_read_file)')
    -->  RuntimeError: Unable to create a new OSD id

- 第二条命令执行失败，则修订执行第二条命令::

   sudo /usr/bin/ceph --cluster zdata --name client.bootstrap-osd --keyring /var/lib/ceph/bootstrap-osd/ceph.keyring -i - osd new 5e95a8da-bae5-478d-a7e6-659e20dfb7ad

测试提示::

   2021-11-25T21:43:31.484+0800 7fa5c5a5c700 -1 auth: unable to find a keyring on /etc/ceph/zdata.client.bootstrap-osd.keyring,/etc/ceph/zdata.keyring,/etc/ceph/keyring,/etc/ceph/keyring.bin,: (2) No such file or directory
   2021-11-25T21:43:31.484+0800 7fa5c5a5c700 -1 AuthRegistry(0x7fa5c00592a0) no keyring found at /etc/ceph/zdata.client.bootstrap-osd.keyring,/etc/ceph/zdata.keyring,/etc/ceph/keyring,/etc/ceph/keyring.bin,, disabling cephx

并卡住没有返回

上述命令已经传递了参数 ``--keyring /var/lib/ceph/bootstrap-osd/ceph.keyring`` 但为何提示信息还是显示 ``auth: unable to find a keyring`` ，看起来会查看对应集群名字的 ``/etc/ceph/zdata.client.bootstrap-osd.keyring`` ，所以先复制过来::

   sudo cp /var/lib/ceph/bootstrap-osd/ceph.keyring /etc/ceph/zdata.client.bootstrap-osd.keyring

- 重新执行第二条命令::

   sudo /usr/bin/ceph --cluster zdata --name client.bootstrap-osd --keyring /var/lib/ceph/bootstrap-osd/ceph.keyring -i - osd new 5e95a8da-bae5-478d-a7e6-659e20dfb7ad

此时不再提示信息，但是卡住不返回

后来我看了 ``ceph --help`` ，原来::

   -i INPUT_FILE, --in-file INPUT_FILE
                        input file, or "-" for stdin

也就是使用了 ``-i -`` 就会等待标准输入，这是一个输入入文件

尝试ceph.conf
=================

由于太多命令采用了 ``ceph`` 默认集群名字，所以我尝试做一个软链接看看究竟是哪些命令运行::

   cd /etc/ceph
   ln -s zdata.client.admin.keyring ceph.client.admin.keyring
   ln -s zdata.client.bootstrap-osd.keyring ceph.client.bootstrap-osd.keyring
   ln -s zdata.conf ceph.conf

- 执行osd创建::

   sudo ceph-volume lvm create --data /dev/nvme0n1p1

原来完整过程有如下执行::

   Running command: /usr/bin/ceph-authtool --gen-print-key
   Running command: /usr/bin/ceph --cluster ceph --name client.bootstrap-osd --keyring /var/lib/ceph/bootstrap-osd/ceph.keyring -i - osd new bce0e1a5-4b01-4be6-bfbc-d3dfc1037e01
   Running command: /usr/sbin/vgcreate --force --yes ceph-57827388-ad92-4bab-aa37-8dd5ce09577c /dev/nvme0n1p1
    stdout: Physical volume "/dev/nvme0n1p1" successfully created.
    stdout: Volume group "ceph-57827388-ad92-4bab-aa37-8dd5ce09577c" successfully created
   Running command: /usr/sbin/lvcreate --yes -l 166892 -n osd-block-bce0e1a5-4b01-4be6-bfbc-d3dfc1037e01 ceph-57827388-ad92-4bab-aa37-8dd5ce09577c
    stdout: Logical volume "osd-block-bce0e1a5-4b01-4be6-bfbc-d3dfc1037e01" created.
   Running command: /usr/bin/ceph-authtool --gen-print-key
   Running command: /usr/bin/mount -t tmpfs tmpfs /var/lib/ceph/osd/ceph-0
   --> Executable selinuxenabled not in PATH: /usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/snap/bin
   Running command: /usr/bin/chown -h ceph:ceph /dev/ceph-57827388-ad92-4bab-aa37-8dd5ce09577c/osd-block-bce0e1a5-4b01-4be6-bfbc-d3dfc1037e01
   Running command: /usr/bin/chown -R ceph:ceph /dev/dm-0
   Running command: /usr/bin/ln -s /dev/ceph-57827388-ad92-4bab-aa37-8dd5ce09577c/osd-block-bce0e1a5-4b01-4be6-bfbc-d3dfc1037e01 /var/lib/ceph/osd/ceph-0/block
   Running command: /usr/bin/ceph --cluster ceph --name client.bootstrap-osd --keyring /var/lib/ceph/bootstrap-osd/ceph.keyring mon getmap -o /var/lib/ceph/osd/ceph-0/activate.monmap
    stderr: got monmap epoch 2
   Running command: /usr/bin/ceph-authtool /var/lib/ceph/osd/ceph-0/keyring --create-keyring --name osd.0 --add-key AQAInJ9hb0CHFxAAR27RvWMir4TrC0YWU3/X0Q==
    stdout: creating /var/lib/ceph/osd/ceph-0/keyring
    stdout: added entity osd.0 auth(key=AQAInJ9hb0CHFxAAR27RvWMir4TrC0YWU3/X0Q==)
   Running command: /usr/bin/chown -R ceph:ceph /var/lib/ceph/osd/ceph-0/keyring
   Running command: /usr/bin/chown -R ceph:ceph /var/lib/ceph/osd/ceph-0/
   Running command: /usr/bin/ceph-osd --cluster ceph --osd-objectstore bluestore --mkfs -i 0 --monmap /var/lib/ceph/osd/ceph-0/activate.monmap --keyfile - --osd-data /var/lib/ceph/osd/ceph-0/ --osd-uuid bce0e1a5-4b01-4be6-bfbc-d3dfc1037e01 --setuser ceph --setgroup ceph
    stderr: 2021-11-25T22:22:01.692+0800 7f3fa7cb5d80 -1 bluestore(/var/lib/ceph/osd/ceph-0/) _read_fsid unparsable uuid
    stderr: 2021-11-25T22:22:01.736+0800 7f3fa7cb5d80 -1 freelist read_size_meta_from_db missing size meta in DB
   --> ceph-volume lvm prepare successful for: /dev/nvme0n1p1
   Running command: /usr/bin/chown -R ceph:ceph /var/lib/ceph/osd/ceph-0
   Running command: /usr/bin/ceph-bluestore-tool --cluster=ceph prime-osd-dir --dev /dev/ceph-57827388-ad92-4bab-aa37-8dd5ce09577c/osd-block-bce0e1a5-4b01-4be6-bfbc-d3dfc1037e01 --path /var/lib/ceph/osd/ceph-0 --no-mon-config
   Running command: /usr/bin/ln -snf /dev/ceph-57827388-ad92-4bab-aa37-8dd5ce09577c/osd-block-bce0e1a5-4b01-4be6-bfbc-d3dfc1037e01 /var/lib/ceph/osd/ceph-0/block
   Running command: /usr/bin/chown -h ceph:ceph /var/lib/ceph/osd/ceph-0/block
   Running command: /usr/bin/chown -R ceph:ceph /dev/dm-0
   Running command: /usr/bin/chown -R ceph:ceph /var/lib/ceph/osd/ceph-0
   Running command: /usr/bin/systemctl enable ceph-volume@lvm-0-bce0e1a5-4b01-4be6-bfbc-d3dfc1037e01
    stderr: Created symlink /etc/systemd/system/multi-user.target.wants/ceph-volume@lvm-0-bce0e1a5-4b01-4be6-bfbc-d3dfc1037e01.service → /lib/systemd/system/ceph-volume@.service.
   Running command: /usr/bin/systemctl enable --runtime ceph-osd@0
   Running command: /usr/bin/systemctl start ceph-osd@0
    stderr: Job for ceph-osd@0.service failed because the control process exited with error code.
   See "systemctl status ceph-osd@0.service" and "journalctl -xe" for details.
   --> Was unable to complete a new OSD, will rollback changes
   Running command: /usr/bin/ceph --cluster ceph --name client.bootstrap-osd --keyring /var/lib/ceph/bootstrap-osd/ceph.keyring osd purge-new osd.0 --yes-i-really-mean-it
    stderr: purged osd.0
   -->  RuntimeError: command returned non-zero exit status: 1

可以看到出错在于启动过程

   

参考
=======

- `Ceph document - Installation (Manual) <http://docs.ceph.com/docs/master/install/>`_
