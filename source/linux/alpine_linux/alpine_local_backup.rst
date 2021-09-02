.. _alpine_local_backup:

========================
Alpine Linux本地备份
========================

Alpine Linux以diskless模式启动时，只会从启动设备中加载一些必要的软件包。然后，本地修改内存中的数据(操作系统加载到内存中运行)是可能的，例如，安装软件包或者修改 ``/etc`` 目录中配置文件。这些修改通过一个 overlay 文件保存 ( ``.apkovl`` )，就好像 :ref:`docker` 使用了分层的overlay文件系统，这样就能够在启动时自动加载，恢复到保存的状态。

``.apkovl`` 文件包含了自定义配置，可以使用 Alpine的本地备份工具 ``lbu`` 保存到可写入存储中。

.. note::

   如果是以 ``sys`` 磁盘模式来安装Alpine，也就是传统的将操作系统安装到本地磁盘，是不需要使用 ``lbu`` 来保存系统状态。

.. warning::

   默认情况下， ``lbu commit`` 只保存 ``/etc`` 目录下的修改，但不包括 ``/etc/init.d/`` 子目录。不过，可以使用 ``lbu include`` 来包含更多指定文件或者目录来进行备份。

保存和加载自定义ISO镜像
========================

Alpine的 ``diskless mode`` ISO镜像会尝试从系统分区加载一个 ``.apkovl`` 卷，这样就可以将定制的运行状态保存到一个可写入分区的 ``.apkovl`` 文件，然后在启动是自动加载。

.. note::

   当主机重启时，在网络启动之前是无法使用远程软件仓库的。这意味着重启后本地启动介质中软件包较为陈旧，除非使用 ``local package cache`` 来把软件包更新持久化到本地可写入的存储设备。

本地包缓存(local package cache)，是使用 ``.apkovl`` 文件中保存的数据，将增加和更新过的软件包自动复制到内存中。

要使用内部磁盘的分区，需要手工修改 ``/etc/fstab`` ，并且保存配置:

- 使用diskless系统从ISO启动系统

- 根据需要，创建和格式化一个分区，例如，我使用U盘( ``/dev/sdb`` )的剩余空间创建一个分区 - 使用 ``cfdisk`` 较为方便，我发现 ``parted`` 似乎无法查看ISO镜像中的分区::

   cfdisk /dev/sdb

交互模式完成简单分区::

                                                                                                  Disk: /dev/sdb
                                                                               Size: 28.65 GiB, 30765219840 bytes, 60088320 sectors
                                                                                        Label: dos, identifier: 0x65428faa
   
       Device                      Boot                                   Start                      End                  Sectors                  Size                 Id Type
       /dev/sdb1                   *                                          0                  1224703                  1224704                  598M                  0 Empty
       /dev/sdb2                                                            460                     3339                     2880                  1.4M                 ef EFI (FAT-12/16/32)
   >>  /dev/sdb3                                                        1224704                 60088319                 58863616                 28.1G                 83 Linux

完成后，使用 ``fdisk -l /dev/sdb`` 可以看到::

   Disk /dev/sdb: 29 GB, 30765219840 bytes, 60088320 sectors
   29340 cylinders, 64 heads, 32 sectors/track
   Units: sectors of 1 * 512 = 512 bytes
   
   Device  Boot StartCHS    EndCHS        StartLBA     EndLBA    Sectors  Size Id Type
   /dev/sdb1 *  0,0,1       597,63,32            0    1224703    1224704  598M  0 Empty
   /dev/sdb2    1023,254,63 1023,254,63        460       3339       2880 1440K ef EFI (FAT-12/16/32)
   /dev/sdb3    76,59,48    668,82,54      1224704   60088319   58863616 28.0G 83 Linux

- 格式化分区::

   apk add e2fsprogs

   mkfs.ext4 /dev/sdb3

- 挂载分区::

   mkdir /media/sdb3
   mount /dev/sdb3 /media/sdb3

- 检查挂载::

   df -h

显示::

   Filesystem                Size      Used Available Use% Mounted on
   devtmpfs                 10.0M         0     10.0M   0% /dev
   shm                       7.8G         0      7.8G   0% /dev/shm
   /dev/sdb1               598.0M    598.0M         0 100% /media/sdb1
   tmpfs                     7.8G     23.9M      7.8G   0% /
   tmpfs                     3.1G    112.0K      3.1G   0% /run
   /dev/loop0               99.4M     99.4M         0 100% /.modloop
   /dev/sdb3                27.5G     24.0K     26.0G   0% /media/sdb3

- 然后在 ``setup-alpine`` 中就可以使用这个 ``sdb3`` 作为存储配置以及apk缓存目录 ``/media/sdb3/cache``

参考
======

- `Alpine local backup <https://wiki.alpinelinux.org/wiki/Alpine_local_backup>`_
