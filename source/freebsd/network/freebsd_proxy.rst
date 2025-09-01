.. _freebsd_proxy:

=========================
FreeBSD代理配置
=========================

我 :ref:`freebsd_on_intel_mac` 之后执行 :ref:`freebsd_update` 以及安装 :ref:`freebsd_nvidia-driver` 都遇到一个非常麻烦都事: 访问FreeBSD软件仓库的网速实在太慢了，几乎无法完成系列软件下载工作。

这个问题实际上并不是FreeBSD软件仓库的网络问题，应该是GFW的干扰或者是本地电信运营商网络的阻塞。我检查发现，实际上只要通过 :ref:`ssh` 转发访问，就能够获得极快的下载速度。所以，结合 :ref:`squid_socks_peer` (具体实现 :ref:`apt_proxy_arch` ) 可以加速FreeBSD的更新。也就是说，需要配置FreeBSD主机直接使用现有已经部署好的代理服务器:

在FreeBSD配置系统级别代理方法和Linux相似，是通过环境变量完成。由于FreeBSD常用的SHELL有多种，配置方法略有不同

- 对于 ``csh`` 或  ``tcsh`` ，配置 ``/etc/csh.cshrc`` ::

   setenv HTTP_PROXY http://192.168.7.9:3128
   setenv HTTPS_PROXY https://192.168.7.9:3128

- 对于 ``sh`` ，配置 ``/etc/profile`` / ``~/.shrc`` ::

   export HTTP_PROXY=http://192.168.7.9:3128
   export HTTPS_PROXY=https://192.168.7.9:3128

参考
=======

- `FreeBSD 101 hacks: Configure proxy <https://nanxiao.gitbooks.io/freebsd-101-hacks/content/posts/configure-proxy.html>`_
- `How to Configure Proxy Settings for `pkg` Downloads on FreeBSD Operating System <https://www.siberoloji.com/how-to-configure-proxy-settings-for-pkg-downloads-on-freebsd-operating-system/>`_
- `Update FreeBSD Using Proxy Server (csup / portsnap proxy update) <https://www.cyberciti.biz/faq/updating-freebsd-source-tree-via-proxyserver/>`_ 提到了使用 ``prtunnel`` 来构建一个 tunnel，这样即使软件不支持代理也可以通过 ``prtunnel`` 实现网络流量走代理。不过这个方法我还没有实践，记录备用。
