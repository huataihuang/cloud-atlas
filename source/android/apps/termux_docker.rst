.. _termux_docker:

=======================
在Termux中运行Docker
=======================

我们确实可以在Termux中体验 :ref:`termux_dev` ，但是毕竟是在Android系统中运行一个并非完整的Linux系统。所以我们会有一个疑惑，是否可以在手机系统中，也就是在Termux之上再运行一个 :ref:`docker` 呢？毕竟，只要能够运行Docker，也就意味着打开了一个全新的容器化环境，能够构建不同的应用程序运行环境，更能够把 :ref:`mobile_pixel_dev` 实现得更完美。

- 安装::

   pkg install root-repo
   pkg install docker

安装完成提示::

   Setting up libaio (0.3.112-3) ...
   Setting up libdevmapper (2.03.09-2) ...
   Setting up libseccomp (2.5.4) ...
   Setting up runc (1.0.0-rc92-0) ...

   RunC requires support for devices cgroup support in kernel.

   If CONFIG_CGROUP_DEVICE was enabled during compile time,
   you need to run the following commands (as root) in order
   to use the RunC:

     mount -t tmpfs -o mode=755 tmpfs /sys/fs/cgroup
     mkdir -p /sys/fs/cgroup/devices
     mount -t cgroup -o devices cgroup /sys/fs/cgroup/devices

   If you got error when running commands listed above, this
   usually means that your kernel lacks CONFIG_CGROUP_DEVICE.

   Setting up containerd (1.4.13) ...
   Setting up docker (20.10.14) ...
   NOTE: Docker requires the kernel to support
   device cgroups, namespace, VETH, among others.

   To check a full list of features needed, run the script:
   https://github.com/moby/moby/blob/master/contrib/check-config.sh

内核需要定制支持上述选项

参考
=======

- `Package request: Docker engine #60 <https://github.com/termux/termux-root-packages/issues/60>`_
- `Is it possible to install Docker using Termux? <https://android.stackexchange.com/questions/232264/is-it-possible-to-install-docker-using-termux>`_
