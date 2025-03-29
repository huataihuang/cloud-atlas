.. _virsh_dompmsuspend:

=====================================
virsh dompmsuspend 挂起运行虚拟机
=====================================

.. note::

   对于采用 :ref:`iommu` 技术pass-through PCIe设备到 :ref:`ovmf` 虚拟机的挂起操作，需要结合虚拟机内部的 :ref:`qemu_guest_agent` 来实现

.. warning::

   本文实践我会在完成 :ref:`ovmf` 直通 :ref:`tesla_p10` GPU运算卡的虚拟机之后再进行，当前仅整理资料，稍后完成实践

参考
=======

- `Saving VM state with GPU passthrough? <https://www.reddit.com/r/VFIO/comments/568mmt/saving_vm_state_with_gpu_passthrough/>`_ 这篇reddit讨论给出了如何处理pass-through设备的虚拟机存储方法，也就是需要结合QEMU guest agent来完成。 ``pipaiyef`` 提供了完整的操作方法可以参考
- `USING THE QEMU GUEST AGENT WITH LIBVIRT <https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/7/html/virtualization_deployment_and_administration_guide/sect-using_the_qemu_guest_virtual_machine_agent_protocol_cli-libvirt_commands>`_
- `SUSPENDING A RUNNING DOMAIN <https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/6/html/virtualization_administration_guide/sub-sect-starting_suspending_resuming_saving_and_restoring_a_guest_virtual_machine-suspending_a_running_domain>`_
