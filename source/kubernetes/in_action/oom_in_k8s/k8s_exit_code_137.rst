.. _k8s_exit_code_137:

==========================================
Kubernetes的pod异常退出(ExitCode:137)
==========================================

在生产环境中， ``OOM kill`` ( :ref:`linux_oom` )是非常常见的现象，对于 Kubernetes 而言，在 ``kubelet`` 日志中会记录类似:

.. literalinclude:: k8s_exit_code_137/kubelet_oom_killed
   :caption: ``kubelet`` 日志中记录了 ``XXXXX`` pod被 ``OOMKilled``
   :emphasize-lines: 1

Exit Code 137
================

Exit Code 137表示进程由于使用太多内存而被(意外)终止。

在Linux操作系统中，所有意外退出/杀死的进程都会返回一个退出码，以提供一个检查机制来通知用户、系统和应用程序进程为何停止。这个退出码(exit code)数值介于 ``0`` 到 ``255`` :

- ``0`` 表示shell命令成功执行完成; **非零** 退出状态表示失败
- 当命令因为编号为 ``N`` 的 **致命信号** (fatal signal) 退出时，Bash就会使用 ``128+N`` 作为退出状态

  - ``OOMKilled`` 进程收到的致命信号是 ``9`` ，也就是 ``SIGKILL (signal 9)`` 强制杀死
  - ``128+9 = 137`` 表示pod进程是被操作系统直接杀死的
  - 如果 ``kubelet`` 记录的 ``ExitCode`` 是 ``143`` ，则表明容器是被 ``SIGTERM (signal 15)`` **温柔** 终止

- 在bash中，最后一个命令的退出状态可以在特殊参数 ``$?`` 查看( ``echo $?`` )

- 当 Kubernetes 记录了容器或Pod因为内存使用过高而终止 ``ExitCode 137`` ，就应该详细调查程序是否存在内存泄漏或者编程不佳导致资源过渡消耗

常见的内存问题
================

容器使用超出配置的内存限制
---------------------------

容器超出内存限制( :ref:`k8s_limits_and_requests` )就会触发操作系统OOM kill，如果代码检查没有出现 **内存泄漏** 以及低效代码，则可以根据业务情况调整 :ref:`resource_management_for_pods_containers` 避免触发OOM Kill 

如果没有合理的容器内存限制，并且在容器内存使用达到 ``limits`` 之前及时告警和处理，有可能会触发物理服务器节点的操作系统级别的OOM kill，这种进程杀死是随机的不可预测的，有可能殃及并没有超出预期设置的正常pod被误杀。

应用程序内存泄漏
-------------------

当应用程序使用内存但是操作完成后没有释放内存，就会发生内存泄漏，导致内存逐渐填满并耗尽所有可用容量。可以尝试采用 :ref:`valgrind` 这样的诊断工具来帮助排查内存泄漏。

负载监控
----------

随着业务增长，有可能内存消耗更多(内存密集型应用)。所以要进行长期广泛的监控( :ref:`prometheus` )，以便能够观察到变化趋势以及即使收到告警，以及采用自动扩展方案



参考
=====

- `How to Fix Exit Code 137 | Kubernetes Memory Issues <https://foxutech.com/how-to-fix-exit-code-137-kubernetes-memory-issues/>`_
- `Bash: Exit Status <https://www.gnu.org/software/bash/manual/html_node/Exit-Status.html>`_
- `SIGKILL: Fast Termination Of Linux Containers | Signal 9 <https://komodor.com/learn/what-is-sigkill-signal-9-fast-termination-of-linux-containers/>`_
- `How to fix exit code 137 <https://www.airplane.dev/blog/exit-code-137>`_
