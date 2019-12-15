.. _get_container_logs:

=================
获取容器日志
=================

在Pods中有多个容器，则需要获取容器日志，需要通过 ``-c`` 参数指定容器::

   kubectl logs podname -c containername --previous

这里 ``podname`` 指定pod，``containername`` 指定该pod中的容器， ``--previous`` 则输出最近一次容器启动后生成的日志。

对于pod，可以通过 ``describe pod`` 命令来获取pod的event记录，对于排查pod异常会很有帮助

对于namespace，可以整体获得这个namespace中日志信息::

   kubectl get event [--namespace=my-namespace]

参考
=======

- `How do I tell when/if/why a container in a kubernetes cluster restarts? <https://serverfault.com/questions/727104/how-do-i-tell-when-if-why-a-container-in-a-kubernetes-cluster-restarts>`_
