.. _darwin-containers_startup:

==============================
Darwin Containers快速起步
==============================

安装准备
===========

- 操作系统必须时 Catalina 或更新版本
- 关闭 `System Integrity Protection <https://developer.apple.com/documentation/security/disabling-and-enabling-system-integrity-protection>`_ ，因为SIP比允许 ``chroot`` :

System Integrity Protection (SIP) 时macOS的保护机制，拒绝非授权代码执行，系统只授权从App Store下载的应用运行，或者授权开发者认证的应用或者用户直接分发应用。默认不允许其他所有应用。

对于开发者，可能需要暂时关闭SIP以便安装和测试自己的代码。不过，在XCode中不需要关闭SIP来运行和调试apps，但可能需要关闭SIP才能安装系统扩展，例如DriveKit驱动。

关闭SIP
----------

- 重启计算机到 `Recovery mode <https://support.apple.com/en-us/HT201314>`_

  - 对于Apple Silicon主机，启动时按住电源开关不放就会提示 ``startup options``  ，选择 ``Options`` 
  - 对于Intel主机，启动时安装 ``Command (⌘) and R`` 进入 ``Recovery mode``

- 在Utilities菜单中启动 ``Terminal`` 应用

- 输入 ``csrutil disable`` 命令

- 重启主机


参考
========

- `GitHub: darwin-containers/homebrew-formula <https://github.com/darwin-containers/homebrew-formula#readme>`_
