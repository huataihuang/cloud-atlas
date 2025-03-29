.. _lspci:

===========
lspci
===========

- 安装 ``lspci`` 可以识别服务器PCI相关设备:

.. literalinclude:: lspci/install_lspci
   :caption: 安装lspci

.. note::

   更新操作系统的 ``pciids`` 库是  ``lspci`` 能够识别硬件的关键步骤，你可以看到更新前后对硬件设备识别可能完全不同: 更新后的id库使得 ``lspci`` 能够识别出最新的硬件设备(型号)

- 更新 pci 识别库:

.. literalinclude:: lspci/update-pciids
   :language: bash
   :caption: 更新pci识别库

此时会从互联网下载最新的 ``pciids`` 库

- 检查:

.. literalinclude:: lspci/lspci_-v
   :language: bash
   :caption: 执行 ``lspci -v`` 可以看到详细的PCI设备信息

对比 ``update-pciids`` 前后的输出信息差别，就可以看出更新的重要性:

.. literalinclude:: lspci/lspci_before_update-pciids
   :language: bash
   :caption: 更新 ``update-pciids`` 之前 ``lspci -v`` 输出信息
   :emphasize-lines: 3,30

更新以后能够识别出 :ref:`nvidia_a100` :

.. literalinclude:: lspci/lspci_after_update-pciids
   :language: bash
   :caption: 更新 ``update-pciids`` 之后 ``lspci -v`` 输出信息
   :emphasize-lines: 3,30
