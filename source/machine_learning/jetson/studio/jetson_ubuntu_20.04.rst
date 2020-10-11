.. jetson_ubuntu_20.04:

===============================
在Jetson Nano运行Ubuntu 20.04
===============================

.. warning::

   从NVIDIA官方说明可以看到NVIDIA并没有提供Ubuntu 20.04 LTS的支持，官方仅提供 Ubuntu 18.04 LTS的生产版本支持。而NVIDIA还提供 `20.09 Jetson CUDA-X AI Developer Preview <https://developer.nvidia.com/embedded/20.09-Jetson-CUDA-X-AI-Developer-Preview>`_ 应该还是基于Ubuntu 18.04 LTS操作系统。

   所以不建议升级生产环境的操作系统版本，我这里仅记录参考，实际并没有实践。

当前Jetson Developer Kits(Jetson Nano, Jetson TX2 和 Jetson AGX Xavier)官方提供版本都是运行L4T 32.2.x。L4T是Ubuntu 18.04的定制支持Jetson Tegra处理器的版本。L4T使用Unity桌面，虽然使得Ubuntu桌面看上去比较类似Windows和Mac，但是非常消耗资源，并且使用别扭。

实际上Ubuntu for ARM架构已经提供了最新的LTS版本 20.04 ，在每次登陆Jetson Nano主机的终端也会提示你 ``do-release-upgrade`` 升级到 20.04。那么究竟能否升级到最新版本依然可以支持运行 Nvidia 的Tegra处理器并且能够运行Nvidia提供的开发套件呢？

`Upgrading the NVIDIA Jetson Xavier NX to latest Ubuntu Focal Fossa (20.04) <https://medium.com/@carlosedp/upgrading-your-nvidia-jetson-xavier-nx-to-latest-ubuntu-focal-fossa-20-04-5e92ccc5a66>`_ 提供了一个参考:

- 升级命令::

   sudo do-release-upgrade -d -f DistUpgradeViewGtk3

- 升级以后原生的NVIDIA软件仓库被disable，需要重新激活::

   for f in /etc/apt/sources.list.d/*; do
     sudo sed -i 's/^\#\s*//' $f
   done

- Unity和Gnome 3冲突，会导致应用程序有重复菜单，所以删除掉unity::

   sudo apt purge unity

- 建议安装监控CPU和GPU使用量及温度，可以安装jtop::

   sudo -H pip3 install -U jetson-stats

参考
======

- `Upgrading the NVIDIA Jetson Xavier NX to latest Ubuntu Focal Fossa (20.04) <https://medium.com/@carlosedp/upgrading-your-nvidia-jetson-xavier-nx-to-latest-ubuntu-focal-fossa-20-04-5e92ccc5a66>`_
