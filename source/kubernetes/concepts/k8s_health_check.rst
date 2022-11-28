.. _k8s_health_check:

=====================
Kubernetes健康检测
=====================

当需要 :ref:`k8s_crashloopbackoff` 等异常排查，需要理解 ``kubelet`` 如何侦测容器的健康状况。

Kubelet使用探针(probes)来获取这些状态情况:

- 存活(Liveness): 确定是否需要重启容器(例如应用死锁)，有助于提高应用的可用性(即使应用程序存在缺陷)
- 就绪(Readiness): 确定容器是否准备好接受请求流量，当一个Pod中所有容器都就绪的时候，才能认为该Pod就绪。可以用来控制Pod作为Service的后端，如果Pod没有就绪，就会被从Service的负载均衡中剔除
- 启动(Startup): 了解应用容器是否启动成功，在启动成功之后就可以进行存活和就绪检测。特别是对于慢启动容器，使用启动探针可以避免容器服务运行前就被杀掉。

实践
======

在部署 :ref:`kind_run_simple_container` 需要 :ref:`k8s_crashloopbackoff` :

- 根据以往 :ref:`k8s_crashloopbackoff` ，

参考
======

- `Kubernetes文档>>任务>>配置Pods和容器>>配置存活、就绪和启动探针 <https://kubernetes.io/zh-cn/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/>`_
