.. _k8s_crashloopbackoff:

==============================================
Kubernetes pod CrashLoopBackOff错误排查
==============================================

很多时候部署Kubernetes应用容器，经常会遇到pod进入 ``CrashLoopBackOff`` 状态，但是由于容器没有启动，很难排查问题原因。

CrashLoopBackOff错误解析
=========================

``CrashloopBackOff`` 表示pod经历了 ``starting`` , ``crashing`` 然后再次 ``starting`` 并再次 ``crashing`` 。

这个失败的容器会被kubelet不断重启，并且按照几何级数(exponentially)延迟(10s,20s,40s...)直到5分钟，最后一次是10分钟后重置。默认使用的是 `podRestartPolicy <https://kubernetes.io/docs/concepts/workloads/pods/pod-lifecycle/#restart-policy>`_

``PodSpec`` 有一个 ``restartPolicy`` 字段，值可以是 ``Always`` , ``OnFailure`` 和 ``Never`` ，默认是 ``Always``

导致 ``CrashLoopBackOff`` 的原因通常有:

- 容器中应用程序持续crash
- pod/container的参数配置错误
- 当部署Kubernetes pod是出现错误

观察方法如下::

   kubectl get pods -n <NameSpace>

排查方法
=========

- 首先通过 ``describe`` pod获取信息::

   kubectl describe pod <podname>

如果要非常详细的信息，则可以加上一个 ``-v=9`` 参数

- 此外，可以通过 ``get events`` 来获得上述 ``describe`` 的事件部分信息::

   kubectl get event -n <NameSpace>

注意，Docker容器必须保持PID 1进程持续运行，否则容器就会退出(也就是主进程退出)。对于Docker而言PID 1退出就是容器停止，此时如果容器在Kubernetes中就会重启容器。

当容器重启后，Kubernetes就会申明这个Pod进入 ``Back-off`` 状态。此时通过 ``kubectl get pods -n <NameSpace>`` 就会看到容器重启计数增加::

   $ kubectl get pods -n test-kube
   NAME                         READY   STATUS             RESTARTS   AGE
   challenge-7b97fd8b7f-cdvh4   0/1     CrashLoopBackOff   2          60s

- 接下来检查pod的日志::

   kubectl logs <podname> -n <NameSpace>

注意，容器运行需要有输出，通常是容器中运行程序的日志输出(容器通常就是运行一个应用)

- 最后查看 ``Liveness/Readiness`` probe::

   kubectl describe pod <podname> -n <NameSpace>

为了能够让容器不退出，你可以在运行命令中添加一段死循环::

   while true; do sleep 20; done;

这样就可以保持容器持续运行，方便你查看日志

实践案例
=========

我在制作 :ref:`docker_tini` 镜像之后，已经能够在docker运行。但是我通过以下简单的 ``deployments.yaml`` 部署到Kubernetes集群时，发现pod不断重启::

   NAME                           READY   STATUS             RESTARTS   AGE
   onesre-core-5d4d4d8b5f-zn7lg   0/1     CrashLoopBackOff   6          9m1s

此时检查events显示::

   kubectl --kubeconfig meta/admin.kubeconfig -n onesre describe pods onesre-core-5d4d4d8b5f-zn7lg

输出显示::

   Warning  BackOff               9s (x4 over 24s)   kubelet            Back-off restarting failed containe

为何会判断容器失败呢？

参考 `Kubernetes文档>>任务>>配置Pods和容器>>配置存活、就绪和启动探针 <https://kubernetes.io/zh-cn/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/>`_ 添加 :ref:`k8s_pods_cmd_args` ::

    spec:
      containers:
      - image: onesre:20210205-1
        args:
        - /bin/sh
        - -c
        - touch /tmp/healthy
        livenessProbe:
          exec:
            command:
            - cat
            - /tmp/healthy
          initialDelaySeconds: 5
          periodSeconds: 60

.. note::

   :ref:`k8s_pods_cmd_args` 实际上就是传递给Kubernetes的Docker镜像最后的 ``ENTRYPOINT`` 的参数:

   - 对于没有任何操作命令的镜像，就会替代执行一个命令(这里生成了 ``/tmp/healthy`` )并且脚本命令返回 ``0`` 表明容器正常启动 ( 也就会 :ref:`k8s_health_check` 的 ``startup`` 检测成功 ) 
   - 生成的 ``/tmp/healthy`` 又作为 ``liveness`` 的探针检测，确保Kubernetes的存活( ``liveness`` )检测通过

- 检查 ``get pods`` ::

   kubectl -n onesre get pods onesre-core-7697868c67-pmhng -o yaml

显示输出::

   status:
     conditions:
     - lastProbeTime: null
       lastTransitionTime: "2021-02-05T16:10:49Z"
       status: "True"
       type: Initialized
     - lastProbeTime: null
       lastTransitionTime: "2021-02-05T16:10:49Z"
       message: 'containers with unready status: [onesre]'
       reason: ContainersNotReady
       status: "False"
       type: Ready
     - lastProbeTime: null
       lastTransitionTime: "2021-02-05T16:10:49Z"
       message: 'containers with unready status: [onesre]'
       reason: ContainersNotReady
       status: "False"
       type: ContainersReady
     - lastProbeTime: null
       lastTransitionTime: "2021-02-05T16:10:49Z"
       status: "True"
       type: PodScheduled

实际原因是Kubernetes启动pod一定要在container中运行一个程序，并根据运行程序返回来判断容器是否启动。最初我没有配置执行命令，考虑的是等容器启动之后，手工去部署。但是这不符合k8s定义。

所以添加以下内容::

   command: [ "/bin/bash", "-ec"]
   args: [ date; sleep 10; echo 'Hello from the Kubernetes cluster'; sleep 1; while true; do sleep 20; done;]

也就是完整如下::

    spec:
      containers:
      - image: onesre:20210205-1
        command: [ "/bin/bash", "-ec"]
        args: [ date; sleep 10; echo 'Hello from the onesre'; touch /tmp/healthy;  sleep 1; while true; do sleep 20; done;]
        readinessProbe:
          exec:
            command:
            - cat
            - /tmp/healthy
          initialDelaySeconds: 5
        livenessProbe:
          exec:
            command:
            - cat
            - /tmp/healthy
          initialDelaySeconds: 5
          periodSeconds: 60
   
上述包含了启动时:

  - 创建了 ``/tmp/healthy`` 提供 ``readiness`` 和 ``liveness`` 侦测
  - 终端循环执行bash脚本，保持不退出

但是遇到问题，发现没有启动 tini

实际上我的案例是因为没有在Kubernetes启动pod时运行任何主程序，所以导致无法判断容器状态。

参考
=======

- `Troubleshoot pod CrashLoopBackOff error:: Kubernetes <https://beanexpert.co.in/troubleshoot-pod-crashloopbackoff-error-kubernetes/>`_
