.. _macos_shared_library:

=======================
macOS共享库
=======================

.. note::

   我还没有搞清楚macOS的底层库原理，这里仅记录汇总资料，有待后续学习...

我在尝试构建 :ref:`darwin-jail` 时候，惊奇地发现，打包提取的macOS运行环境居然高达 7.3G。这使我非常失望，如果构建一个jail环境，进而运行 :ref:`darwin-containers` 需要如此巨大的footprint，那么构建类似 :ref:`docker` / :ref:`kubernetes` 这样的容器运行环境性价比就很低。

联想到很久以前在支付宝工作时，为线上构建线上查询日志的chroot环境，在Linux上很容易通过 ``ldd`` 找出运行程序所依赖的库文件。那么，对于 :ref:`macos` ，是否有对应的工具呢？

``dyld``
============

``dyld`` 是 ``动态链接编辑器`` ( ``Dynamic Link Editor`` )，在 :ref:`macos` 和 :ref:`ios` 中负责在运行时加载和链接动态库。

``dyld`` 负责定位和加载动态框架(dynamic frameworks)，程序需要dyld来运行时和链接代码需要的库。 ``dyld`` 也负责在库里面管理符号 ``symbols`` (变量和函数的名字)并使符号对于程序可用。

在任何程序加载代码执行时， ``dyld`` 加载所有动态框架，所添加动态框架越多，则处理任务实践越长。

.. note::

   `emergetools.com <https://www.emergetools.com/>`_ 开发了一个 `Emerge's performance analysis <https://docs.emergetools.com/docs/performance-testing>`_ 可以分析程序加载使用的动态库框架，以及性能分析。非常类似 :ref:`flame_graph` ，可以辅助定位app应用性能问题。

   `Link fast: Improve build and launch times <https://developer.apple.com/videos/play/wwdc2022/110362/>`_ WWDC 2022的一个技术分享，介绍了链接静态库的原理以及苹果 ``ld64`` 的改进和如何结合参数来对程序进行瘦身和加速，以及持续改进 ``dyld`` 。

`dyld-shared-cache-extrator <https://github.com/keith/dyld-shared-cache-extractor>`_
---------------------------------------------------------------------------------------

从 macOS Big Sur 开始，Apple 不再随 macOS 一起提供系统库，而是提供所有内置动态库的生成缓存，并排除原始库。 `dyld-shared-cache-extrator <https://github.com/keith/dyld-shared-cache-extractor>`_ 工具可以从缓存中提取这些库以进行逆向工程。

在 :ref:`darwin-jail` 中抽取 ``/System/Volumes/Preboot/Cryptexes/OS/System/Library/dyld/dyld_shared_cache_*`` 到jail中的 ``/System/Library/dyld/`` 就是这个原理。

``dyld`` 库非常巨大，主要是包含了数百个库文件以及被应用加载的库的缓存(以加快启动)。 `CleanMyMac <https://macpaw.com/cleanmymac>`_ 工具提供了清理 ``dyld`` 库垃圾文件的功能(我理解是清理缓存以及删除程序后不再需要的库)。

显示加载的 ``dylibs``
========================

``dyld`` 提供了一个打印所有加载的 ``dylibs`` 的方法:

.. literalinclude:: macos_shared_library/dyld_print
   :caption: 输出所有 ``dyld``  加载的 ``dylibs``

检查 ``dyld.log``

另外 ``otool`` 可以显示程序使用的库文件，类似Linux下的 ``ld`` 。但是，这些库文件并没有实际存在于文件系统中，而是 ``dyld`` 加载的动态库(我感觉应该被加载到内存了) ，所以你实际是无法根据 ``otool`` 来打包文件的(文件不存在):

.. literalinclude:: macos_shared_library/otool
   :caption: 使用 ``otool`` 显示程序使用的库

输出的使用库文件并不是存在于文件系统中

.. literalinclude:: macos_shared_library/otool_output
   :caption: 使用 ``otool`` 显示程序使用的库输出案例


参考
======

- `How to find which shared library is missing? <https://apple.stackexchange.com/questions/378007/how-to-find-which-shared-library-is-missing>`_
- `‘ldd -r’ equivalent on macOS <https://stackoverflow.com/questions/55196053/ldd-r-equivalent-on-macos>`_
- `emergetools glossary: dyld <https://www.emergetools.com/glossary/dyld>`_
- `What is dyld folder in Library on Mac <https://macpaw.com/how-to/dyld-folder-mac>`_
