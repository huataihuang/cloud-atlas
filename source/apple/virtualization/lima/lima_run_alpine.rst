.. _lima_run_alpine:

=============================
Lima运行Alpine Linux虚拟机
=============================

.. warning::

   我暂时没有解决如何在lima中运行 :ref:`alpine_linux` ，也许我的操作系统确实太陈旧了，运行lima存在什么问题

   待后续再排查

   目前暂时改为采用 :ref:`rancher_desktop` (同样基于 Lima 的企业级工具，类似 :ref:`docker_desktop` )

实践是在古老的 :ref:`mbp15_late_2013` 完成，由于是早期的 ``x86_64`` 系统，不支持最新的 :ref:`vz` ，所以需要通过 :ref:`macports` 安装 :ref:`qemu` ( :ref:`macports_old_qemu` )。

.. note::

   虽然 :ref:`apple_virtualization` 的 :ref:`vz` 性能更好，但是需要满足 macOS 13 才能激活，受限于我的笔记本操作系统(macOS Big Sur 11.7.10)，所以只能退而求其次使用 :ref:`qemu`

创建虚拟机
===========

- 创建 :ref:`qemu` 类型虚拟机:

.. note::

   `Lima Templates <https://lima-vm.io/docs/templates/>`_ 是官方提供的安装模版，包含了 :ref:`alpine_linux` 可以直接使用。对于官方没有提供的模版，例如 :ref:`freebsd` 也可以通过修改现有模版来满足要求，例如 :ref:`lima_run_freebsd`

.. literalinclude:: lima_run_alpine/create
   :caption: 创建alpine linux虚拟机

- 启动创建的虚拟机:

.. literalinclude:: lima_run_alpine/start
   :caption: 启动alpine linux虚拟机

这里遇到报错信息:

.. literalinclude:: lima_run_alpine/start_error
   :caption: 启动alpine linux虚拟机
   :emphasize-lines: 14

.. note::

   上述报错看起来是虚拟机内部没有运行ssh服务，导致 ``limactl`` 无法创建ssh连接导致

   怎么改正？

但是，执行 ``ps aux | grep qemu`` 却发现当前实际上是有qemu进程运行的:

.. literalinclude:: lima_run_alpine/qemu_process
   :caption: 当前进程存在qemu

此时执行 ``limactl list`` 检查，也能够看到正在运行的 ``ldev`` :

.. literalinclude:: lima_run_alpine/limactl_list_output
   :caption: 当前有 ``ldev`` 虚拟机运行

- 安装 ``socat`` 来连接 ``~/.lima/ldev/serial.sock`` ，查看控制台输出:

.. literalinclude:: lima_run_alpine/port_install_socat
   :caption: 安装 ``socat``

- 连接控制台:

.. literalinclude:: lima_run_alpine/socat_serial.sock
   :caption: 连接 ``serial.sock``

但是当前没有任何输出信息

使用
=======

待续...
