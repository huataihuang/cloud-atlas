.. _systemd-nspawn:

=====================
systemd-nspawn
=====================

我在 :ref:`android_build_env_ubuntu` 参考 `How to build LineageOS inside a container <https://dzx.fr/blog/how-to-build-lineageos-inside-a-container/>`_ 发现 ``systemd-nspawn`` 结合 :ref:`debootstrap` 是一个非常轻量级的容器化运行 :ref:`ubuntu_linux` 的方案

- 执行容器启动:

.. literalinclude:: systemd-nspawn/systemd-nspawn_ubuntu-dev
   :language: bash
   :caption: 执行 ``systemd-nspawn`` 启动 ``ubuntu-dev`` 容器

参考
======

- `archlinux: systemd-nspawn <https://wiki.archlinux.org/title/Systemd-nspawn>`_
- `On Running systemd-nspawn Containers <https://benjamintoll.com/2022/02/04/on-running-systemd-nspawn-containers/>`_
- `systemd-nspawn — Spawn a command or OS in a light-weight container <https://www.freedesktop.org/software/systemd/man/systemd-nspawn.html>`_
- `How to build LineageOS inside a container <https://dzx.fr/blog/how-to-build-lineageos-inside-a-container/>`_
