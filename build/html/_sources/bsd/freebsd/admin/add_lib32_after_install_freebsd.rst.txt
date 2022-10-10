.. _add_lib32_after_install_freebsd:

===========================
FreeBSD安装完成后添加lib32
===========================

我在 :ref:`freebsd_on_intel_mac` 没有选择 ``lib32`` 支持，原本想运行一个纯粹的64位系统，但是没有想到 :ref:`freebsd_wine` 依赖32位环境运行，所以在完成FreeBSD系统安装后，再添加 ``lib32`` 支持。

- 根据现有系统的发行版来安装，所以需要先检查当前FreeBSD版本::

   uname -r

显示版本::

   13.1-RELEASE-p2

- 从 `FreeBSD releases ftp <https://download.freebsd.org/ftp/releases/>`_ 找到对应版本和架构的 `lib32.txz <https://download.freebsd.org/ftp/releases/amd64/13.1-RELEASE/lib32.txz>`_ 

- 将下载压缩包解压缩到根目录::

   sudo tar -C / -xpf lib32.txz

这个解压缩后的文件依然可以更新

- 执行 :ref:`` ::

   sudo freebsd-update fetch install

此时可以看到刚才安装的 ``lib32`` 得到了更新::

   ...
   Inspecting system... done.
   Preparing to download files... done.
   Fetching 8 patches..... done.
   Applying patches... done.
   The following files will be updated as part of updating to
   13.1-RELEASE-p2:
   /usr/lib32/lib9p.a
   /usr/lib32/lib9p.so.1
   /usr/lib32/lib9p_p.a
   /usr/lib32/libpam.a
   /usr/lib32/libz.a
   /usr/lib32/libz.so.6
   /usr/lib32/libz_p.a
   /usr/lib32/pam_exec.so.6
   Creating snapshot of existing boot environment... done.
   ...

参考
=====

- `How to add lib32 after installing FreeBSD? <https://forums.freebsd.org/threads/how-to-add-lib32-after-installing-freebsd.67512/>`_
