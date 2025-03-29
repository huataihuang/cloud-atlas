.. _git-lfs:

========================
Git Large File Storage
========================

在 :ref:`build_lineageos_20_pixel_4` ，编译LineageOS的文档中提出需要使用 `lfs or Large File Storage <https://git-lfs.com/>`_ ，原因是一些repos配置使用了 ``git-lfs`` 。

对于每个使用 ``git-lfs`` 的用户账号，都需要执行一次:

.. literalinclude:: git-lfs/git_lfs_install
   :caption: 每个使用 ``Git Large File Storage`` 的用户账号下需要执行 git lfs 初始化

但是我第一次执行的时候报错:

.. literalinclude:: git-lfs/git_lfs_install_err
   :caption:  执行 ``git lfs install`` 报错

当时我以为可以忽略这个问题，在后续的 ``repo init`` 时候去掉了 ``--git-lfs`` 参数。但是实际上这个参数非常重要，在编译时就遇到了无法同步仓库的报错:

.. literalinclude:: ../../android/build/build_lineageos_20_pixel_4/webview.apk_invalid_file
   :caption: ``webview.apk: Invalid file``
   :emphasize-lines: 5

``external/chromium-webview/prebuilt/arm64/webview.apk`` 文件:

.. literalinclude:: ../../android/build/build_lineageos_20_pixel_4/webview.apk
   :caption: ``webview.apk``
   :emphasize-lines: 1

这说明必须支持 ``git-lfs``

安装
======

实际安装非常方便，Ubuntu提供了 ``git-lfs`` 软件包:

.. literalinclude:: git-lfs/apt_install_git-lfs
   :caption: 在Ubuntu上安装git-lfs

安装完成后，在用户目录下再次执行:

.. literalinclude:: git-lfs/git_lfs_install
   :caption: 每个使用 ``Git Large File Storage`` 的用户账号下需要执行 git lfs 初始化

此时输出信息正常:

.. literalinclude:: git-lfs/git_lfs_install_output
   :caption: 执行 ``git lfs install`` 正确的输出

参考
======

- `git: 'lfs' is not a git command unclear <https://stackoverflow.com/questions/48734119/git-lfs-is-not-a-git-command-unclear>`_
