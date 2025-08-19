.. _bhyve_ubuntu_extend_ext4_on_lvm:

=============================================
bhyve上Ubuntu虚拟机扩展LVM上的EXT4文件系统
=============================================

我在 :ref:`bhyve` 虚拟化环境中部署 :ref:`ubuntu_linux` 来构建 :ref:`rocm_quickstart` ，但是我发现，之前 :ref:`bhyve_ubuntu` 创建的是稀疏卷，总共分配了 ``60GB`` ZFS稀疏卷，不过Ubuntu Server部署时，自动只使用了一半空间(小于安装部署 :ref:`rocm` 要求):

- 在虚拟机内部检查磁盘空间:

.. literalinclude:: bhyve_ubuntu_extend_ext4_on_lvm/fdisk
   :caption: 虚拟机内部 fdisk 检查磁盘空间

可以看到 ``60GiB`` 空间，LVM根卷只使用了 ``28.47GiB`` :

.. literalinclude:: bhyve_ubuntu_extend_ext4_on_lvm/fdisk_output
   :caption: 虚拟机内部 fdisk 检查磁盘空间 输出信息 
   :emphasize-lines: 1,14

- ``df`` 可以看到LVM卷 ``ubuntu--vg-ubuntu--lv`` 挂载为 ``/`` ，只分配了 ``28G`` :

.. literalinclude:: bhyve_ubuntu_extend_ext4_on_lvm/df_output
   :caption: 检查 ``df -h`` 输出
   :emphasize-lines: 4

- 在虚拟机内部检查lvm卷(分别使用 ``lvs`` , ``pvdisplay`` , ``vgdisplay`` 和 ``lvdisplay`` 检查):

.. literalinclude:: bhyve_ubuntu_extend_ext4_on_lvm/lvm_output
   :caption: 检查lvm卷
   :emphasize-lines: 3,32,35,36

可以看到:

  - ``pv`` 是完全分配整个磁盘空间 (60GB)
  - ``vg`` 完整占用了VG( ``<56.95 GiB`` )，但只划分了 ``28.47 GiB`` PE用于 ``lv`` ，还有 ``28.47GiB Free PE``
  - ``lv`` 大小 ``28.47 GiB`` ，还有剩余但 ``28.47 GiB`` **vg** 空着没有占用

**解决方法是扩展 lv，然后再扩展ext4文件系统** : 方法参考 :ref:`extend_ext4_on_lvm` (注意只需要 ``lvextend`` ，因为**vg** 是满分配的)

- 扩容lvm ( **lv** ):

.. literalinclude:: bhyve_ubuntu_extend_ext4_on_lvm/lvextend
   :caption: 扩容 ``lv`` 占据整个 ``vg``

输出显示成功扩容lv到 ``<56.95 GiB`` :

.. literalinclude:: bhyve_ubuntu_extend_ext4_on_lvm/lvextend_output
   :caption: 扩容 ``lv`` 占据整个 ``vg`` 输出显示成功

- 再次检查 ``vgdisplay`` 看是否完整分配了 vg:

.. literalinclude:: bhyve_ubuntu_extend_ext4_on_lvm/vgdisplay_all
   :caption: ``vgdisplay`` 显示现在整个vg已经分配完
   :emphasize-lines: 18,19

-  EXT4文件系统支持在线扩展，所以对挂载对EXT4文件系统( ``/`` )扩容:

.. literalinclude:: bhyve_ubuntu_extend_ext4_on_lvm/resize2fs
   :caption: 在线扩展 ``/`` 挂载的EXT4文件系统

输出显示

.. literalinclude:: bhyve_ubuntu_extend_ext4_on_lvm/resize2fs_output
   :caption: 在线扩展 ``/`` 挂载的EXT4文件系统显示完成

- 现在使用 ``df -h`` 检查，就可以看到原先 ``28G`` 的根目录现在扩展到了 ``56G`` :

.. literalinclude:: bhyve_ubuntu_extend_ext4_on_lvm/df_after_resize2fs
   :caption: 扩容完成后的根文件系统
   :emphasize-lines: 4

一切就绪，现在可以继续 :ref:`rocm_quickstart` 
