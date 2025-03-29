.. _debug_k8s_notready_node_kubelet:

===================================
Kubernetes节点NotReady排查(kubelet)
===================================

在Kubernetes集群运维时，工作节点 ``NotReady`` 状态是非常常见的故障。通常我们有一些排查思路需要依次执行以获取必要信息。这里我做一些案例分析，提供一些建议。

节点容器没有启动
================

在 :ref:`arm_k8s_deploy` 后，我对其中 :ref:`kali_linux` 节点做了操作系统升级，然后重启。发现 ``kubectl get nodes`` 显示该节点 ``NotReady`` ::

   NAME         STATUS     ROLES                  AGE     VERSION   INTERNAL-IP     EXTERNAL-IP   OS-IMAGE                 KERNEL-VERSION       CONTAINER-RUNTIME
   kali         NotReady   <none>                 6d20h   v1.22.0   192.168.1.10    <none>        Kali GNU/Linux Rolling   5.4.83-Re4son-v8l+   docker://20.10.5+dfsg1

- 我通常检查服务器采用三板斧

  - ``dmesg -T`` 看系统报错
  - ``df -h`` 和 ``df -i`` 检查磁盘空间
  - ``top`` 观察系统负载
  
- 由于节点 ``NotReady`` ，所以和 ``kubelet`` 相关，检查该服务日志::

   ● kubelet.service - kubelet: The Kubernetes Node Agent
   Loaded: loaded (/lib/systemd/system/kubelet.service; disabled; vendor preset: disabled)
   Drop-In: /etc/systemd/system/kubelet.service.d
           └─10-kubeadm.conf
   Active: inactive (dead)
     Docs: https://kubernetes.io/docs/home/

- 果然 ``kubelet`` 服务没有正常启动 ``inactive (dead)`` ，所以我们需要通过 :ref:`journalctl` 工具来检查::

   journalctl -u kubelet.service

看到如下信息::

   Aug 18 11:41:46 kali kubelet[3636559]: E0818 11:41:46.325093 3636559 cadvisor_stats_provider.go:415] "Partial failure issuing cadvisor.   ContainerInfoV2" err="partial failures: [\"/kubepods.slice/kubepods-burstable.slice/kubepods-burstable-pod6737c726_b5f3_4acd_83ca_3b41c2017137.slice/   docker-1a4da17d59f0c177f78fb518759c8175b9fabb4083acb1e6616db95f7c38c61a.scope\": RecentStats: unable to find data in memory cache], [\"/kubepods.   slice\": RecentStats: unable to find data in memory cache], [\"/system.slice/docker.service\": RecentStats: unable to find data in memory cache], [\"/   kubepods.slice/kubepods-burstable.slice/kubepods-burstable-pod6737c726_b5f3_4acd_83ca_3b41c2017137.slice/   docker-d71bdcee8277ff03ce0eac24072bc320cc4b63243d5d44f0c73a99b6d691b1b9.scope\": RecentStats: unable to find data in memory cache], [\"/kubepods.slice/   kubepods-besteffort.slice\": RecentStats: unable to find data in memory cache], [\"/kubepods.slice/kubepods-burstable.slice\": RecentStats: unable to    find data in memory cache], [\"/kubepods.slice/kubepods-besteffort.slice/kubepods-besteffort-pod9ea69a17_879c_4376_b434_d385900b8913.slice\":    RecentStats: unable to find data in memory cache], [\"/kubepods.slice/kubepods-besteffort.slice/   kubepods-besteffort-pod9ea69a17_879c_4376_b434_d385900b8913.slice/docker-04e72e5a46936cdecca0e15be104c0dc42e8d37832a1edfecb55470a4cde15ea.scope\":    RecentStats: unable to find data in memory cache], [\"/kubepods.slice/kubepods-besteffort.slice/   kubepods-besteffort-pod9ea69a17_879c_4376_b434_d385900b8913.slice/docker-dc34d19bcab3d9c9f830aec7e51164963d5ddf63cc5bd60dc9d0e84cd37babfe.scope\":    RecentStats: unable to find data in memory cache], [\"/system.slice/kubelet.service\": RecentStats: unable to find data in memory cache], [\"/kubepods.   slice/kubepods-burstable.slice/kubepods-burstable-pod6737c726_b5f3_4acd_83ca_3b41c2017137.slice\": RecentStats: unable to find data in memory cache]"
   Aug 18 11:41:46 kali kubelet[3636559]: E0818 11:41:46.335263 3636559 summary_sys_containers.go:47] "Failed to get system container stats" err="failed    to get cgroup stats for \"/kubepods.slice\": failed to get container info for \"/kubepods.slice\": partial failures: [\"/kubepods.slice\":    RecentStats: unable to find data in memory cache]" containerName="/kubepods.slice"
   Aug 18 11:41:46 kali kubelet[3636559]: E0818 11:41:46.335451 3636559 summary_sys_containers.go:47] "Failed to get system container stats" err="failed    to get cgroup stats for \"/system.slice/kubelet.service\": failed to get container info for \"/system.slice/kubelet.service\": partial failures: [\"/   system.slice/kubelet.service\": RecentStats: unable to find data in memory cache]" containerName="/system.slice/kubelet.service"
   Aug 18 11:41:46 kali kubelet[3636559]: E0818 11:41:46.335548 3636559 summary_sys_containers.go:47] "Failed to get system container stats" err="failed    to get cgroup stats for \"/system.slice/docker.service\": failed to get container info for \"/system.slice/docker.service\": partial failures: [\"/   system.slice/docker.service\": RecentStats: unable to find data in memory cache]" containerName="/system.slice/docker.service"
   Aug 18 11:41:46 kali kubelet[3636559]: E0818 11:41:46.335631 3636559 helpers.go:673] "Eviction manager: failed to construct signal" err="system    container \"pods\" not found in metrics" signal=allocatableMemory.available
   Aug 18 11:41:46 kali kubelet[3636559]: I0818 11:41:46.335696 3636559 helpers.go:746] "Eviction manager: no observation found for eviction signal"    signal=allocatableMemory.available
   Aug 18 11:41:49 kali systemd[1]: Stopping kubelet: The Kubernetes Node Agent...
   Aug 18 11:41:50 kali systemd[1]: kubelet.service: Succeeded.

看起来容器没有启动

- 检查发现，确实没有任何容器::

   # docker ps
   CONTAINER ID   IMAGE     COMMAND   CREATED   STATUS    PORTS     NAMES

- 检查网络接口::

   ip addr

发现docker和kvm虚拟化相关网络接口都没有启动::

   ...
   4: virbr0: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 qdisc noqueue state DOWN group default qlen 1000
   link/ether 52:54:00:c1:b8:94 brd ff:ff:ff:ff:ff:ff
   inet 192.168.122.1/24 brd 192.168.122.255 scope global virbr0
      valid_lft forever preferred_lft forever
   5: docker0: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 qdisc noqueue state DOWN group default
   link/ether 02:42:67:d2:8a:52 brd ff:ff:ff:ff:ff:ff
   inet 172.17.0.1/16 brd 172.17.255.255 scope global docker0
      valid_lft forever preferred_lft forever

为什么网桥没有启动? 这个现象正常，参见 :ref:`docker0_bridge_down_in_k8s_flannel`

- 检查网络相关服务::

   systemctl list-units | grep -i network

发现 ``networking.service`` 有失败::

   ● networking.service     loaded failed failed    Raise network interfaces
     NetworkManager-wait-online.service     loaded active exited    Network Manager Wait Online

- 采用 :ref:`systemctl` 和 :ref:`journalctl` 检查服务状态和对应日志::

   systemctl status networking.service

显示异常如下::

   ● networking.service - Raise network interfaces
        Loaded: loaded (/lib/systemd/system/networking.service; enabled; vendor preset: enabled)
        Active: failed (Result: exit-code) since Wed 2021-08-18 11:41:57 CST; 11h ago
          Docs: man:interfaces(5)
       Process: 330 ExecStart=/sbin/ifup -a --read-environment (code=exited, status=1/FAILURE)
      Main PID: 330 (code=exited, status=1/FAILURE)
           CPU: 278ms
   
   Jul 14 01:29:27 kali systemd[1]: Starting Raise network interfaces...
   Jul 14 01:29:27 kali ifup[330]: ifup: unknown interface eth0
   Aug 18 11:41:57 kali systemd[1]: networking.service: Main process exited, code=exited, status=1/FAILURE
   Aug 18 11:41:57 kali systemd[1]: networking.service: Failed with result 'exit-code'.
   Aug 18 11:41:57 kali systemd[1]: Failed to start Raise network interfaces.

这个好像无关，因为 ``/etc/network/interfaces`` 中残留有::

   auto eth0
   allow-hotplug eth0

而实际网卡管理由 :ref:`networkmanager` 完成配置 ( ``/etc/NetworkManager/system-connections`` 目录下有对应配置

kubelet未启动导致NotReady
============================

上述检查可以看到 ``docker ps`` 显示所有容器都没有启动，但是我也注意到 ``kubelet`` 没有运行，这是导致后续无法启动pod的原因

- 所以先尝试重启 ``kubelet`` ::

   systemctl restart kubelet

- 然后检查状态::

   systemctl status kubelet

可以看到服务启动正常了::

- 再检查pod启动::

   docker ps

可以观察到关键pod ``flannel`` 和 ``kube-proxy`` 都已经启动::

   CONTAINER ID   IMAGE                  COMMAND                  CREATED          STATUS          PORTS     NAMES
   87a2c206e7db   85fc911ceba5           "/opt/bin/flanneld -…"   10 seconds ago   Up 9 seconds              k8s_kube-flannel_kube-flannel-ds-pkhch_kube-system_6737c726-b5f3-4acd-83ca-3b41c2017137_2
   433e52729018   fef37187b238           "/usr/local/bin/kube…"   12 seconds ago   Up 11 seconds             k8s_kube-proxy_kube-proxy-bn9q8_kube-system_9ea69a17-879c-4376-b434-d385900b8913_1
   6fbb3c96fb6b   k8s.gcr.io/pause:3.5   "/pause"                 13 seconds ago   Up 11 seconds             k8s_POD_kube-flannel-ds-pkhch_kube-system_6737c726-b5f3-4acd-83ca-3b41c2017137_1
   a84723506dac   k8s.gcr.io/pause:3.5   "/pause"                 13 seconds ago   Up 11 seconds             k8s_POD_kube-proxy-bn9q8_kube-system_9ea69a17-879c-4376-b434-d385900b8913_1

- 最后检查node已经Ready::

   kubectl get nodes -o wide

显示输出::

   NAME         STATUS   ROLES                  AGE     VERSION   INTERNAL-IP     EXTERNAL-IP   OS-IMAGE                 KERNEL-VERSION       CONTAINER-RUNTIME
   kali         Ready    <none>                 6d23h   v1.22.0   192.168.1.10    <none>        Kali GNU/Linux Rolling   5.4.83-Re4son-v8l+   docker://20.10.5+dfsg1

.. note::

   我注意到 ``kali`` 节点使用的 ``INTERNAL-IP`` 是绑定在无线网卡上，这个无线网卡启动需要复杂认证，启动缓慢。我推测是这个导致kubelet无法正常启动，因为kueblet启动时无线网卡可能尚未就绪。具体原因后续再排查。
