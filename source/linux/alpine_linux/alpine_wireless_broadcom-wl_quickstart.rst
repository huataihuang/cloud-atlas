.. _alpine_wireless_broadcom-wl_quickstart:

===========================================
快速设置Alpine Linux无线: ``broadcom-wl``
===========================================

在 Linux 内核升级到 ``6.12.x`` 后，Broadcom 的官方 ``wl`` 源代码（ :ref:`alpine_wireless_broadcom-wl` ）会因为内核 API 的巨大变动（如 ``strlcpy`` 被移除、 ``net_device`` 结构体变化等）而导致编译彻底失败。

MacBook Air 2014 (BCM4360 芯片)，在 Alpine Linux 上有以下几种快速解决办法

方法一: 使用开源驱动 ``brcmfmac`` (推荐)
==========================================

BCM4360 (SDIO/PCIe) 其实已经由内核内置的开源驱动 ``brcmfmac`` 提供了非常好的支持，这样就不再需要忍受闭源 ``wl`` 驱动的编译之苦(之前我查询资料饶了很多弯路)

- 安装固件包:

.. literalinclude:: alpine_wireless_broadcom-wl_quickstart/firmware-brcm
   :caption: 固件

- 清理旧的 ``wl`` 模块:

.. literalinclude:: alpine_wireless_broadcom-wl_quickstart/remove_module
   :caption: 清理 ``wl`` 模块

- 加载开源模块 ``brcmfmac`` :

.. literalinclude:: alpine_wireless_broadcom-wl_quickstart/modrpobe
   :caption: 加载 ``brcmfmac``


方法二: 使用经过社区修补的 ``wl`` 源码
=============================================

目前社区维护最好的版本是 `broadcom-wl-dkms <https://github.com/michaelaquilina/broadcom-wl-dkms>`_ ，它包含了支持 6.12+ 内核的补丁

- 安装构建工具:

.. literalinclude:: alpine_wireless_broadcom-wl_quickstart/apk_add_dev
   :caption: 安装编译工具

- 下载补丁过的源代码:

.. literalinclude:: alpine_wireless_broadcom-wl_quickstart/source
   :caption: 获取补丁过的源代码

模块冲突预防
==============

如果 ``brcmfmac`` 和 ``wl`` 同时存在，系统可能会混乱。务必拉黑不用的驱动： 编辑 ``/etc/modprobe.d/blacklist.conf`` :

.. literalinclude:: alpine_wireless_broadcom-wl_quickstart/blacklist.conf
   :caption: 设置 /etc/modprobe.d/blacklist.conf
