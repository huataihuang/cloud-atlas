.. _incus_bridge_network:

============================
Incus bridge 网络
============================

Bridge 模式让 VM 直接接入物理网络，获得与 host 同网段的 IP，外部机器可以直接 SSH，无需任何转发。

环境
======

- :ref:`incus_debian_vm` 虚拟机IP地址 ``10.0.55.83``

桥接到 ``enp4s0`` ( ``192.168.6.0/24`` 有线网)
==================================================

:ref:`networkmanager` 底座
---------------------------

.. literalinclude:: incus_bridge_network/bridge_enp4s0
   :caption: 有线网络bridge

.. literalinclude:: incus_bridge_network/bridge_wlan
   :caption: 无线网络bridge

.. note::

   很多 WiFi 驱动（尤其是 Intel/Realtek）不支持 bridge 透传，VM 可能无法通信。如果不行，优先用有线 enp4s0。

注意，上述配置使用了 :ref:`networkmanager` 工具 ``nmcli`` ，适合默认安装了 NetworkManager的 :ref:`debian` 或者 :ref:`ubuntu_linux` 工作站版本。但是，在Ubuntu Server版本，使用 :ref:`netplan` 调用 :ref:`systemd_networkd` ，则需要采用下文配置方法

:ref:`netplan` + :ref:`systemd_networkd` 底座
-----------------------------------------------

在 :ref:`ubuntu_linux` 26.04 Server上，默认使用的是 :ref:`netplan` 调用 :ref:`systemd_networkd` ，所以需要修改  ``/etc/netplan/*.yaml`` ，默认配置是 ``/etc/netplan/00-install-config.yaml`` ，当前默认配置如下:

.. literalinclude:: incus_bridge_network/00-installer-config.yaml
   :language: yaml
   :caption: Ubuntu系统安装完成后系统自动创建的 ``/etc/netplan/00-install-config.yaml``

现在我们的目标就是将物理网卡上的配置摘除，迁移到bridge上，然后把物理网卡绑定到bridge上:

.. literalinclude:: incus_bridge_network/00-installer-config-br.yaml
   :caption: 创建bridge，并将原先物理网卡配置迁移到bridge上再做绑定

这里遇到一个问题，检查bridge状态，显示绑定无线网卡的bridge始终是DOWN状态:

.. literalinclude:: incus_bridge_network/ip_link
   :caption: 检查bridge

输出显示 ``br1`` 始终是 ``DOWN`` 状态

.. literalinclude:: incus_bridge_network/ip_link_output
   :caption: 检查bridge显示 ``br1`` 状态DOWN
   :emphasize-lines: 2

当然，查看IP也是显示br1是DOWN

.. literalinclude:: incus_bridge_network/ip_addr
   :caption: 检查IP状态
   :emphasize-lines: 2,4

这块无线网卡是 ``mt76/mt7921u`` USB驱动存在限制: USB WiFi 适配器在 mac80211 栈中以 station 模式运行时，帧处理逻辑和 bridge 的 L2 透传模式冲突，carrier 状态无法正确传递。

由于无法在无线网卡上启动bridge，所以在无线网络上，修改为 :ref:`incus_nat_network` 模式。所以首先修订 ``/etc/netplan/00-installer-config.yaml`` 将无线网路部分恢复到最初的直接使用:

.. literalinclude:: incus_bridge_network/00-installer-config-br0.yaml
   :caption: 只创建bridge br0



参考
======

- :ref:`podman_compose_ollama_nvidia_a2` 运行 ``qwen3.8:27b-q8_0`` 模型
