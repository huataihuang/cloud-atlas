.. _k8s_stuck_in_podinit:

==================================
Kubernetes Pod停留在Init状态排查
==================================

在部署Kubernetes集群时，遇到apiserver初始化始终停留在 ``Init:0/1`` 状态。这种情况的排查有一定方式方法，记录如下:

Init container
===============

当Kubernetes的Pod始终停留在init状态，意味着这个pod包含了 ``init container`` 无法完成: 这里可以观察 ``init:N/M`` 表示pod包含M个Init容器，其中N个已经完成，例如上文 ``Init:0/1`` 表示Pod只有一个容器需要初始化，其中完成初始化的容器是0个。

排查方法
==========

要排查Pod无法启动原因，可以依次使用以下命令:

- ``kubectl describe pods pod-XXX`` :

获取pod信息，这个步骤是最基本步骤，可以获得events，例如上例中，就可以看到Pod无法启动的事件原因::

   Warning  FailedMount  25m (x410 over 14h)  kubelet  MountVolume.SetUp failed for volume "xxxxx-configs" : configmaps "xxxxx-configs-520" not found
   Warning  FailedMount  7s (x411 over 14h)   kubelet  Unable to mount volumes for pod "apiserver-795c56f6bd-4n9k8_example-cluster(5ba50edb-7ae9-4ec6-8ce5-17918426db4d)": timeout expired waiting for volumes to attach or mount for pod "example-cluster"/"apiserver-795c56f6bd-4n9k8". list of unmounted volumes=[xxxxx-configs]. list of unattached volumes=[master-pki ...]

可以看到原因是无法挂载卷

- ``kubectl logs pod-XXX`` :

检查pod中容器日志

- ``kubectl logs pod-XXX -c init-container-xxx`` :

如果一个pod中有多个容器，则必须指定容器 ``-c init-container-xxx`` 才能看到对应日志

- ``kubectl describe node node-XXX`` :

有可能需要检查pod所在节点的事件日志

- ``kubectl get events`` :

有可能需要检查整个集群的事件日志

- ``journalctl -xeu kubelet | tail -n 10`` :

检查systemd的kubelet日志

- ``journalctl -xeu docker | tail -n 1`` :

检查docker日志

参考
=======

- `Pods stuck in PodInitializing state indefinitely <https://stackoverflow.com/questions/53314770/pods-stuck-in-podinitializing-state-indefinitely>`_
