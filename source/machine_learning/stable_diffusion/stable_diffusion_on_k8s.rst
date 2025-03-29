.. _stable_diffusion_on_k8s:

===================================
在Kubernetes部署Stable Diffusion
===================================

在 :ref:`kubernetes` 上部署 :ref:`stable_diffusion_infra` (包括 `Stable Diffusion web UI <https://github.com/Sygil-Dev/sygil-webui>`_ 和 自动模型获取)，可以快速完成一个基于 :ref:`nvidia_gpu` (我使用 :ref:`tesla_p10` )的 :ref:`machine_learning` 案例。此外，我的部署在 :ref:`priv_cloud_infra` 构建的 :ref:`ovmf_gpu_nvme` 虚拟化，也验证了云计算方案。

功能
=======

- 自动模型获取
- 结合 :ref:`nvidia_gpu_operator` ，采用 :ref:`cuda` 库，具有多功能交互UI
- GFPGAN 用于人脸重建，RealESRGAN 用于超采样
- 文本倒置(Textual Inversion)

准备工作
==========

- 首先部署一个至少有一个节点具备GPU的Kubernetes集群:

  - 部署 :ref:`z-k8s` 
  - 配置 :ref:`ovmf_gpu_nvme`
  - :ref:`install_nvidia_linux_driver_in_ovmf_vm`

- 在上述Kubernetes集群 :ref:`z-k8s` :ref:`install_nvidia_gpu_operator`

- 本地安装好 :ref:`helm`

安装
========

- 添加helm仓库 ``stable-diffusion-k8s`` :

.. literalinclude:: stable_diffusion_on_k8s/helm_add_stable-diffusion-k8s_repo
   :language: bash
   :caption: 添加stable-diffusion-k8s helm仓库

- (可选)创建一个 ``values.yaml`` 配置定制设置:

  - 可能需要设置的参数有 ``nodeAffinity`` , ``cliArgs`` (见下文) 以及 ``ingress`` （这样就不需要使用 ``kubectl port-forward`` ，我采用 :ref:`cilium_k8s_ingress_http` )

.. literalinclude:: stable_diffusion_on_k8s/values.yaml
   :language: yaml
   :caption: 定制values.yaml
   :emphasize-lines: 24,34,66,67

values.yaml
-------------

- 在 ``values.yaml`` 中，修订 ``cliArgs`` 可以向WebUI传递参数。默认使用参数是 ``--extra-models-cpu --optimized-turbo`` ，此时会使用 6GB GPU
- 如果要激活 文本倒置(Textual Inversion) ，则去除 ``--optimize`` 和 ``--optimize-turbo`` 参数，然后添加 ``--no-half`` 到 ``cliFlags`` （见上文我配置 ``values.yaml`` )
- 如果输出总是一个绿色图像，则使用参数 ``--precision full --no-half``

开始安装
----------

.. literalinclude:: stable_diffusion_on_k8s/helm_install_stable-diffusion-k8s
   :language: bash
   :caption: 安装stable-diffusion-k8s

提示信息:

.. literalinclude:: stable_diffusion_on_k8s/helm_install_stable-diffusion-k8s_output
   :language: bash
   :caption: 安装stable-diffusion-k8s的输出信息

问题排查
=============

stable diffusion pod调度排查
-------------------------------

- 发现pod调度没有成功，始终pending:

- 检查 pods::

   kubectl describe pods stable-diffusion-1673539037-0

可以看到调度失败信息:

.. literalinclude:: stable_diffusion_on_k8s/stable-diffusion_pod_pending
   :language: bash
   :caption: stable-diffusion pod 调度失败信息
   :emphasize-lines: 9

- 检查配备了GPU的节点 ``z-k8s-n-1`` 标签，是存在 ``nvidia.com/gpu.present=true``

- 显示调度失败是因为没有 ``PersistentVolumeClaims`` 持久化卷申明，也就是说集群需要先部署一个卷

这里 ``Node-Selectors:              nvidia.com/gpu.present=true`` ，可以通过 ``kubectl get nodes --show-labels`` 看到，安装了NVIDIA GPU的 ``z-k8s-n-1`` 是具备该标签的

这个报错 :ref:`fix_pod_has_unbound_immediate_persistentvolumeclaims` 感觉原因是我部署节点都只分配了 ``9.5G`` 磁盘作为 :ref:`containerd` 存储目录，实际上多次安装以后磁盘空间只剩下 1.x GB:

.. literalinclude:: stable_diffusion_on_k8s/df_vdb1
   :language: bash
   :caption: /dev/vdb1空间不足
   :emphasize-lines: 7

而这个 ``stable-diffusion`` 自身镜像就需要下载8G，同时卷申明也需要空间

检查::

   $ kubectl get pvc
   NAME                                                                    STATUS    VOLUME   CAPACITY   ACCESS MODES   STORAGECLASS   AGE
   stable-diffusion-1673539037-model-store-stable-diffusion-1673539037-0   Pending                                                     16m

   $ kubectl get pv
   No resources found

- :ref:`ceph_extend_rbd_drive_with_libvirt_xfs_vdb1` 将虚拟机 ``z-k8s-n-1`` 的 ``/var/lib/containerd`` 扩展成50G

- 不过还是存在同样的调度问题，仔细 :ref:`gpu_node_schedule_err_debug` 发现这是因为 passthrough GPU设备只能分配给一个pod使用，而在 :ref:`install_nvidia_gpu_operator` 的示例pod没有删除，导致GPU设备占用。删除掉占用GPU的测试pod之后...怎么，还是没有调度成功...

- 仔细检查 ``vpc`` ::

   $ kubectl get pvc
   NAME                                                                    STATUS    VOLUME   CAPACITY   ACCESS MODES   STORAGECLASS   AGE
   stable-diffusion-1673539037-model-store-stable-diffusion-1673539037-0   Pending                                                     13h

   $ kubectl describe pvc stable-diffusion-1673539037-model-store-stable-diffusion-1673539037-0
   Name:          stable-diffusion-1673539037-model-store-stable-diffusion-1673539037-0
   Namespace:     default
   StorageClass:
   Status:        Pending
   Volume:
   Labels:        app.kubernetes.io/instance=stable-diffusion-1673539037
                  app.kubernetes.io/name=stable-diffusion
   Annotations:   <none>
   Finalizers:    [kubernetes.io/pvc-protection]
   Capacity:
   Access Modes:
   VolumeMode:    Filesystem
   Used By:       stable-diffusion-1673539037-0
   Events:
     Type    Reason         Age                     From                         Message
     ----    ------         ----                    ----                         -------
     Normal  FailedBinding  4m19s (x3262 over 13h)  persistentvolume-controller  no persistent volumes available for this claim and no storage class is set

可以看到 ``describe pod`` 有如下存储定义:

     stable-diffusion-1673589055-model-store:
       Type:       PersistentVolumeClaim (a reference to a PersistentVolumeClaim in the same namespace)
       ClaimName:  stable-diffusion-1673589055-model-store-stable-diffusion-1673589055-0
       ReadOnly:   false

在 `Stable Diffusion on Kubernetes with Helm <https://github.com/amithkk/stable-diffusion-k8s>`_ 项目的issue中有一个 `Issues with "storageClassName" #1 <https://github.com/amithkk/stable-diffusion-k8s/issues/1>`_ 提到 ``storageClassName`` 定义持久化存储，有一个代码合并提示文档::

   persistence:
     annotations: {}
     ## If defined, storageClass: <storageClass>
     ## If set to "-", storageClass: "", which disables dynamic provisioning
     ## If undefined (the default) or set to null, no storageClass spec is
     ##   set, choosing the default provisioner.  (gp2 on AWS, standard on
     ##   GKE, AWS & OpenStack)
     ##
     accessMode: ReadWriteOnce
     size: 8Gi

为了简化，先暂时关闭持久化存储::

   persistence:
     annotations: {}
     ## If defined, storageClass: <storageClass>
     ## If set to "-", storageClass: "", which disables dynamic provisioning
     ## If undefined (the default) or set to null, no storageClass spec is
     ##   set, choosing the default provisioner.  (gp2 on AWS, standard on
     ##   GKE, AWS & OpenStack)
     ##
     storageClass: "-"
     accessMode: ReadWriteOnce
     size: 8Gi

- 然后尝试debug方式安装::

   $ helm install --debug --generate-name amithkk-sd/stable-diffusion -f values.yaml

发现安装失败原因是无法下载:

.. literalinclude:: stable_diffusion_on_k8s/helm_install_debug_stable-diffusion
   :language: bash
   :caption: 使用helm install --debug 安装stable-diffusion显示无法下载
   :emphasize-lines: 9

启动代理翻墙，可以看到 ``helm`` 正常工作如下:

.. literalinclude:: stable_diffusion_on_k8s/helm_install_debug_stable-diffusion_success
   :language: bash
   :caption: 启用代理翻墙，helm install --debug 安装stable-diffusion
   :emphasize-lines: 9

但是奇怪，这次没有看到 ``kubectl get pods`` 输出有 ``stable-diffusion`` 的pod

回退掉 ``storageClass: "-"`` ，尝试验证::

   $ helm install --debug --dry-run --generate-name amithkk-sd/stable-diffusion -f values.yaml

PVC和PV配置解决调度问题
~~~~~~~~~~~~~~~~~~~~~~~~~

- 检查 ``stable-diffusion`` 所要求的pvc::

   kubectl get pvc stable-diffusion-1673591786-model-store-stable-diffusion-1673591786-0 -o yaml

可以看到:

.. literalinclude:: stable_diffusion_on_k8s/stable-diffusion_pvc
   :language: yaml
   :caption: stable-diffusion的PVC

参考 `Configure a Pod to Use a PersistentVolume for Storage <https://kubernetes.io/docs/tasks/configure-pod-container/configure-persistent-volume-storage/>`_ 有一句非常关键的话:

**If the control plane finds a suitable PersistentVolume with the same StorageClass, it binds the claim to the volume.**

明白了:

- ``stable-diffusion`` 声明了一个PVC，需要有对应的PV，这个PVC和PV对应绑定关系是通过 ``storageClassName`` 指定的关联
- 在 `Stable Diffusion on Kubernetes with Helm <https://github.com/amithkk/stable-diffusion-k8s>`_ 项目的issue中有一个 `Issues with "storageClassName" #1 <https://github.com/amithkk/stable-diffusion-k8s/issues/1>`_ 提到 ``storageClassName`` 定义持久化存储

  - 默认没有配置，如果是自己部署，需要定义一个PV和PVC关联的 ``storageClass``
  - 可以使用本地存储(例如我现在就搞一个)

- 在 ``stable-diffusion-pv.ymal`` :

.. literalinclude:: stable_diffusion_on_k8s/stable-diffusion-pv.yaml
   :language: yaml
   :caption: 创建定义本地存储 stable-diffusion-pv.yaml
   :emphasize-lines: 8

注意：这里定义了存储类型命名是 ``manual`` ，所以需要对应修改 ``values.yaml`` 在其中添加了一行:

.. literalinclude:: stable_diffusion_on_k8s/values_part.yaml
   :language: yaml
   :caption: 在values.yaml中添加一行 storageClass: manual
   :emphasize-lines: 9

- 此时再次执行 ``helm install ... -f values.yaml`` 就可以看到能够正确调度到 ``z-k8s-n-1`` ::

   $ kubectl get pods -o wide
   NAME                              READY   STATUS      RESTARTS        AGE     IP           NODE        NOMINATED NODE   READINESS GATES
   ,..
   stable-diffusion-1673593163-0     0/2     Init:1/3    36 (16m ago)    169m    10.0.3.164   z-k8s-n-1   <none>           <none>

stable-diffusion容器启动失败排查
----------------------------------

调度虽然解决了，但是观察pod始终停留在初始化状态 ``Init:1/3`` 

- 检查pod::

   kubectl describe pods stable-diffusion-1673593163-0

可以看到是容器启动问题::

   Events:
     Type     Reason   Age                   From     Message
     ----     ------   ----                  ----     -------
     Warning  BackOff  15m (x628 over 170m)  kubelet  Back-off restarting failed container

- 检查日志::

   kubectl logs stable-diffusion-1673593163-0

可以看到::

   Error from server (BadRequest): container "stable-diffusion-stable-diffusion" in pod "stable-diffusion-1673593163-0" is waiting to start: PodInitializing

之前发现容器镜像下载因为GFW原因出现TLS连接超时，怀疑是镜像下载问题导致。

解决方法
---------

- :ref:`containerd_proxy` (类似 :ref:`docker_proxy`) 在虚拟机中运行的 ``containerd`` 服务配置代理，这样下载镜像就能够翻越GFW
- 使用Kubernetes的环境变量( ``env:`` )，向启动的poed容器注入代理配置::

    env:
    - name: HTTP_PROXY
      value: "http://192.168.6.200:3128"
    - name: HTTPS_PROXY
      value: "http://192.168.6.200:3128" 


参考
======

- `Stable Diffusion on Kubernetes with Helm <https://github.com/amithkk/stable-diffusion-k8s>`_
