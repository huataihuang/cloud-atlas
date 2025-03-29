.. _reserved_space_for_root_on_filesystem:

=========================
文件系统为root保留空间
=========================

我在生产环境为一个海量存储做 :ref:`rsync` 同步数据的时候，由于原存储和新存储是相同规格的，并且原存储磁盘已经100%打爆，所以我担心新存储空间也会被同步的数据打爆，所以在服务器上硬抠了一个分区作为 :ref:`extend_ext4_on_lvm` 。但是，我发现同步到最后， ``df -h`` 还是显示磁盘已经 100% 满了。

正当我感叹运气不佳的时候，我发现通过 :ref:`screen` ``-dm`` 参数正在运行的 ``rsync`` 同步完全没有报错，依然稳稳地向 ``EXT4`` 文件系统中写入数据。why?

灵光一闪，我想起来，以前学习过: 文件系统 **默认** 为 ``root`` 用户保留了 5% 空间作为应急，避免普通用户将磁盘打爆之后导致 ``root`` 用户也无法登陆维护的特性。关键时刻，真是救命了: 没有让我为这海量数据同步花费的精力白费!

.. note::

   这次 ``rsync`` 恰好是使用 ``root`` 用户账号，所以能够使用这 5% 的保留空间

我们再来温习一下

文件系统保留空间的用途:

- 为重要的 ``root`` 用户进程提供保留空间，以及救援所需空间
- 以前的 ``ext3`` 文件系统虽然能够很大程度上避免文件系统碎片，但是一旦达到 95% 的使用率会出现性能急剧下降，所以保留 5% 空间可以提供缓冲
- 现代的 ``ext4`` 文件系统已经不存在碎片导致的性能急剧下降(即使文件系统超过 95% 使用率接近满的情况)，所以如果

如果使用文件系统进行长期存档，例如保存视频，文档不经常改动，则可以调整文件系统默认的保留空间大小，甚至调整为0

检查
=======

- 使用 ``tune2fs`` 命令可以检查文件系统分区的保留空间等信息:

.. literalinclude:: reserved_space_for_root_on_filesystem/tune2fs
   :caption: 使用 ``tune2fs`` 命令检查磁盘分区

输出显示

.. literalinclude:: reserved_space_for_root_on_filesystem/tune2fs_output
   :caption: 使用 ``tune2fs`` 命令检查磁盘分区
   :emphasize-lines: 11,12

可以看到保留的空间百分比: 144079151/3194129408=0.0451 ，也就是保留了 4.5% 左右空间。由于我在 :ref:`extend_ext4_on_lvm` 扩展的存储空间高达 12T ，这样保留的空间也非常可观

降低ext4文件系统保留空间
==========================

对于大规格存储，例如10TB存储，每1%的空间都是巨大的。所以我们可以适当调整保留空间，节约存储空间。 ``tun2fs`` 命令提供了 ``-m`` 参数用来调整保留百分比，例如 ``-m 1`` 表示只保留 1% ，而设置 ``-m 0`` 则完全不保留空间。

举例::

   tune2fs -m 0 /dev/mapper/vg--data-lv--thanos

则完全关闭存储空间的保留空间，可以节约出大约 600G 空间(12T总容量)。紧急情况戏，如果某个应用写满了磁盘无法运行，应急时可以尝试释放这部分空间

参考
======

- `Reserved space for root on a filesystem - why? <https://unix.stackexchange.com/questions/7950/reserved-space-for-root-on-a-filesystem-why>`_
- `Linux : How to reduce the percentage of reserved blocks on ext4 filesystem <https://www.itechlounge.net/2022/10/linux-how-to-reduce-the-percentage-of-reserved-blocks-on-ext4-filesystem/>`_
