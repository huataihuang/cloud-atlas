.. _rancher_desktop_vm:

========================
Rancher Desktop虚拟机
========================

``Rancher Desktop`` 实际上是使用 :ref:`lima` 虚拟机来实现 :ref:`macos` 上运行 :ref:`docker` 以及 :ref:`kubernetes` 的。也就是说，一旦使用 ``Rancher Desktop`` 跑起来 Kubernetes ，系统中必然有一个虚拟机:

- 如果是macOS 13 及以后的系统，则可以使用 ``VZ`` 虚拟化(即 :ref:`apple_virtualization` )
- 如果是macOS 13 之前的系统，则必须使用 :ref:`qemu` 虚拟化

那么，如何进入 :ref:`lima` 提供的这个虚拟机呢？

``rdctl``
============

``Rancher Desktop`` 提供了一个官方工具 ``rdctl`` 可以简便地进入虚拟机:

.. literalinclude:: rancher_desktop_vm/rdctl
   :caption: 通过 ``rdctl`` 进入 ``Lima`` 虚拟机

此时会看到shell提示符:

.. literalinclude:: rancher_desktop_vm/rdctl_shell
   :caption: 进入 ``lima-rancher-desktop`` 虚拟机的提示符

- 检查当前用户id可以看到，原来进入 ``Rancher Desktop`` 虚拟机后用户是 ``lima`` :

.. literalinclude:: rancher_desktop_vm/lima_id
   :caption: 用户身份是 ``lima``

- 检查内核以及运行环境( ``uname -a`` ):

.. literalinclude:: rancher_desktop_vm/uname_output
   :caption: ``uname -a`` 显示输出

- 检查虚拟机操作系统版本( ``cat /etc/os-release`` )

.. literalinclude:: rancher_desktop_vm/os-release
   :caption: 可以看到运行的是一个 ``Alpine Linux`` 虚拟机

- 检查磁盘( ``sudo df -h`` )需要使用 ``root`` 身份，因为当前运行的 :ref:`kubernetes` 容器挂载存储都需要root权限:

.. literalinclude:: rancher_desktop_vm/df
   :caption: ``sudo df -h`` 输出

- 检查运行的容器( ``docker ps`` )

.. literalinclude:: rancher_desktop_vm/docker_ps
   :caption: 检查运行容器
