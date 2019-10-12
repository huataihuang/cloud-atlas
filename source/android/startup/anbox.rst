.. _anbox:

==========================
Anbox运行Andorid程序
==========================

Anbox部署要点
===============

- 需要使用snap安装
  
虽然 `Arch Linux社区文档 - Anbox <https://wiki.archlinux.org/index.php/Anbox>`_ 的方法能够脱离snap直接在操作系统中安装Anbox，但是由于Anbox对系统库文件有版本要求，例如mesa库需要特定版本，这种方法会导致Android应用图形刷新存在问题，并且无法响应鼠标键盘。

.. note::

   本文只提炼总结实践的最终正确方法，即采用snap安装anbox。有关Linux直接安装anbox的折腾和排查经历，请参考 :ref:`anbox_scratch`

- snap安装使用edge通道

目前(2019年10月)，使用snap的beta通道安装anbox能够正常运行Google自家的软件，但是，钉钉和微信启动后始终停留在启动画面或退出。使用edge通道的anbox，至少能够运行钉钉。

- anbox的网络和域名解析

当前anbox发布包已经结合了网上很多修复网络联通的工具和方法，例如 `anbox-bridge.sh <https://github.com/anbox/anbox/blob/master/scripts/anbox-bridge.sh>`_ 脚本，实际上已經不再需要第三方脚本或命令来设置路由和DNS解析。Anbox官方文档其实已经给出了配制方法，只是在README文档中没有引用，所以导致我折腾了很久。

`anbox Networker Configuration <https://docs.anbox.io/userguide/advanced/network_configuration.html>`_ 通过snap设置anbox网络可以完成默认路由和DNS解析的配制。

- Host主机firewalld配制

host主机的firewalld配制会影响Anbox访问外网的连接，默认没有将anbox0网络设备加入到zone，并且没有启用public zone上的ip masquerade，所以会导致anbox网络配制好以后依然无法访问外网(然而可以ping)。如果Linux主机使用了firewalld，需要对应配制。

snap
=======

安装snapd::

   yay -S snapd

.. note::

   ``snapd`` 安装了一个 ``/etc/profile.d/snapd.sh`` 来输出snapd包和桌面的安装路径。需要重启一次系统来使之生效。

.. note::

   从2.36开始， ``snapd`` 需要激活激活 AppArmr 来支持Arch Linux。如果没有激活AppArmor，则所有snaps都运行在 ``devel`` 模式，意味着它们运行在相同的不受限制访问系统，类似Arch Linux仓库安装的应用。

   要使用AppArmor::

      systemctl enable --now apparmor.service
      systemctl enable --now snapd.apparmor.service

- 激活snapd::

   sudo systemctl enable --now snapd.socket  

为了激活经典snap，执行以下命令创建链接::

   sudo ln -s /var/lib/snapd/snap /snap

- 测试

先安装一个简单的 hello-world snap::

   sudo snap install hello-world

这里报错::

   error: too early for operation, device not yet seeded or device model not acknowledged

需要等一会等环境就绪再重新执行

需要将 ``/var/lib/snapd/snap/bin`` 添加到PATH环境(或者如前所述，先重启一次系统)

然后测试::

    hello-world

- (可选)成功以后，通过snap安装snap-store应用商店::

    sudo snap install snap-store

.. note::

   通过snap-store可以安装很多重量级软件，具有独立的容器运行环境，不影响系统。

使用snap案例
---------------

- 查询Ubuntu Store::

   snap find <searchterm>

- 安装snap::

   sudo snap install <snapname>

安装将下载snap到 ``/var/lib/snapd/snaps`` 并挂载成 ``/var/lib/snapd/snap/snapname`` 来使之对系统可用。并且将创建每个snap的挂载点，并将它们加入到 ``/etc/systemd/system/multi-user.target.wants/`` 软链接，以便系统嗯启动时素有snap可用。

- 检查已经安装的snap::

   snap list

可以看到::

   Name         Version    Rev   Tracking  Publisher   Notes
   anbox        4-e1ecd04  158   beta      morphis     devmode
   core         16-2.41    7713  stable    canonical✓  core
   hello-world  6.4        29    stable    canonical✓  -

- 更新snap::

   snap refresh

- 检查最新的刷新时间::

   snap refresh --time

- 设置刷新时间，例如每天2次::

   snap set core refresh.timer=0:00-24:00/2

- 删除snap::

   snap remove snapname

通过snap安装anbox
==================

.. note::

   非正式版本的snap程序采用 ``--devmode`` 安装，但是不会自动更新，需要手工更新。

- 安装anbox::

   sudo snap install --devmode --edge anbox

.. note::

   需要安装edge通道的anbox版本，beta通道版本不能运行钉钉。

- 卸载::

   sudo snap remove anbox

snap配制anbox
==============

通过snap安装了anbox之后，直接运行anbox的话，App应用的网络是不通的。这是因为Anbox不知道你所在的网络的DNS配制，也没有默认配制andriod的默认网关(虽然我觉得很不友好)。

- 设置anbox容器的默认网关::

   sudo snap set anbox container.network.gateway=192.168.250.1

由于anbox不知道host所在网络的DNS，所以默认也没有配制容器的resolver。比较简单的方法是查看host主机使用的DNS配制，然后通过 ``snap set`` 指令设置dns。

- 获取当前host主机的DNS配制::

   nmcli dev show | grep DNS

- 根据上述输出DNS记录，设置anbox的DNS(这里假设局域网使用的DNS是192.168.1.1)::

   sudo snap set anbox container.network.dns=192.168.1.1

- 重启anbox container-manager::

   sudo systemctl restart snap.anbox.container-manager.service

重启以后观察 ``anbox container-manager`` 进程，可以看到运行参数中多了2个配制项: ``--container-network-gateway=192.168.250.1 --container-network-dns-servers=10.15.48.1`` 

- 启动虚拟机::

   snap run anbox.appmgr

firewalld
-----------

anbox使用了类似 :ref:`libvirt_nat_network` 的 ``anbox0`` 网桥，使用 ``brctl show`` 可以看到::

   bridge name  bridge id               STP enabled     interfaces
   anbox0               8000.1edb3f6031c8       no              vethQ6F8VV

对于系统已经启用了firewalld防火墙，需要将 ``anbox0`` 加入到 ``internal`` zone，并配制 ``public`` zone的IP masquerade，这样才能和外网进行通讯。

- 检查zone::

   firewall-cmd --get-active-zones

此时还看不到 anbox0 接口。

- 将接口 ``anbox0`` 加入到内部zone::

   firewall-cmd --zone=internal --change-interface=anbox0

然后检查::

   firewall-cmd --get-active-zones

输出显示::

   internal
     interfaces: anbox0
   ...

- 检查public接口，就会发现没有启用masquerade - ``masquerade: no`` ::

   firewall-cmd --zone=public --list-all

- 在public区域添加masquerade::

   firewall-cmd --zone=public --add-masquerade

现在在Anbox的app就可以访问外部网络。

DNSmasq
--------

每次切换不同的网络，手工修订 ``snap set anbox container.network.dns=`` 非常麻烦。 所以建议在host主机上运行一个DNSmasq服务，为anbox提供DNS解析，这样就不需要每次修订DNS配制。

masq::

   sudo pacman -S dnsmasq

- 修改 ``/etc/dnsmasq.conf`` 仅对anbox0接口提供DNS服务::

   interface=anbox0
   bind-interfaces

- 启动DNS::

   sudo systemctl start dnsmasq
   sudo systemctl enable dnsmasq

- 修改anbox的DNS配制，改为采用Host主机的DNSmasq::

   sudo snap set anbox container.network.dns=192.168.250.1

- 重启anbox container-manager::

   sudo systemctl restart snap.anbox.container-manager.service

安装Google Play
=================

- 安装Google Play::

   wget https://raw.githubusercontent.com/geeks-r-us/anbox-playstore-installer/master/install-playstore.sh
   chmod +x install-playstore.sh
   sudo ./install-playstore.sh

这样就可以直接访问Google Play安装应用程序，就和Android手机没有什么差异了。

安装本地应用
=============

除了从Google Play可以安装应用程序，还可以安装本地 apk 包::

   adb install app.apk

参考
======

- `Arch Linux社区文档 - Anbox <https://wiki.archlinux.org/index.php/Anbox>`_
- `Running Android applications on Arch using anbox <https://forum.manjaro.org/t/running-android-applications-on-arch-using-anbox/53332>`_
- `Bliss ROMs <https://blissroms.com/>`_ 是一个将Android改造成原生运行的操作系统，可以在PC或者KVM虚拟机中运行，或许有些类似ChromeBook，但是可以运行丰富的Android程序，可以在以后尝试一下。此外，类似还有 Phoenix OS 。
