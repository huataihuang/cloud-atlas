.. _node_exporter_killed_by_sigpipe:

===================================
Node Exporter被 ``SIGPIPE`` 杀死
===================================

.. note::

   这个问题我主要是记录，尚未真正遇到，不过，我遇到过类似生产环境组件因为 ``SIGPIPE`` 退出的问题，原理和情况相似。

   这个 ``SIGPIPE`` 导致 Node Exporter 退出的问题会发生在早期版本，不过现在 Node Exporter 内置了 ``SIGPIPE`` 处理，所以已经不再出现因为 ``PIPE`` 管道异常导致退出的问题。这里仅作为记录参考

Node Exproter在 :ref:`systemd` 环境下运行，有时候你可能会遇到异常退出，检查 ``systemctl status node_exporter`` 可能会看到类似:

.. literalinclude:: node_exporter_killed_by_sigpipe/systemd_service_killed_sigpipe
   :caption: 服务进程被 ``PIPE`` 信号杀死的案例
   :emphasize-lines: 5

这里被 **信号** ``PIPE`` 杀死的原因: 

当使用已经失效的读取器写入管道时，写入器将收到 ``SIGPIPE`` 信号。默认情况下，这会终止进程。如果忽略这个信号，写入将返回错误 ``EPIPE`` 。无论 ``reader`` 是怎么死亡的，这种情况都会发生。

这里 ``node_exporter``  服务配置是:

.. literalinclude:: node_exporter_killed_by_sigpipe/node_exporter.service
   :caption: ``node_exporter.service`` 配置
   :emphasize-lines: 13

默认配置是 ``Restart=on-failure`` ，早期版本没有处理 ``SIGPIPE`` 信号，所以会导致收到 ``PIPE`` 信号时候退出，但是因为没有作为Fail处理，所以也不会自动启动。

对于不能处理 ``SIGPIPE`` 信号的软件退出问题，可以修改 :ref:`systemd` 配置，修改为::

   Restart=always

或者加上::

   RestartForceExitStatus=SIGPIPE

参考
======

- `Is SIGPIPE signal received when reader is killed forcefully(kill -9)? <https://stackoverflow.com/questions/70648067/is-sigpipe-signal-received-when-reader-is-killed-forcefullykill-9>`_
