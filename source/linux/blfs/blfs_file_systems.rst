.. _blfs_file_systems:

=====================
BLFS文件系统
=====================

.. _blfs_initramfs:

initramfs
============

``initramfs`` 的唯一用途是挂载根文件系统:

- initramfs是在普通根文件系统上可以找到的一套完整目录
- initramfs被捆绑到单个 ``cpio`` 归档中，并使用几种压缩算法之一进行压缩

在系统启动时，引导加载程序将内核和 ``initramfs`` 映像加载到内存中并启动黑河。内核检查 ``initramfs`` 是否存在，如果找到，就将其挂载为 ``/`` 并运行 ``/init`` 。 ``init`` 通常是一个shell脚本。

注意，如果使用 ``initramfs`` ，启动过程将花费更长时间，甚至可能长很多。

构建initramfs
-------------------

以下脚本是一个基本 ``initramfs`` ，允许通过 ``分区UUID`` 或 ``分区LABEL`` 或 LVM逻辑卷的一个rootfs 来指定 ``rootfs`` 。该脚本不支持加密root文件系统或者从网卡挂载rootfs。如果需要更完整能力，则参考 `the LFS Hints <https://www.linuxfromscratch.org/hints/read.html>`_ 或者 :ref:`dracut`

- 安装以下脚本:

.. literalinclude:: blfs_file_systems/mkinitramfs
   :caption: 创建 ``mkinitramfs`` 脚本

.. literalinclude:: blfs_file_systems/init.in
   :caption: 创建 ``init.in`` 脚本

使用initramfs
-------------------

- 在使用 ``initramfs`` 之前必须完成 :ref:`blfs_cpio`

- 如果系统分区使用了 LVM 或 mdadm ，则必须先安装这两个工具才能执行 ``initramfs`` (目前我没有)

- 生成 ``initramfs`` 运行命令

.. literalinclude:: blfs_file_systems/mkinitramfs_6.10.5
   :caption: 构建 ``6.10.5`` 内核的 initramfs

这里参数 ``6.10.5`` 是可选的，也就是 ``/lib/modules`` 的一个子目录。如果没有modules指定，那么将生成名为 ``initrd.img-no-kmods`` ，如果指定内核版本，就会生成 ``initrd.img-$KERNEL_VERSION`` 用于特定内核。输出文件存放在当前目录。

.. literalinclude:: blfs_file_systems/mkinitramfs_6.10.5_output
   :caption: 构建 ``6.10.5`` 内核的 initramfs 输出文件案例

.. note::

   如果已经在 :ref:`blfs_micorcode` 中已经将 ``intel-ucode`` 目录完整复制到 ``/lib/firmware`` 目录下，那么 ``mkinitramfs`` 会自动添加到 ``intrd`` 中(也就是不需要独立的 ``microcode.img`` 了。

   不过， ``grub.cfg`` 中 ``initrd`` 可以加载多个 ``img`` ::

      initrd /microcode.img /other-initrd.img

- 最后修订 ``/boot/grub/grub.cfg`` 添加一行:

.. literalinclude:: blfs_file_systems/grub.cfg
   :caption: 修订grub.cfg添加initrd
   :emphasize-lines: 4

.. warning::

   目前我实际还没有添加 ``initrd.img-6.10.5`` 配置行，因为目前还没有需要特别预先加载的内核模块和工具。

   目前我还是只使用 :ref:`blfs_micorcode` 预先加载CPU微码

   如果后续有需要我再添加 ``initramfs``
