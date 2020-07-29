.. _load_kind_image:

================================
加载kind镜像
================================

Docker镜像可以通过以下命令加载到集群中::

   kind load docker-image my-custom-image --name cluster-name

此外，镜像打包也可以加载::

   kind load image-archive /my-image-archive.tar

kind镜像加载实战
=================

kind提供了将docker镜像加载到集群每个node节点上的操作命令，加载镜像之后，集群的每个节点都会具备该镜像文件，就不需要再从docker hub仓库pull了，节约了下载带宽资源。当然，你使用kubectl命令创建pod也能够下载对应镜像，重复拉取镜像会拖慢pod创建速度。

.. note::

   这里采用的镜像实战是 :ref:`dockerfile` 案例，我们将在kind集群中构架一个基础的自定义ssh服务的CentOS。

- 创建Dockerfile目录 ``docker`` ，然后进入该目录，在该目录下存放 ``centos8-ssh`` 文件

.. literalinclude:: ../admin/centos8-ssh
   :language: dockerfile
   :linenos:
   :caption:

.. note::

   如果你有需要复制到镜像中文件，例如我需要复制公钥文件 ``authorized_keys`` 

- 执行docker创建镜像命令::

   docker build -f centos8-ssh -t local:centos8-ssh .

- 完成后检查镜像::

   docker images

显示::

   REPOSITORY          TAG                 IMAGE ID            CREATED             SIZE
   local               centos8-ssh         80314bfa9eed        8 seconds ago       286MB

- 将镜像加载到集群 ``dev`` 中::

   kind load docker-image local:centos8-ssh --name dev

提示信息::

   Image: "local:centos8-ssh" with ID "sha256:80314bfa9eeddd87d002cf89026089a084b9fd2e511bbc07f0fbc977e7f06ed3" not yet present on node "dev-worker2", loading...
   Image: "local:centos8-ssh" with ID "sha256:80314bfa9eeddd87d002cf89026089a084b9fd2e511bbc07f0fbc977e7f06ed3" not yet present on node "dev-worker", loading...
   ...

- 完成镜像上传后，kind集群的每个node节点都会具备分发的自定义镜像 ``centos8-ssh`` ，我们需要检查镜像的名字， ``docker exec`` 提供了检查集群节点(这里案例是检查集群节点 ``dev-worker`` )上镜像列表的命令::

   docker exec -it dev-worker crictl images

显示镜像列表如下::

   MAGE                                      TAG                 IMAGE ID            SIZE
   docker.io/kindest/kindnetd                 0.5.4               2186a1a396deb       113MB
   docker.io/library/local                    centos8-ssh         80314bfa9eedd       294MB
   docker.io/rancher/local-path-provisioner   v0.0.12             db10073a6f829       42MB
   k8s.gcr.io/coredns                         1.6.7               67da37a9a360e       43.9MB
   k8s.gcr.io/debian-base                     v2.0.0              9bd6154724425       53.9MB
   k8s.gcr.io/etcd                            3.4.3-0             303ce5db0e90d       290MB
   k8s.gcr.io/kube-apiserver                  v1.18.2             7df05884b1e25       147MB
   k8s.gcr.io/kube-controller-manager         v1.18.2             31fd71c85722f       133MB
   k8s.gcr.io/kube-proxy                      v1.18.2             312d3d1cb6c72       133MB
   k8s.gcr.io/kube-scheduler                  v1.18.2             121edc8356c58       113MB
   k8s.gcr.io/pause                           3.2                 80d28bedfe5de       686kB

.. note::

   :ref:`crictl` 是CRI兼容的容器runtime命令行工具。在kind的Kubernetes集群节点上没有安装docker命令行工具，而是安装了Kubernetes的crictl工具。

   注意，kind配置的 ``/etc/crictl.yaml`` 只有一行配置，指向Kubernetes节点上的containerd的socket::

      runtime-endpoint: unix:///var/run/containerd/containerd.sock

   从节点上运行的 ``kubelet`` 进程的参数也可以看到 ``--container-runtime-endpoint=/run/containerd/containerd.sock`` ，这就是 ``crictl`` 可以直接和 containerd 通讯的socks。

- 为了方便管理，我先创建一个独立的namespace，名为 ``studio`` 来容纳后续创建的pod::

   kubectl create namespace studio

提示信息::

   namespace/studio created

检查::

   kubectl get namespaces

可以看到::

   NAME                 STATUS   AGE
   default              Active   2d
   kube-node-lease      Active   2d
   kube-public          Active   2d
   kube-system          Active   2d
   local-path-storage   Active   2d
   studio               Active   16s

- 既然我们已经加载好镜像(注意：创建的docker镜像是具备了 ``ENTRYPOINT`` ，也就是最后会自动启动sshd和bash，所以我们的kubernetes不需要传递容器命令)，我们现在来创建pod::

   kubectl run dev-studio --image docker.io/library/local:centos8-ssh --namespace=studio

- 然后检查创建的pod::

   kubectl get pods -n studio

糟糕，pod出现了crash::

   NAME         READY   STATUS             RESTARTS   AGE
   dev-studio   0/1     CrashLoopBackOff   3          59s

我们来检查以下pod失败的原因::

   kubectl describe pods dev-studio -n studio

输出显示::

   Name:         dev-studio
   Namespace:    studio
   Priority:     0
   Node:         dev-worker3/172.19.0.4
   Start Time:   Sun, 19 Jul 2020 22:36:23 +0800
   Labels:       run=dev-studio
   Annotations:  <none>
   Status:       Running
   IP:           10.244.5.2
   IPs:
     IP:  10.244.5.2
   Containers:
     dev-studio:
       Container ID:   containerd://50e1df5e4464ede9f6cdb0e3b59bb5bcf93c02907cf0038732a0ff8fcfe882c2
       Image:          docker.io/library/local:centos8-ssh
       Image ID:       sha256:80314bfa9eeddd87d002cf89026089a084b9fd2e511bbc07f0fbc977e7f06ed3
       Port:           <none>
       Host Port:      <none>
       State:          Terminated
         Reason:       Completed
         Exit Code:    0
         Started:      Sun, 19 Jul 2020 22:37:56 +0800
         Finished:     Sun, 19 Jul 2020 22:37:56 +0800
       Last State:     Terminated
         Reason:       Completed
         Exit Code:    0
         Started:      Sun, 19 Jul 2020 22:37:06 +0800
         Finished:     Sun, 19 Jul 2020 22:37:06 +0800
       Ready:          False
       Restart Count:  4
       Environment:    <none>
       Mounts:
         /var/run/secrets/kubernetes.io/serviceaccount from default-token-tpblw (ro)
   Conditions:
     Type              Status
     Initialized       True
     Ready             False
     ContainersReady   False
     PodScheduled      True
   Volumes:
     default-token-tpblw:
       Type:        Secret (a volume populated by a Secret)
       SecretName:  default-token-tpblw
       Optional:    false
   QoS Class:       BestEffort
   Node-Selectors:  <none>
   Tolerations:     node.kubernetes.io/not-ready:NoExecute for 300s
                    node.kubernetes.io/unreachable:NoExecute for 300s
   Events:
     Type     Reason     Age               From                  Message
     ----     ------     ----              ----                  -------
     Normal   Scheduled  <unknown>         default-scheduler     Successfully assigned studio/dev-studio to dev-worker3
     Normal   Pulled     2s (x5 over 94s)  kubelet, dev-worker3  Container image "docker.io/library/local:centos8-ssh" already present on machine
     Normal   Created    2s (x5 over 94s)  kubelet, dev-worker3  Created container dev-studio
     Normal   Started    2s (x5 over 94s)  kubelet, dev-worker3  Started container dev-studio
     Warning  BackOff    1s (x9 over 92s)  kubelet, dev-worker3  Back-off restarting failed container

排查pod启动失败
================

- 登陆到服务器节点排查::

   docker exec -it dev-worker3 /bin/bash

- 在node节点 ``dev-worker3`` 上通过 ``crictl`` 排查，首先检查pods::

   crictl pods

这里显示的信息是Ready的::

   POD ID              CREATED             STATE               NAME                NAMESPACE           ATTEMPT
   23e53447b90b3       13 minutes ago      Ready               dev-studio          studio              0
   f4b1796209a86       2 days ago          Ready               kube-proxy-qfrkl    kube-system         0
   2ef62989002ca       2 days ago          Ready               kindnet-ktjzr       kube-system         0

但是容器启动失败::

   crictl ps -a

::

   CONTAINER           IMAGE               CREATED             STATE               NAME                ATTEMPT             POD ID
   375a0e4fa36a8       80314bfa9eedd       25 seconds ago      Exited              dev-studio          8                   23e53447b90b3
   b8de653dd80ff       2186a1a396deb       2 days ago          Running             kindnet-cni         0                   2ef62989002ca
   44b9a685912b6       312d3d1cb6c72       2 days ago          Running             kube-proxy          0                   f4b1796209a86

- 检查容器日志::

   crictl logs 375a0e4fa36a8

奇怪，日志始终是空的

- 在node上inspect容器::

   crictl inspect 375a0e4fa36a8

显示::

   ...
       "runtimeSpec": {
         "ociVersion": "1.0.1-dev",
         "process": {
           "user": {
             "uid": 0,
             "gid": 0
           },
           "args": [
             "/bin/sh",
             "-c",
             "/usr/sbin/sshd \u0026\u0026 /bin/bash"
           ],
   ...

是不是dockerfile的 ``ENTRYPOINT /usr/sbin/sshd && /bin/bash`` 到Kubernetes中不能正常运行了？为何Dockerfile配置中 ``&&`` 符号到了Kubernetes中成了 ``\u0026\u0026``

对比
-------

- 尝试对比一个简单的httpd容器::

   kubectl run test --image=docker.io/centos/httpd

- 这个标准镜像启动是正常的::

   kubectl get pods -o wide

显示::

   NAME   READY   STATUS    RESTARTS   AGE   IP           NODE          NOMINATED NODE   READINESS GATES
   test   1/1     Running   0          43m   10.244.4.2   dev-worker5   <none>           <none>



参考
======

- `Kind Quick Start - Loading an Image Into Your Cluster <https://kind.sigs.k8s.io/docs/user/quick-start/>`_
