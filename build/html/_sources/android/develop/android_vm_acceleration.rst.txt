.. _android_vm_acceleration:

=====================
Android虚拟机加速
=====================

Android应用程序开发时，需要使用模拟器来运行App。如果开发环境是Linux平台，基于 :ref:`kvm` 的虚拟机加速可以帮助Android模拟器运行更快。

运行要求
=========

运行KVM需要特定的用户权限，所以需要确保Android开发者具有特定的权限。

.. note::

   安装KVM运行环境，请参考 :ref:`kvm_docker_in_studio`

- 安装完成KVM环境以后，需要验证系统是否已经加载了KVM模块::

   ls -lh /dev/kvm

- 运行 Android Stuidio 程序，然后启动 AVD Manager(使用如下方法之一):
  - 选择菜单 ``Tools > AVD Manager``
  - 点击工具条上的 ``AVD Manager`` 按钮

AVD包含硬件规则，系统镜像以及存储区域，皮肤等，建议为应用程序的每个潜在可能的支持系统创建一个AVD。

- 选择硬件profile：

.. figure:: ../../_static/android/startup/avd-manager-device.png
   :scale: 35

- 然后选择系统镜像，其中有推荐(Recommended)镜像列表，可以选择安装:

.. figure:: ../../_static/android/startup/avd-manager-system.png
   :scale: 35

这里需要先下载需要的镜像，然后才能进行下一步操作

- 最后选择AVD的特性，然后点击Finish结束:

.. figure:: ../../_static/android/startup/avd-manager-verify.png
   :scale: 35

.. note::

   如果没有提供KVM硬件加速，则在选择AVD时候会提示。

参考
=======

- `Configure VM acceleration on Linux <https://developer.android.com/studio/run/emulator-acceleration?utm_source=android-studio#vm-linux>`_
