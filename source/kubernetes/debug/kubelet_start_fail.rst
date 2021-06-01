.. _kubelet_start_fail:

======================
Kubelet启动异常排查
======================

我在 :ref:`arm_k8s_deploy` 的一个 :ref:`jetson_nano` 工作节点，升级重启以后遇到 :ref:`systemd_service_mask` 导致 :ref:`networkmanager` 无法管理网络接口。虽然 ``unmask`` 之后并且恢复了NetworkManager管理网络接口。但是系统重启后， ``kubelet`` 服务没有正常启动。

- 检查 ``kubelet`` 服务状态::

   systemctl status kubelet

显示输出::

   ● kubelet.service - kubelet: The Kubernetes Node Agent
      Loaded: loaded (/lib/systemd/system/kubelet.service; enabled; vendor preset: enabled)
     Drop-In: /etc/systemd/system/kubelet.service.d
              └─10-kubeadm.conf
      Active: activating (auto-restart) (Result: exit-code) since Tue 2021-06-01 23:05:15 CST; 2s ago
        Docs: https://kubernetes.io/docs/home/
     Process: 15941 ExecStart=/usr/bin/kubelet $KUBELET_KUBECONFIG_ARGS $KUBELET_CONFIG_ARGS $KUBELET_KUBEADM_ARGS $KUBELET_EXTRA_ARGS (code=exited, status=1/FAILURE)
    Main PID: 15941 (code=exited, status=1/FAILURE)
   
   6月 01 23:05:15 jetson systemd[1]: kubelet.service: Main process exited, code=exited, status=1/FAILURE
   6月 01 23:05:15 jetson systemd[1]: kubelet.service: Failed with result 'exit-code'.

- 检查journal日志::

   journalctl -u kubelet --no-pager

显示::

   6月 01 23:15:22 jetson systemd[1]: Started kubelet: The Kubernetes Node Agent.
   6月 01 23:15:22 jetson kubelet[24037]: Flag --network-plugin has been deprecated, will be removed along with dockershim.
   6月 01 23:15:22 jetson kubelet[24037]: Flag --network-plugin has been deprecated, will be removed along with dockershim.
   6月 01 23:15:22 jetson kubelet[24037]: I0601 23:15:22.825636   24037 server.go:440] "Kubelet version" kubeletVersion="v1.21.1"
   6月 01 23:15:22 jetson kubelet[24037]: I0601 23:15:22.826407   24037 server.go:851] "Client rotation is on, will bootstrap in background"
   6月 01 23:15:22 jetson kubelet[24037]: I0601 23:15:22.867597   24037 certificate_store.go:130] Loading cert/key pair from "/var/lib/kubelet/pki/kubelet-client-current.pem".
   6月 01 23:15:22 jetson kubelet[24037]: I0601 23:15:22.870159   24037 dynamic_cafile_content.go:167] Starting client-ca-bundle::/etc/kubernetes/pki/ca.crt
   6月 01 23:15:23 jetson kubelet[24037]: W0601 23:15:23.037531   24037 sysinfo.go:203] Nodes topology is not available, providing CPU topology
   6月 01 23:15:23 jetson kubelet[24037]: I0601 23:15:23.090497   24037 server.go:660] "--cgroups-per-qos enabled, but --cgroup-root was not specified.  defaulting to /"
   6月 01 23:15:23 jetson kubelet[24037]: E0601 23:15:23.090909   24037 server.go:292] "Failed to run kubelet" err="failed to run Kubelet: running with swap on is not supported, please disable swap! or set --fail-swap-on flag to false. /proc/swaps contained: [Filename\t\t\t\tType\t\tSize\tUsed\tPriority /dev/zram0                              partition\t507408\t0\t5 /dev/zram1                              partition\t507408\t0\t5 /dev/zram2                              partition\t507408\t0\t5 /dev/zram3                              partition\t507408\t0\t5]"
   6月 01 23:15:23 jetson systemd[1]: kubelet.service: Main process exited, code=exited, status=1/FAILURE
   6月 01 23:15:23 jetson systemd[1]: kubelet.service: Failed with result 'exit-code'.
   6月 01 23:15:33 jetson systemd[1]: kubelet.service: Service hold-off time over, scheduling restart.
   6月 01 23:15:33 jetson systemd[1]: kubelet.service: Scheduled restart job, restart counter is at 2191.
   6月 01 23:15:33 jetson systemd[1]: Stopped kubelet: The Kubernetes Node Agent.
   6月 01 23:15:33 jetson systemd[1]: Started kubelet: The Kubernetes Node Agent.
   6月 01 23:15:33 jetson kubelet[24176]: Flag --network-plugin has been deprecated, will be removed along with dockershim.
   6月 01 23:15:33 jetson kubelet[24176]: Flag --network-plugin has been deprecated, will be removed along with dockershim.
   6月 01 23:15:33 jetson kubelet[24176]: I0601 23:15:33.595247   24176 server.go:440] "Kubelet version" kubeletVersion="v1.21.1"
   6月 01 23:15:33 jetson kubelet[24176]: I0601 23:15:33.596482   24176 server.go:851] "Client rotation is on, will bootstrap in background"

原因是 ``kubelet`` 默认不支持 ``swap`` ，所以需要关闭swap，或者在 kubelet 启动时传递 ``--fail-swap-on`` 参数。

这里我使用的是 :ref:`jetson_nano` ， :ref:`jetson_swap` 默认用，并且由于NVIDIA定制了操作系统采用的是 zram ，是在内存中划分出部分作为swap，并且采用压缩方式存储的内存型swap。

需要注意，我之前实际上部署 :ref:`arm_k8s_deploy` 已经关闭过swap，但是如果升级操作系统，可能会无意中重新开启了swap。

- 检查zram::

   zramctl

- 在线关闭zram::

   swapoff /dev/zram3
   echo 3 > /sys/class/zram-control/hot_remove
   swapoff /dev/zram2
   echo 2 > /sys/class/zram-control/hot_remove
   swapoff /dev/zram1
   echo 1 > /sys/class/zram-control/hot_remove
   swapoff /dev/zram0
   echo 0 > /sys/class/zram-control/hot_remove

- 禁止zram服务在操作系统启动时启动::

   systemctl disable nvzramconfig.service

- 然后可以正常启动kubelet了::

   systemctl start kubelet
