.. _iommu_grub_config:

=======================
IOMMU内核启动grub配置
=======================

在 :ref:`intel_vt-d_startup` 和 :ref:`ovmf` 介绍了如何配置IOMMU虚拟化，其中有一个重要步骤是启用内核IOMMU。这个步骤需要配置内核参数，也就是通过配置 ``grub`` 实现参数修改。由于Intel和AMD的配置参数略有不同，本文做一个简单梳理。

Intel
==========

Intel处理器使用 ``IOMMU`` 只需要激活:

.. literalinclude:: iommu_grub_config/intel_iommu
   :caption: 内核参数激活Intel处理器 ``IOMMU``

如果要使用 :ref:`sr-iov` ，为了最佳性能，应该再添加一个 ``pass-through`` ( ``pt`` ) 参数:

.. literalinclude:: iommu_grub_config/iommu_pt
   :caption: 激活IOMMU ``pass-through``

当激活了 ``pass-through`` 模式，网卡就不需要使用DMA转换到内存，这就提高了处理性能。所以，对于hypervisor性能，这个 ``iommu=pt`` 参数是非常必要的

综合上面两个参数，在 :ref:`ubuntu_linux` 系统中，配置上述2个参数的方法是修订 ``/etc/default/grub`` :

.. literalinclude:: iommu_grub_config/grub
   :caption: 修订 ``/etc/default/grub`` 添加 IOMMU 配置

然后更新Grub并重启:

.. literalinclude:: iommu_grub_config/update-grub
   :caption: 更新grub

参考
========

- `Understanding the iommu Linux grub File Configuration <https://community.mellanox.com/s/article/understanding-the-iommu-linux-grub-file-configuration>`_
