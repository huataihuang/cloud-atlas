.. _priv_dnsmasq:

=========================
私有云DNS服务(dnsmasq)
=========================

在少量部署的虚拟机环境中，通过简单维护各个主机 ``/etc/hosts`` 一致，就能够实现主机解析。但是，一旦开始大规模通过 :ref:`clone_vm_rbd` :ref:`zdata_ceph_rbd_libvirt` ，就很难实时更新每个虚拟机的 ``hosts`` 配置文件。更何况后续还会 :ref:`priv_cloud_infra` 构建 :ref:`kvm_nested_virtual` ，构建数以百计的虚拟机。所以，我们需要构建一个因特网非常基础的 :ref:`dns` ，来提供整个基础架构的域名解析。

当然，大规模基础架构，我们会选择久经考验坚如磐石的 :ref:`bind` (然而非常复杂)，但是为了快速搭建 ``staging`` 环境，我首先选择 :ref:`dnsmasq` 来完成原型，待后续不断优化后再升级到 Bind 构建真正的因特网基础设施。

dnsmasq是小型网络的轻量级DNS/TFTP和DHCP服务器，特别适合小型网络的快速构建，以及宽带共享路由器的局域网基础服务。

安装
========

- ubuntu安装::

   sudo apt install dnsmasq

配置dnsmasq
==============

- ``/etc/dnsmasq.conf`` 配置:

.. literalinclude:: ../../infra_service/dns/dnsmasq/deploy_dnsmasq/dnsmasq.conf
   :language: ini
   :linenos:
   :caption: dnsmasq简易配置

上述配置:

  - 指定默认域名 ``staging.huatai.me`` 并提供DNS解析服务
  - 绑定DNS请求服务网络接口IP ``listen-address``
  - 指定上游域名解析服务器 ``server``

- 执行一个简单的脚本，生成 ``/etc/hosts`` ，这个配置将被 ``dnsmasq`` 加载作为域名解析配置:

.. literalinclude:: ../../infra_service/dns/dnsmasq/deploy_dnsmasq/dnsmasq.conf
   :language: bash
   :linenos:
   :caption: hosts配置提供dnsmasq域名解析配置

执行该脚本，根据 :ref:`priv_cloud_infra` 规划的主机列表生成 ``/etc/hosts`` 文件::

   ./deploy_dnsmasq.sh

- 注意，系统使用了 :ref:`systemd_resolved` 和 :ref:`netplan` ，在系统安装时候通过 ``netplan`` 已经配置了 802.1x 网络动态获取IP地址:

.. literalinclude:: ../../linux/ubuntu_linux/network/netplan/01-eno4-config.yaml
   :language: yaml
   :linenos:
   :caption: netplan 802.1x配置

所以 ``netplan`` 会配置 ``systemd-resolved`` 服务使用DHCP获得的DNS服务器，我们需要覆盖这个配置，采用本地运行的 ``dnsmasq`` 来提供解析: 修订 ``/etc/systemd/resolved.conf`` ::

   [Resolve]
   DNS=127.0.0.1
   Domains=staging.huatai.me

然后重启 ``systemd-resolved`` 服务::

   sudo systemctl daemon-reload
   sudo systemctl restart systemd-networkd
   sudo systemctl restart systemd-resolved

(可选)命令行修订 ``systemd-resolv`` 配置::

   sudo systemd-resolve --interface eno4 --set-dns 127.0.0.1 --set-domain staging.huatai.me

不过，我发现重启 ``systemd-resolved`` 服务后，上述配置是叠加在DHCP配置上的，检查 ``/run/systemd/resolve/resolv.conf`` 可以看到::

   nameserver 127.0.0.1
   nameserver 8.8.8.8
   search staging.huatai.me office.com

但是， ``dig`` 命令查询是正常的， ``resolv.conf`` 配置的 ``nameserver`` 是始终访问第一个 ``nameserver 127.0.0.1`` ，所以没有报错。(这和我很久以前学习 《DNS和Bind》 的记忆有差别，我记得是轮询所有 ``nameserver`` 的)

配置DNS客户端
================

所有VM都需要配置 :ref:`systemd_resolved` 采用 ``zcloud`` 上部署的DNS服务器(dnsmasq)，所以修订VM以及模版VM ``/etc/netplan/01-netcfg.yaml`` ::

   ...
      nameservers:
          search: [ staging.huatai.me ]
          addresses:
              - "192.168.6.200"

然后执行::

   sudo netplan apply

完成DNS解析器配置，采用 ``192.168.6.200`` （zcloud) 的DNS进行域名解析。
