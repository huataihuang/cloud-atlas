.. _introduce_docker_init:

=============================
Docker多进程容器init进程简介
=============================

在容器技术领域，有一个咒语 ``每个容器一个进程`` ，也就是说你不应该将容器视为传统的 ``大而全的虚拟机`` ，而是轻量级专用容器。

然而，事实上，在一个容器中确实运行了多个进程，例如 ``ENTRYPOINT`` 就是一个不折不扣的 ``init process`` 。有时我们需要在容器中运行多个相互依赖的进程(例如 :ref:`sidecar` ) 或者将历史应用程序迁移到容器环境中，此时我们需要一个传统的进程管理器以便在容器中运行多个进程。

不同的进程管理器
=================

- :ref:`systemd` - 大而全的系统进程管理器，功能复杂且强大，对于Docker容器环境 :ref:`docker_systemd` 是比较重的解决方案，但是符合传统运维管理模式 **我的实践虽然成功但是依然不推荐，配置太繁琐易错**
- :ref:`openrc` - 在 :ref:`gentoo_image` 实践时意外发现这个轻量级进程管理器在Docker容器中"开箱即用"，而且也是 :ref:`gentoo_linux` 和 :ref:`alpine_linux` 默认进程管理器，得到社区持续开发和维护，所以 **推荐采用**
- :ref:`supervisord` - 易于使用的进程管理器
- `monit <https://mmonit.com/monit/>`_ 小型的进程管理器
- `runit <http://smarden.org/runit/>`_
- `s6 <https://skarnet.org/software/s6/>`_ 非常著名的进程管理器，在 `s6-overlay <https://github.com/just-containers/s6-overlay>`_ 项目提供了精彩的文档，并被很多用户推崇。我将在 :ref:`docker_s6` 中实践。
- :ref:`docker_tini` 是Docker默认进程管理器

参考
=====

- `Choosing an init process for multi-process containers <https://ahmet.im/blog/minimal-init-process-for-containers/>`_
