.. _docker_run_add_host_device:

===========================
添加host设备到容器
===========================

Host主机LVM卷映射添加到容器
=============================

在 :ref:`ceph_docker_in_studio` 创建了5个LVM卷设备，分别准备用于5个Ceph容器::

   ls -lh /dev/mapper/

::

   lrwxrwxrwx 1 root root       7 4月  11 10:00 ceph-data1 -> ../dm-0
   lrwxrwxrwx 1 root root       7 4月  11 10:00 ceph-data2 -> ../dm-1
   lrwxrwxrwx 1 root root       7 4月  11 10:00 ceph-data3 -> ../dm-2
   lrwxrwxrwx 1 root root       7 4月  11 10:00 ceph-data4 -> ../dm-3
   lrwxrwxrwx 1 root root       7 4月  11 10:00 ceph-data5 -> ../dm-4

- 创建::

   docker run -itd --hostname ceph-1 --name ceph-1 -v data:/data \
      --net ceph-net --ip 172.18.0.11 \
      --device=/dev/mapper/ceph-data1:/dev/xvdc local:ubuntu18.04-ssh

- 登陆 ``ceph-1`` 容器内部检查磁盘设备::

   root@ceph-1:/# ls -lh /dev/xvdc
   brw-rw---- 1 root disk 253, 0 Apr 11 02:17 /dev/xvdc

.. note::

   现在在容器 ``ceph-1`` 内部可以使用这个块设备，也就可以部署Ceph服务了。

按照上述方法重复，再创建4个ceph容器，分别命名为 ``ceph-2`` 到 ``ceph-5`` 备用，具体IP地址参考 :ref:`studio_ip` ::

   for i in {2..5};do
     docker run -itd --hostname ceph-$i --name ceph-$i -v data:/data \
         --net ceph-net --ip 172.18.0.1$i \
         --device=/dev/mapper/ceph-data$i:/dev/xvdc local:ubuntu18.04-ssh
   done

完成后使用 ``docker ps`` 检查应该具备如下5个容器::

   CONTAINER ID        IMAGE                   COMMAND                  CREATED             STATUS              PORTS               NAMES
   98b6eb9374eb        local:ubuntu18.04-ssh   "/bin/sh -c '/usr/sb…"   51 seconds ago      Up 50 seconds       1122/tcp            ceph-5
   0d1d9bf1db2f        local:ubuntu18.04-ssh   "/bin/sh -c '/usr/sb…"   2 minutes ago       Up 2 minutes        1122/tcp            ceph-4
   abfd47525b91        local:ubuntu18.04-ssh   "/bin/sh -c '/usr/sb…"   2 minutes ago       Up 2 minutes        1122/tcp            ceph-3
   692665ba620c        local:ubuntu18.04-ssh   "/bin/sh -c '/usr/sb…"   2 minutes ago       Up 2 minutes        1122/tcp            ceph-2
   93b0abd529e7        local:ubuntu18.04-ssh   "/bin/sh -c '/usr/sb…"   About an hour ago   Up About an hour    1122/tcp            ceph-1

参考
========

- `Docker run - Add host device to container (--device) <https://docs.docker.com/engine/reference/commandline/run/#add-host-device-to-container---device>`_
