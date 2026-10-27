.. _incus_container_systemd_debug:

===========================
Incus容器内systemd异常排查
===========================

我在Incus中实践 :ref:`incus_startup` 和 :ref:`incus_freebsd` 都非常顺利，但是，我发现一个奇怪的问题，在我的服务器上，使用 ``debian/12`` 镜像是正常启动的，但是 ``debian/13`` , ``debian/14`` 以及 ``ubuntu/26.04`` 容器都出现了相同的异常，容器内部有4个 :ref:`systemd` 服务无法启动，从 ``incus console`` 可以看到循环的报错:

.. literalinclude:: incus_container_systemd_debug/systemd_error
   :caption: 容器内systemd服务无法启动
   :emphasize-lines: 4,5,8,11

也就是可以看到有4个服务无法启动:

- :ref:`systemd_networkd`
- ``systemd-udev-trigger``
- ``systemd-journald``
- ``systemd-resolved``

这一点让我非常困扰，在 ``debian/12`` 的容器中是完全正常的，但是到了更高版本系统就出现了上述问题。

gemini提示:

- Systemd 版本的跨越式迭代

  - Debian 12 使用的是较旧的 systemd v252，对容器环境的硬件限制包容度较高
  - Debian 13/14 及 Ubuntu 26.04 搭载了更新的 systemd v255 / v256 / v257+。新版 systemd 引入了极其严格的内部沙箱和硬件检查机制

- systemd-udev-trigger 的权限硬编码

  - 在非特权容器中，由于没有真实的物理硬件和 /sys 写的权限，新版 systemd-udev-trigger 会强制尝试向 /sys/devices/.../uevent 写入重置或触发事件
  - 在旧版本中，这类错误会被忽略；但在新版本 systemd 中，它会抛出 Permission denied 并触发死锁或无限重试

- 网络与日志服务的链式阻塞

  - 因为 udev 初始化失败或无限挂起，依赖它的 systemd-networkd、systemd-resolved 以及 systemd-networkd-wait-online 会陷入长达 1分30秒（1min 30s） 的超时等待循环，导致容器迟迟无法完成引导，自然也无法通过 DHCP 成功拿到 IP 地址

临时的解决
============

目前看来没有什么好的解决方法，我也不想再折腾和最终目标无关的技术，所以我改用 :ref:`debian` 12 **bookworm** 版本来作为容器，后续部署 :ref:`kubernetes`


