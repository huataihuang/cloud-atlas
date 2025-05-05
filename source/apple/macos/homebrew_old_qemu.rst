.. _homebrew_old_qemu:

=========================
Homebrew安装旧版本qemu
=========================

.. note::

   经过不同版本验证，已测试成功:

   - macOS Big Sur 11.7.10 能够编译安装 ``qemu-9.0.2``
   - 更新的版本需要XCode 15无法在 :ref:`mbp15_late_2013` 所支持的最高 macOS Big Sur 11.7.10 上编译安装

由于 :ref:`homebrew_qemu` 在旧版本macOS上失败(macOS版本过低不支持qemu 10)，我尝试安装旧版本qemu

- 创建本地tap(按照需要提取的软件包名命令git仓库,这里是 :ref:`qemu` ):

.. literalinclude:: homebrew_old_qemu/tap-new
   :caption: 创建本地tap，实际上就是初始化一个本地git仓库

此时输出:

.. literalinclude:: homebrew_old_qemu/tap-new_output
   :caption: 创建本地tap输出信息
   :emphasize-lines: 1,7,8

- 获取homebrew的formulea:

.. literalinclude:: homebrew_old_qemu/tap
   :caption: 获取本地formulea

.. note::

   我尝试了:

   - 9.2.3 版本，依然要求Clang 15
   - 9.2.1 版本，SHA值和配置不一致，放弃
   - 9.1.1 版本，编译失败
   - 9.0.2 版本，编译安装成功

输出:

.. literalinclude:: homebrew_old_qemu/tap_output
   :caption: 获取本地formulea

- 取出( ``extract`` )指定版本的软件配置(这里是 :ref:`qemu` ) 

.. literalinclude:: homebrew_old_qemu/extract
   :caption: 取出指定版本的软件配置

输出:

.. literalinclude:: homebrew_old_qemu/extract_output
   :caption: 提取出9.0.2版本的qemu
   :emphasize-lines: 3

- 现在就可以按照常规方式进行安装:

.. literalinclude:: homebrew_old_qemu/install
   :caption: 安装指定版本qemu

出现报错:

.. literalinclude:: homebrew_old_qemu/install_output
   :emphasize-lines: 35,36

这里的报错原因是已知的，见 :ref:`homebrew_snappy` ，需要手工修订 :ref:`homebrew_formulae` 来手工安装 ``snappy-1.2.2`` (已完成),并且修订 ``qemu`` 依赖。所以按照前面 ``extract`` 出来的指定 ``qemu@9.2.3.rb`` 配置文件:

.. literalinclude:: homebrew_old_qemu/qemu_9.1.2
   :caption: 编辑本地提取出的qemu文件

然后再次安装 ``qemu@9.1.2``

- 9.1.2 版本，编译存在python模块 ``tomli`` 报错:

.. literalinclude:: homebrew_old_qemu/tomli
   :caption: 编译9.1.2版本提示python模块错误
   :emphasize-lines: 15

我尝试手工创建 :ref:`virtualenv` ，然后手工安装发现原来是证书错误导致无法下载:

.. literalinclude:: homebrew_old_qemu/tomli_cert_error
   :caption: 证书错误导致无法下载tomli

这个问题参考 `pip is configured with locations that require TLS/SSL, however the ssl module in Python is not available <https://stackoverflow.com/questions/45954528/pip-is-configured-with-locations-that-require-tls-ssl-however-the-ssl-module-in>`_ ，我感觉是先安装的python，然后手工完成 :ref:`homebrew_openssl` ，看起来需要重新安装一次python(获得最新的openssl支持)，然后再重新构建 :ref:`virtualenv` :

.. literalinclude:: homebrew_old_qemu/reinstall_python
   :caption: 重新安装python3

果然，在 :ref:`homebrew_openssl` 之后重新安装一遍 Python ，就能够正常在 :ref:`virtualenv` 中使用 ``pip`` 安装 ``tomli``  模块了

不过，很奇怪，我发现虽然默认使用的是homebrew的 python 3.13.3(路径优先)，但是安装 ``qemu`` 的脚本还是找到 ``/usr/bin/python3`` ，也就是macOS操纵系统自带的 python 3.8.9 。而且这个 python 3.8.9 创建 ``pyvenv`` 环境还是无法安装 ``tomli`` 。非常奇怪，我手工使用macOS操作系统自带的 python 3.8.9 来构建virtualenv，安装 ``tomli`` 明明是成功的。

我使用 ``/usr/bin/pip3`` 在操作系统 **全局** 安装 ``tomli`` (也就是不创建 :ref:`virtualenv` ，直接安装模块):

.. literalinclude:: homebrew_old_qemu/pip_install_tomli
   :caption: 使用 ``/usr/bin/pip3`` 在操作系统 **全局** 安装 ``tomli``

**OK** 这一关过了(不再报 ``tomli`` 模块缺失，也确认 ``9.1.2`` 版本不再强制要求 clang 15)

编译错误
=========

``qemu-9.1.2`` 编译错误:

.. literalinclude:: homebrew_old_qemu/dump_error
   :caption: 编译错误dump.c

没有找到解决方法，所以继续回退一个版本:

  - ``qemu-9.1.1`` 同样编译错误
  - ``qemu-9.0.2`` 则编译成功

参考
=====

- `How to install an old package version with brew <https://cmichel.medium.com/how-to-install-an-old-package-version-with-brew-cc1c567dd088>`_
- `Installing Old Versions from Homebrew (2024) <https://medium.com/@franz.bender/installing-old-versions-from-homebrew-2024-30005ed8f97a>`_
