.. _configure_liveness_readiness_and_startup_probes:

=====================================
配置Liveness, Readiness和Startup侦测
=====================================

.. note::

   在Kubernetes更新master节点的管控组件时，合理配置 ``readinessProbe`` 可以使得升级组件平滑(确保pod轮转完全工作正常后再切换下一个pod)。

kubelet使用 ``liveness`` 侦测来获知合适重启一个容器。例如，liveness probes会捕获死锁，即一个应用程序处于运行状态，但是不能工作的情况。在这种状态下重启一个容器可以使得应用程序避免受到bug影响。

kubelet使用 ``readiness`` 侦测来获知一个容器是否已经就绪可以接受流量。当Pod中所有容器都就绪时就认为Pod就绪了。这种情况特别适合Pod作为服务后台的情况。当Pod没有就绪时，会自动从服务负载均衡中移除。

kubelet使用 ``startup`` 侦测来获知一个容器应用是否已经启动。如果配置了这个侦测，kubelet就会在 ``startup`` 侦测成功之前禁止 livenes 和 readiness 侦测，这要可以确保不必要的侦测影响应用启动。这个 startup 侦测可以在启动缓慢的容器上结合liveness侦测使用，就可以避免容器还没有启动和运行就被kubelet杀死。

.. note::

   本文案例可以采用 :ref:`install_run_minikube` 来验证。

定义liveness命令
=================

很多应用程序运行很长时间以后会阻塞，并且只有重启才能恢复。Kubenetes提供了 ``liveness`` 侦测来检查并处理这种情况。



参考
=====

- `Configure Liveness, Readiness and Startup Probes <https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/>`_
