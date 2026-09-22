.. _waypipe:

===============
waypipe
===============

XDG_RUNTIME_DIR
=================

当执行 ``waypipe ssh`` 访问服务器上的应用时，出现报错:

.. literalinclude:: waypipe_freebsd/xdg_runtime_dir_error
   :caption: 缺乏 ``XDG_RUNTIME_DIR`` 环境变量报错

为了能够每次运行 ``waypipe ssh`` 都自动生效环境变量，可以通过 :ref:`ssh` 协议直接把 ``XDG_RUNTIME_DIR`` 透传给服务器:

- 修改FreeBSD服务器 ``/etc/ssh/sshd_config`` 允许接收客户端发出的 ``XDG_*`` 环境变量(如果没有这行配置可以添加到配置文件末尾):

.. literalinclude:: waypipe_freebsd/sshd_config
   :caption: ``/etc/ssh/sshd_config`` 允许接收客户端发出的 ``XDG_*`` 环境变量

- 配置客户端 ``~/.ssh/config`` 设置向服务器发送环境变量:

.. literalinclude:: waypipe_freebsd/config
   :caption: 客户端 ``~/.ssh/config``
   :emphasize-lines: 4

接下来就可以直接执行 ``waypipe ssh`` 命令了

找不到Vulkan驱动报错
=======================

我从 alpine linux 访问 FreeBSD 上的firefox程序，出现报错:

.. literalinclude:: waypipe_freebsd/vulkan_driver_error
   :caption: 找不到Vulkan驱动报错

上述报错是FreeBSD服务器端没有正确安装Vulkan驱动支持导致

- 在服务器上安装vulkan驱动:

.. literalinclude:: waypipe_freebsd/install_vulkan
   :caption: 安装vulkan

按照gemini提示，服务器端安装vulkan驱动之后执行 ``vulkaninfo --summary`` 输出如下:

.. literalinclude:: waypipe_freebsd/vulkaninfo
   :caption: ``vulkaninfo --summary`` 输出
   :emphasize-lines: 18,19

这里输出的显示是 CPU 类型的 ``llvmpipe`` ，理论上已经具备了vulkan支持，只不过是通过

不过报错依旧，原因是我的 :ref:`thinkpad_x220` 是 HD3000 CPU内置显卡，硬件压根没有 Vulkan 驱动，所以只要 ``waypipe`` 一尝试加载Vulkan就会抛出异常。

解决的方法是在 ``waypipe`` 和 ``Firefox`` 两端彻底关掉 ``dmabuf`` 与 Vulkan的硬件分配，强制走传统的 ``shm`` (Shared Memory纯内存共享)方式:

.. literalinclude:: waypipe_freebsd/diable_dmabuf_waypipe
   :caption: 关闭``dmabuf`` 与 Vulkan的硬件分配

但是出现了新的panic现象:

.. literalinclude:: waypipe_freebsd/diable_dmabuf_waypipe_error
   :caption: 关闭``dmabuf`` 与 Vulkan的硬件分配之后出现新的panic报错

这个报错gemini提示是因为 ``waypipe`` 是二进制程序，同时充当客户端和服务端:

- :ref:`alpine_linux` 客户端运行的是 ``waypipe client`` 角色
- :ref:`freebsd` 服务器端被 :ref:`ssh` 调起时，应该自动作为 ``waypipe server`` 角色启动

当命令行参数同时传入某些选项(或者远程SSH环境变量传递混乱)导致FreeBSD侧被调起的 ``waypipe`` 误以为自己也是一个 ``client`` (客户端)，在内部逻辑判断中触发了 ``assertion failed: !client`` (即"断言": 当前进程绝不应该是client")，从而触发Rust panic崩溃。

解决方法是明确指定 ``--mode server`` 与 ``--mode client`` 避免 ``waypipe`` 在自动推断角色时出错。

.. literalinclude:: waypipe_freebsd/waypipe_mode
   :caption: 明确 ``waypipe`` 角色

参数说明:

  - ``waypipe --mode server`` : 强制FreeBSD端 ``waypipe`` 进程扮演 ``server`` 角色
  - ``--`` 双破折号隔离: 这里在FreeBSD侧用 ``--`` 将 ``waypipe`` 本身的参数与后面要启动的 ``firefox`` 命令隔离开，避免参数解析混淆。

上述命令行也可以在 ``~/.profile`` 中设置别名:

.. literalinclude:: waypipe_freebsd/alias_mode
   :caption: 明确设置角色的alias配置

参考
======

- gemini
- `Intel GPU support Matrix <https://forums.freebsd.org/threads/intel-gpu-support-matrix.102846/>`_
