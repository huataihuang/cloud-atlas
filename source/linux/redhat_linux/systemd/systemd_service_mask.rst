.. _systemd_service_mask:

======================
Systemd Service Mask
======================

我在 :ref:`jetson_nano_startup` 构建一个工作环境，采用 :ref:`networkmanager` 来实现无线网络配置。最近，我发现 :ref:`jetson_nano` 升级重启后，无线网络没有激活。

- 检查 :ref:`networkmanager` 服务::

   systemctl status NetworkManager

输出显示服务没有启动::

   ● NetworkManager.service - Network Manager
      Loaded: loaded (/lib/systemd/system/NetworkManager.service; masked; vendor preset: enabled)
      Active: inactive (dead)
        Docs: man:NetworkManager(8) 

- 启动服务::

   systemctl start NetworkManager

可以看到服务能够正常启动，再次检查 ``systemctl status NetworkManager`` 也可以看到服务正常运行::

   ● NetworkManager.service - Network Manager
      Loaded: loaded (/lib/systemd/system/NetworkManager.service; masked; vendor preset: enabled)
      Active: active (running) since Tue 2021-06-01 15:37:26 CST; 7s ago
        Docs: man:NetworkManager(8)
    Main PID: 27815 (NetworkManager)
       Tasks: 5 (limit: 4181)
      CGroup: /system.slice/NetworkManager.service
              ├─27815 /usr/sbin/NetworkManager --no-daemon
              └─28306 /sbin/dhclient -d -q -sf /usr/lib/NetworkManager/nm-dhcp-helper -pf /run/dhclient-wlan0.pid -lf /var/lib/NetworkManager/dhclient-da5a19b4-2088-49ae-990d-6461897ba47
   
   6月 01 15:37:32 jetson NetworkManager[27815]: <info>  [1622533052.2892] dhcp4 (wlan0): state changed unknown -> bound
   6月 01 15:37:32 jetson NetworkManager[27815]: <info>  [1622533052.2964] device (wlan0): state change: ip-config -> ip-check (reason 'none', sys-iface-state: 'managed')
   6月 01 15:37:32 jetson NetworkManager[27815]: <info>  [1622533052.2976] device (wlan0): state change: ip-check -> secondaries (reason 'none', sys-iface-state: 'managed')
   6月 01 15:37:32 jetson NetworkManager[27815]: <info>  [1622533052.2983] device (wlan0): state change: secondaries -> activated (reason 'none', sys-iface-state: 'managed')
   6月 01 15:37:32 jetson dhclient[28306]: bound to 192.168.0.111 -- renewal in 1515 seconds.
   6月 01 15:37:32 jetson NetworkManager[27815]: <info>  [1622533052.3265] device (wlan0): Activation: successful, device activated.
   6月 01 15:37:32 jetson NetworkManager[27815]: <info>  [1622533052.3270] manager: startup complete
   6月 01 15:37:32 jetson NetworkManager[27815]: <warn>  [1622533052.3288] dns-sd-resolved[0x5596424de0]: Failed: GDBus.Error:org.freedesktop.resolve1.LinkBusy: Link eth0 is managed.
   6月 01 15:37:32 jetson NetworkManager[27815]: <warn>  [1622533052.3289] dns-sd-resolved[0x5596424de0]: Failed: GDBus.Error:org.freedesktop.resolve1.LinkBusy: Link eth0 is managed.
   6月 01 15:37:32 jetson NetworkManager[27815]: <warn>  [1622533052.3299] dns-sd-resolved[0x5596424de0]: Failed: GDBus.Error:org.freedesktop.resolve1.LinkBusy: Link eth0 is managed.

- 但是服务无法激活::

   systemctl enable NetworkManager

显示服务已经被屏蔽::

   Failed to enable unit: Unit file /etc/systemd/system/NetworkManager.service is masked.

Systemd Service Mask原因
=========================

systemd服务的所谓 ``mask`` 状态，实际上是 ``disable`` 的强化版本。当设置服务 ``disable`` 时，所有服务单元的软链接都被移除，但是如果配置成 ``mask`` 则单元被链接到 ``/dev/null`` 

- 通过以下命令检查unit文件状态::

   systemctl list-unit-files

可以看到::

   ...
   NetworkManager-dispatcher.service          disabled
   NetworkManager-wait-online.service         disabled
   NetworkManager.service                     masked
   ...

- 检查unit，可以看到被软链接到 ``/dev/null`` ::

   ls -lh /etc/systemd/system/NetworkManager.service

显示::

   lrwxrwxrwx 1 root root 9 6月   1 16:22 /etc/systemd/system/NetworkManager.service -> /dev/null

- 注意到我采用了 :ref:`systemd_networkd` 管理了 ``eth0`` ，这导致两者存在冲突。所以关闭掉 ``systemd-networkd`` 之后再重新激活 ``NetworkManager`` ::

   systemctl stop systemd-networkd
   systemctl disable systemd-networkd

恢复被Mask的服务
==================

- systemdctl提供了一个 ``unmask`` 命令可以去除Mask::

   systemctl unmask NetworkManger

提示信息::

   Removed /etc/systemd/system/NetworkManager.service.

- 然后可以enable该服务::

   systemctl enable NetworkManager

显示::

   Created symlink /etc/systemd/system/multi-user.target.wants/NetworkManager.service → /lib/systemd/system/NetworkManager.service.
   Created symlink /etc/systemd/system/dbus-org.freedesktop.nm-dispatcher.service → /lib/systemd/system/NetworkManager-dispatcher.service.

- 启动了NetworkManager之后，可以看到 ``nmcli conn`` 显示其管理的网络连接::

   nmcli conn

显示管理了无线，也管理了docker0的bridge网络::

   NAME                UUID                                  TYPE      DEVICE
   Wired connection 1  a94fa1de-b290-3b83-9f49-137981396543  ethernet  eth0
   docker0             0bdc7a88-3f72-438e-9674-0af8fc1af7db  bridge    docker0
   office              da5a19b4-2088-49ae-990d-6461897ba471  wifi      wlan0

.. note::

   这里 ``docker0`` 的bridge如果没有启动，会导致docker无法正常工作，影响kubernetes工作。

参考
=========

- `Why are some systemd services in the “masked” state? <https://askubuntu.com/questions/710420/why-are-some-systemd-services-in-the-masked-state>`_
