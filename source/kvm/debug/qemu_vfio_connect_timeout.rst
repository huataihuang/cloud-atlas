.. _qemu_vfio_connect_timeout:

==========================
虚拟机启动访问vfio设备超时
==========================

今天在解决 :ref:`ceph_extend_rbd_drive_with_libvirt_xfs` 采用了将两个 :ref:`ceph_rbd` 设备连接到另外一个用于维护的虚拟机中处理磁盘扩容。但是，非常意外地发现，当我关闭了维护的虚拟机 ``z-dev`` 之后，想要恢复原先使用 :ref:`ceph_rbd` 的 ``y-k8s-n-1`` 却出现vfio设备连接超时:

.. literalinclude:: qemu_vfio_connect_timeout/vfio_used_error
   :caption: 启动虚拟机时vfio设备报告已被使用，连接超时

这里的报错繁忙设备 ``3eb9d560-0b31-11ee-91a9-bb28039c61eb`` 在 ``virsh dumpxml y-k8s-n-1`` 可以看到其实就是 :ref:`vgpu_quickstart` 配置的2个 :ref:`vgpu` 设置之一:

.. literalinclude:: ../vgpu/vgpu_quickstart/vgpu_create_output_1
   :language: bash
   :caption: 执行 ``vgpu_create`` 脚本创建2个 ``P40-12C`` :ref:`vgpu` 输出信息第 **一** 个vgpu设备

这是一个 ``mdev`` 设备 ( `VFIO Mediated devices <https://docs.kernel.org/driver-api/vfio-mediated-device.html>`_ 设备)

回顾 :ref:`install_vgpu_manager` 笔记可以看到，需要首先确保 ``nvidia-vgpu-mgr.service`` 正常运行，也就是说，必须先 :ref:`vgpu_unlock`

- 检查 ``nvidia-vgpu-mgr.service`` 状态:

.. literalinclude:: ../vgpu/install_vgpu_manager/systemctl_staus_nvidia-vgpu-mgr
   :language: bash
   :caption: 检查 ``nvidia-vgpu-mgr`` 服务状态

果然，再次发现这个服务启动失败...回到了老问题: :ref:`vgpu_unlock` 失效了:

查询 ``vgpu`` :

.. literalinclude:: ../vgpu/install_vgpu_manager/nvidia-smi_vgpu_q
   :language: bash
   :caption: ``nvidia-smi vgpu -q`` 查询vGPU

输出显示只激活了 ``0`` 个vGPU:

.. literalinclude:: ../vgpu/install_vgpu_manager/nvidia-smi_vgpu_q_output
   :language: bash
   :caption: ``nvidia-smi vgpu -q`` 查询vGPU显示只有 ``0`` 个vGPU

我想起来了， :ref:`vgpu_unlock` 需要使用 :ref:`dkms` 模块方式安装 :ref:`vgpu` 驱动。最近依次我升级了内核，内核升级时会重新编译安装 :ref:`vgpu` 模块。我重新检查一遍流程，发现原先修订的过程都正确，但是会不会最近升级的内核支持不稳定呢？

我重新编译了一次 :ref:`vgpu_unlock` (似乎不必)，重启服务器
