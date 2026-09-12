.. _alpine_suspend:

==========================
Alpine Linux挂起(suspend)
==========================

在 Alpine Linux (OpenRC) 极简环境下，由于没有 GNOME/KDE 或 systemd-logind 那套重型守护进程，合盖（Lid Switch）事件通常由 ACPI 守护进程（ ``acpid`` ） 捕获并触发挂起脚本。

安装与启动 acpid
===================

.. literalinclude:: alpine_suspend/install
   :caption: 安装acpid并设置启动

配置合盖触发挂起脚本
======================

``acpid`` 会监听 ``/etc/apci/events/`` 目录下的事件定义

- 创建文件 ``/etc/acpi/events/lid`` :

.. literalinclude:: alpine_suspend/lid
   :caption: ``/etc/acpi/events/lid``

- 挂起响应脚本 ``/etc/acpi/lid.sh`` :

.. literalinclude:: alpine_suspend/lid.sh
   :caption: 判断屏幕状态，仅在合上时触发挂起

- 赋予执行权限并重载服务:

.. literalinclude:: alpine_suspend/acpid_lid
   :caption: 赋予执行权限并重载acpid服务

参考
=======

- gemini
