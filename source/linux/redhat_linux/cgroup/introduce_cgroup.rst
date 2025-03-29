.. _introduce_cgroup:

=============================
控制群组(congrol group)简介
=============================

控制群组（control group）也称为 ``cgroup`` ，是Linux内核的功能：在系统中运行的层级制进程组，可以对其进行资源分配(如 CPU 时间、系统内存、网络带宽或者这些资源的组合)。通过cgroup可以在分配、排序、拒绝、管理和监控系统资源等方面，可以进行精细化控制。硬件资源可以在应用程序和用户间智能分配，从而增加整体效率。

控制群组可对进程进行层级式分组并标记，并对其可用资源进行限制。通过将 cgroup 层级系统(cgroup hierarchies)与 systemd 单位树(systemd unit tree)捆绑，可以把资源管理设置从进程级别移至应用程序级别。这样就能够通过 ``systemctl`` 命令或者修改 systemd 单元文件来管理系统资源。

.. note::

   传统对 ``libcgroup`` 软件包中的 ``cgconfig`` 指令已不建议使用，容易和默认的cgroup层级产生冲突。

通过 systemctl 或者 cgconfig 可以管理内核 cgroup 管控组(也称为子系统)，主要的cgroup管控组是 cpu, memory 和 blkio。

cgroup默认层级
================

默认情况下， ``systemd`` 会自动创建 ``slice`` ， ``scope`` 和 ``service`` 单位的层级，为cgroup树提供统一结构。使用 ``systemctl`` 指令，可以创建自定义 ``slice`` 进一步修改结构。 ``systemd`` 也自动为 ``/sys/fs/cgroup/`` 目录中重要的内核资源管控器挂载层级。

.. warning::

   虽然不推荐使用 libcgroup 软件包中的 cgconfig 工具，但它可以为 systemd （尤其是 net-prio 管控器）暂不支持的管控器挂载、处理层级。永远不要使用 libcgropup 工具去修改 systemd 默认挂载的层级，否则可能会导致异常情况。

systemd的unit type(单位类型)
==============================

系统中运行的所有进程，都是 systemd init 进程的子进程。

在资源管控方面，systemd 提供了三种单位类型:

- ``service`` : 一个或一组进程，由 ``systemd`` 根据单元配置文件启动。

参考
=======

- `Red Hat Enterprise Linux 7 资源管理指南 <https://access.redhat.com/documentation/zh-cn/red_hat_enterprise_linux/7/html/resource_management_guide/>`_
