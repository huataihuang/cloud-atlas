.. _set_k8s_worker_internal_ip:

==================================
指定Kubernetes工作节点内网IP
==================================

在 :ref:`arm_k8s_deploy` 实践中，我发现 ``jetson`` 主机加入时使用的是无线网卡接口的IP地址( ``192.168.0.x`` 网段)::

   kubectl get nodes -o wide

显示::

   NAME         STATUS   ROLES    AGE     VERSION   INTERNAL-IP    EXTERNAL-IP   OS-IMAGE             KERNEL-VERSION     CONTAINER-RUNTIME
   jetson       Ready    <none>   19h     v1.19.4   192.168.0.34   <none>        Ubuntu 18.04.5 LTS   4.9.140-tegra      docker://19.3.6
   pi-master1   Ready    master   6d17h   v1.19.4   192.168.6.11   <none>        Ubuntu 20.04.1 LTS   5.4.0-1022-raspi   docker://19.3.8
   pi-worker1   Ready    <none>   3d5h    v1.19.4   192.168.6.15   <none>        Ubuntu 20.04.1 LTS   5.4.0-1022-raspi   docker://19.3.8
   pi-worker2   Ready    <none>   3d5h    v1.19.4   192.168.6.16   <none>        Ubuntu 20.04.1 LTS   5.4.0-1022-raspi   docker://19.3.8

参考 `How to specify Internal-IP for kubernetes worker node <https://medium.com/@kanrangsan/how-to-specify-internal-ip-for-kubernetes-worker-node-24790b2884fd>`_ ，需要修订jetson的kubelet配置，明确指定 ``node-ip`` ，这样kubelet公告就能够正确指定node的 ``internal-ip`` 。原文是说修改 ``/etc/systemd/system/kubelet.service`` 配置，添加 ``--node-ip=192.168.6.10`` 这行配置。不过，现在kubelet的systemd配置目录下 ``/etc/systemd/system/kubelet.service.d``
明确说明了kubelet的扩展配置参数是从 ``/etc/default/kubelet`` 读取的:

.. literalinclude:: set_k8s_worker_internal_ip/10-kubeadm.conf
   :language: bash
   :linenos:
   :caption:

所以我们需要对应修改或创建 ``/etc/default/kubelet`` :

.. literalinclude:: set_k8s_worker_internal_ip/etc_default_kubelet
   :language: bash
   :linenos:

然后重启 ``kubelet`` ::

   systemctl restart kubelet

再检查进程 ``ps aux | grep kubelet`` 就会看到参数最后添加了 ``--node-ip=192.168.6.10`` ::

   /usr/bin/kubelet --bootstrap-kubeconfig=/etc/kubernetes/bootstrap-kubelet.conf --kubeconfig=/etc/kubernetes/kubelet.conf --config=/var/lib/kubelet/config.yaml --network-plugin=cni --pod-infra-container-image=k8s.gcr.io/pause:3.2 --node-ip=192.168.6.10

- 此时在管控节点上检查 ``kubectl get nodes -o wide`` 就会看到 jetson 节点的 ``INTERNAL-IP`` 已经修订成正确的内网IP地址::

   NAME         STATUS   ROLES    AGE     VERSION   INTERNAL-IP    EXTERNAL-IP   OS-IMAGE             KERNEL-VERSION     CONTAINER-RUNTIME
   jetson       Ready    <none>   19m     v1.19.4   192.168.6.10   <none>        Ubuntu 18.04.5 LTS   4.9.140-tegra      docker://19.3.6
   pi-master1   Ready    master   7d      v1.19.4   192.168.6.11   <none>        Ubuntu 20.04.1 LTS   5.4.0-1022-raspi   docker://19.3.8
   pi-worker1   Ready    <none>   3d12h   v1.19.4   192.168.6.15   <none>        Ubuntu 20.04.1 LTS   5.4.0-1022-raspi   docker://19.3.8
   pi-worker2   Ready    <none>   3d12h   v1.19.4   192.168.6.16   <none>        Ubuntu 20.04.1 LTS   5.4.0-1022-raspi   docker://19.3.8

参考
=====

- `How to specify Internal-IP for kubernetes worker node <https://medium.com/@kanrangsan/how-to-specify-internal-ip-for-kubernetes-worker-node-24790b2884fd>`_
