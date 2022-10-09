.. _freebsd_proxy:

=========================
FreeBSD代理配置
=========================

我 :ref:`freebsd_on_intel_mac` 之后执行 :ref:`freebsd_update` 以及安装 :ref:`freebsd_nvidia-driver` 都遇到一个非常麻烦都事: 访问FreeBSD软件仓库的网速实在太慢了，几乎无法完成系列软件下载工作。

这个问题实际上并不是FreeBSD软件仓库的网络问题，应该是GFW的干扰或者是本地电信运营商网络的阻塞。我检查发现，实际上只要通过 :ref:`ssh` 转发访问，就能够获得极快的下载速度。所以，结合 

参考
=======

- `FreeBSD 101 hacks: Configure proxy <https://nanxiao.gitbooks.io/freebsd-101-hacks/content/posts/configure-proxy.html>`_
