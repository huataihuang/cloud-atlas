.. _multi_arch_k8s:

========================
混合架构Kubernetes集群
========================

混合架构节点选择(nodeSelector)
=================================

在异构(混合架构)的kubernetes集群，需要确保部署的pod能够创建到对应架构的节点，即ARM镜像的pods创建到ARM节点，x86镜像的pods创建到x86节点。我们可以通过 :ref:`k8s_nodeselector` 来实现部署。

- 检查节点标签::

   kubectl get nodes -o wide --show-labels

可以看到ARM节点和x86节点显示如下::

   NAME         STATUS   ROLES                  AGE     VERSION   INTERNAL-IP     EXTERNAL-IP   OS-IMAGE                 KERNEL-VERSION       CONTAINER-RUNTIME        LABELS
   ...
   pi-worker1   Ready    <none>                 6d23h   v1.22.0   192.168.6.15    <none>        Ubuntu 20.04.2 LTS       5.4.0-1041-raspi     docker://20.10.7         beta.kubernetes.io/arch=arm64,beta.kubernetes.io/os=linux,kubernetes.io/arch=arm64,kubernetes.io/hostname=pi-worker1,kubernetes.io/os=linux
   ...
   zcloud       Ready    <none>                 4d22h   v1.22.0   192.168.6.200   <none>        Arch Linux               5.13.9-arch1-1       docker://20.10.8         beta.kubernetes.io/arch=amd64,beta.kubernetes.io/os=linux,kubernetes.io/arch=amd64,kubernetes.io/hostname=zcloud,kubernetes.io/os=linux

- 在ARM的deployment配置中使用::

   ...
   spec:
     containers:
     - name: nginx
       image: nginx-linux-arm64
       imagePullPolicy: IfNotPresent
     nodeSelector:
       kubernetes.io/arch=arm64

参考
=====

- `Building a hybrid x86–64 and ARM Kubernetes Cluster <https://carlosedp.medium.com/building-a-hybrid-x86-64-and-arm-kubernetes-cluster-e7f94ff6e51d>`_
- `Install a multi-node ,multi-arch Kubernetes cluster using kubeadm in just 30 mins! <https://masterofnone.io/spinupk8/>`_
- `Multiplatform (amd64 and arm) Kubernetes cluster setup <https://gist.github.com/squidpickles/dda268d9a444c600418da5e1641239af>`_
