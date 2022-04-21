.. _prepare_k3s_alpine:

=======================
Alpine Linux的K3s准备
=======================

我在ARM环境部署 :ref:`k3s` 采用 :ref:`alpine_linux` 系统。对于Alpine Linux，在部署 :ref:`k3s` 之前，需要和 :ref:`alpine_docker` 一样做内核调整。不过， :ref:`alpine_linux` 可能会使用不同的bootloaer，调整内核方法有所不同，详细可以参考 :ref:`alpine_docker` 。

我所安装的 :ref:`alpine_linux` 没有使用bootloader，所以需要直接修订 ``/media/sda1/cmdline.txt`` 添加:

.. literalinclude:: ../../linux/alpine_linux/alpine_docker/cmdline.txt
   :language: bash
   :caption: /media/sda1/cmdline.txt 添加内核参数

完整配置如下::

   modules=loop,squashfs,sd-mod,usb-storage quiet console=tty1 root=/dev/sda2 cgroup_enable=cpuset cgroup_memory=1 cgroup_enable=memory

重启系统后检查::

   cat /proc/cmdline

参考
======

- `K3s Additional Preparation for Alpine Linux Setup <https://rancher.com/docs/k3s/latest/en/advanced/#additional-preparation-for-alpine-linux-setup>`_
