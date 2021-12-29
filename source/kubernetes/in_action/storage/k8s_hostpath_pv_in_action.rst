.. _k8s_hostpath_pv_in_action:

================================
Kubernetes hostPath持久化卷实践
================================

持久化卷部署步骤概述
=====================

部署Kubernetes持久化卷步骤如下:

- 系统管理员创建一个 持久化卷 (Persistent Volumes, PV)
- 开发人员创建一个 持久化卷申明 (Persistent Volumes Claim, PVC)
- 在POD中引用这个申明(claim)，则一旦这个claim被批准，POD就可以使用这个卷

.. figure:: ../../../_static/kubernetes/in_action/storage/k8s_pod_with_pv_pvc.png
   :scale: 60

准备工作
=========

我的测试环境基于 :ref:`arm_k8s_deploy` 的集群，当前已经部署了3个 ``kube-verify`` namespace中的pod。在本次实践中，将创建持久化卷挂载到容器中测试。

- 检查节点::

   kubectl get nodes -o wide

输出信息::

   NAME         STATUS   ROLES    AGE    VERSION   INTERNAL-IP    EXTERNAL-IP   OS-IMAGE             KERNEL-VERSION     CONTAINER-RUNTIME
   jetson       Ready    <none>   40h    v1.19.4   192.168.6.10   <none>        Ubuntu 18.04.5 LTS   4.9.140-tegra      docker://19.3.6
   pi-master1   Ready    master   8d     v1.19.4   192.168.6.11   <none>        Ubuntu 20.04.1 LTS   5.4.0-1022-raspi   docker://19.3.8
   pi-worker1   Ready    <none>   5d4h   v1.19.4   192.168.6.15   <none>        Ubuntu 20.04.1 LTS   5.4.0-1022-raspi   docker://19.3.8
   pi-worker2   Ready    <none>   5d4h   v1.19.4   192.168.6.16   <none>        Ubuntu 20.04.1 LTS   5.4.0-1022-raspi   docker://19.3.8

- 检查 ``kube-verify`` namespace的pod::

   kubectl -n kube-verify get pods -o wide

输出信息::

   NAME                           READY   STATUS    RESTARTS   AGE     IP             NODE         NOMINATED NODE   READINESS GATES
   kube-verify-69dd569645-q9hzc   1/1     Running   0          39h     10.244.5.161   jetson       <none>           <none>
   kube-verify-69dd569645-s5qb5   1/1     Running   0          2d18h   10.244.2.2     pi-worker2   <none>           <none>
   kube-verify-69dd569645-v9zxt   1/1     Running   0          2d18h   10.244.1.2     pi-worker1   <none>           <none>

- 登陆检查 ``pi-worker1`` 上的pod ``kube-verify-69dd569645-v9zxt`` 确认存储情况::

   kubectl -n kube-verify exec -it kube-verify-69dd569645-v9zxt -- /bin/bash

然后检查磁盘 ``df -h`` 看到如下信息::

   Filesystem      Size  Used Avail Use% Mounted on
   overlay          32G  4.9G   26G  17% /
   tmpfs            64M     0   64M   0% /dev
   tmpfs           3.9G     0  3.9G   0% /sys/fs/cgroup
   /dev/sda2        32G  4.9G   26G  17% /etc/hosts
   shm              64M     0   64M   0% /dev/shm
   tmpfs           3.9G   12K  3.9G   1% /run/secrets/kubernetes.io/serviceaccount
   tmpfs           3.9G     0  3.9G   0% /proc/scsi
   tmpfs           3.9G     0  3.9G   0% /sys/firmware

创建持久化卷(persistent Volume)
=================================

- 在主机上创建一个persistent volume::

   mkdir -p /data/pv/hostpath/kube-verify-vol
   chcon -Rt svirt_sandbox_file_t /data/pv/hostpath/kube-verify-vol

.. note::

   执行 ``chcon -Rt svirt_sandbox_file_t <PATH>`` 报错::

      chcon: can't apply partial context to unlabeled file '/data/pv/hostpath/kube-verify-vol'

参考
======

- `Configure a Pod to Use a PersistentVolume for Storage <https://kubernetes.io/docs/tasks/configure-pod-container/configure-persistent-volume-storage/>`_
- `Kubernetes (4): Persistent Volumes – Hello World <https://vocon-it.com/2018/12/10/kubernetes-4-persistent-volumes-hello-world/>`_
- `hostPath as volume in kubernetes <https://stackoverflow.com/questions/50001403/hostpath-as-volume-in-kubernetes>`_
