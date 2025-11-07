.. _alpine_ssh_syslog:

================================
Alpine ssh服务配置syslog日志
================================

我在排查 :ref:`podman` rootless 运行 :ref:`docker_tini` 来启动多个进程，但是发现除了 ``crond`` 能够启动， ``sshd`` 和 ``syslogd`` 都无法启动

检查 ``podman logs alpine-dev`` 发现:

.. literalinclude:: alpine_ssh_syslog/podman_logs_error
   :caption: 控制台日志显示 ``syslogd`` 和 ``sshd`` 启动失败
   :emphasize-lines: 3,7

实际上我已经在 ``Dockerfile`` 中使用了 ``ssh-keygen -A`` 来生成 host key，并且我也检查了 ``/etc/ssh`` 目录确认host key存在并且权限正确

乌龙了，原来在 :ref:`podman` rootless 中运行的 ``tini`` 进程包括后续启动的子进程，都是 ``admin`` 属主非 ``root`` 权限。这导致集成无法读取 ``/etc/ssh`` 目录下的 Host key 文件，而且 ``syslogd`` 也无法绑定 ``socket`` 。

这也是为何我每次进入容器， ``sudo`` 切换到 ``root`` 身份都能正常运行，我忘记在 ``rootless`` 容器中运行的 ``tini`` 进程管理器自身就是 ``admin`` 属主，没有root权限导致了这个异常。

修订 ``entrypoint.sh`` 脚本，将服务进程以 ``sudo`` 方式执行
