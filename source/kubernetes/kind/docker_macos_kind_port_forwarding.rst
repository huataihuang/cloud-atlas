.. _docker_macos_kind_port_forwarding:

==================================================
Docker Desktop for mac 端口转发(port forwarding)
==================================================

在完成 :ref:`metallb_with_kind` 之后，也就已经实现了标准Kubernets集群应用部署的输出了。但是对于 Docker Desktop for mac ，实际上整个Kubernets都是在一个Linux虚拟机中运行，从物理足迹 :ref:`macos` 上不能直接访问这个输出地址，还需要做一个端口转发(port forwarding)来访问。

.. note::

   在 :ref:`mobile_cloud_x86_kind` ，采用直接在Linux物理主机上部署 :ref:`kind` 就没有这个麻烦，外部可以直接访问
