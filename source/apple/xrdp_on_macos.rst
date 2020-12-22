.. _xrdp_on_macos:

======================
在macOS上运行xrdp服务
======================

通常macOS内建提供了VNC服务，所以可以通过VNC客户端访问macOS桌面。不过， neutrinolabs
 开发的 xrdp 是非常流行的跨 Linux/Unix 操作提供的RDP实现，特别适合混合Windows/macOS/Linux环境，并且性能更好，支持更为丰富的远程访问(如声音、远程共享目录)。

在Linux平台上我们比较容易设置xrdp服务( :ref:`jetson_remote` 设置比较挫折 )，不过，也可以在macOS平台实现同样的远程访问。

我准备尝试 xRDP on macOS来实现远程快速访问macOS桌面

参考
=====

- `xRDP on MacOS Mojave <https://ryancreecy.com/2019/10/29/xrdp-on-mac.html>`_
- `GigHub neutrinolabs/xrdp <https://github.com/neutrinolabs/xrdp/wiki>`_
