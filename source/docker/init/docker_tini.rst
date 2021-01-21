.. _docker_tini:

======================
Docker tini进程管理器
======================

Tini
=====

`tini 容器init <https://github.com/krallin/tini>`_ 是一个最小化到 ``init`` 系统，运行在容器内部，用于启动一个子进程，并等待进程退出时清理僵尸和执行信号转发。 这是一个替代庞大复杂的systemd体系的解决方案，已经集成到Docker 1.13中，并包含在Docker CE的所有版本。

Tini的优点:

- tini可以避免应用程序生成僵尸进程
- tini可以处理Docker进程中运行的程序的信号，例如，通过Tini， ``SIGTERM`` 可以终止进程，不需要你明确安装一个信号处理器

使用Tini
===========

要激活Tini，在 ``docker run`` 命令中传递 ``--init`` 参数就可以。

在Docker中，只需要加载Tini并传递运行的程序和参数给Tini就可以::

   # Add Tini
   ENV TINI_VERSION v0.18.0
   ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /tini
   RUN chmod +x /tini
   ENTRYPOINT ["/tini", "--"]

   # Run your program under Tini
   CMD ["/your/program", "-and", "-its", "arguments"]
   # or docker run your-image /your/program ...

上述Dockerfile中，通过 ``ENTRYPOINT`` 启动 ``tini`` 作为进程管理器，然后再通过 ``tini`` 运行 ``CMD`` 指定的程序命令。

如果要使用tini签名，请参考 `tini 容器init <https://github.com/krallin/tini>`_ 发行文档
