.. _remove_ceph:

================
删除Ceph集群
================

我在 :ref:`mobile_cloud_ceph_add_ceph_mons` 时遇到无法正常部署 ``ceph-mon`` ，而且也没有办法回滚到最初 :ref:`mobile_cloud_ceph_mon` 正常的操作状态。由于是测试环境，想快速恢复，所以采用删除Ceph集群，重新开始 :ref:`mobile_cloud_ceph_mon` 等安装步骤。

- 在每个节点上按需停止服务(已安装服务)::

   sudo systemctl stop ceph-mon@`hostname -s`
   sudo systemctl disable ceph-mon@`hostname -s`

   sudo systemctl stop ceph-osd@`hostname -s`
   sudo systemctl disable ceph-osd@`hostname -s`

   sudo systemctl stop ceph-mgr@`hostname -s`
   sudo systemctl disable ceph-mgr@`hostname -s`

如果进程没有停止，则手工 ``kill`` 掉

- ``osd`` 有一个本地挂载的 ``tmpfs`` ( ``/var/lib/ceph/osd/ceph-0`` ) 需要卸载，然后再删除掉数据目录 ``/var/lib/ceph`` ::

   sudo umount /var/lib/ceph/osd/ceph-0
   sudo rm -rf /var/lib/ceph

- 清理掉 ``/etc/ceph`` 目录下证书文件(下一次新建集群会重新创建) ，备份配置文件::

   sudo rm -f /etc/ceph/ceph.client.admin.keyring
   sudo mv /etc/ceph/ceph.conf /etc/ceph/ceph.conf.bak

- 删除 ``osd`` 卷(这里命令是简单操作，没有考虑复杂的逻辑，例如只有本地一个osd卷)::

   lv=`sudo lvdisplay | grep "LV Path" | awk '{print $3}'`
   sudo lvremove $lv -y

   vg=`sudo vgdisplay | grep "VG Name" | awk '{print $3}'`
   sudo vgremove $vg -y

   pv=`sudo pvdisplay | grep "PV Name" | awk '{print $3}'`
   sudo pvremove $pv -y

- 重启各个服务器节点

参考
======

- `How to Completely remove/delete or reinstall ceph and its configuration from Proxmox VE (PVE) <https://dannyda.com/2021/04/10/how-to-completely-remove-delete-or-reinstall-ceph-and-its-configuration-from-proxmox-ve-pve/>`_
