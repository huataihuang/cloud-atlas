.. _nvidia-smi_nvlink:

===========================================
使用 ``nvidia-smi`` 工具检查NVIDIA NVLink
===========================================

:ref:`nvidia_nvlink` 是NVIDIA公司开发的GPU卡通讯互联接口(协议)，在高端数据中心GPU卡中使用。

- 查看 ``nvidia-smi nvlink -h`` 帮助:

.. literalinclude:: nvidia-smi_nvlink/nvidia-smi_nvlink_help
   :language: bash
   :caption: ``nvidia-smi nvlink -h`` 提供基本帮助信息，可以快速了解功能

- 查看 ``GPU 0`` (通常服务器会安装多块GPU卡) NVIDIA计算卡的 NVLink 状态:

.. literalinclude:: nvidia-smi_nvlink/nvidia-smi_nvlink_status
   :language: bash
   :caption: 检查GPU 0的NVLink状态

.. literalinclude:: nvidia-smi_nvlink/nvidia-smi_nvlink_status_output
   :language: bash
   :caption: 检查GPU 0的NVLink状态输出案例

- 查看 ``GPU 0`` 卡的NVLink功能:

.. literalinclude:: nvidia-smi_nvlink/nvidia-smi_nvlink_capabilities
   :language: bash
   :caption: 检查GPU 0的NVLink功能

.. literalinclude:: nvidia-smi_nvlink/nvidia-smi_nvlink_capabilities_output
   :language: bash
   :caption: 检查GPU 0的NVLink功能输出案例

- 关键命令: 检查 ``GPU 0`` 卡的NVLink链路数据传输计数(可用于 :ref:`prometheus_nvlink` )

.. literalinclude:: nvidia-smi_nvlink/nvidia-smi_nvlink_getthroughput
   :language: bash
   :caption: 检查GPU 0的NVLink数据传输

.. note::

   ``nvlink --getthroughput`` 有2个子参数:

   - ``d`` 实际传输的数据负载(KiB)，也就是剥离了传输协议部分的真实数据量
   - ``r`` 包括协议负载和数据负载的传输总数据量(KiB)

.. literalinclude:: nvidia-smi_nvlink/nvidia-smi_nvlink_getthroughput_output
   :language: bash
   :caption: 检查GPU 0的NVLink数据传输输出案例




参考
========

- `Exploring NVIDIA NVLink "nvidia-smi" Commands <https://www.exxactcorp.com/blog/HPC/exploring-nvidia-nvlink-nvidia-smi-commands>`_
