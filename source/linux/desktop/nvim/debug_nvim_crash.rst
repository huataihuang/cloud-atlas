.. _debug_nvim_crash:

=====================
排查nvim异常退出方法
=====================

我在 :ref:`lazy.nvim_docker` 遇到一个非常奇怪的问题，就是开始使用nvim，刚打开过了几秒钟就自动退出，也没有提示任何错误。

- 检查Neovim退出时状态码:

.. literalinclude:: debug_nvim_crash/echo_code
   :caption: 检查退出时

返回码显示是 ``132``

Linux 的信号退出码计算公式是 **128 + 信号编号** 。 **132 - 128 = 4** ，而内核信号 ``4`` 正好就是 ``SIGILL`` 。

``SIGILL`` 是Linux的一个进程终止信号，缩写自英文 ``illegal instruction`` ( **非法指令** )。当一个进程尝试执行以下操作时，CPU无法识别该指令并向进程发送此信号:

- **损坏的二进制文件** : 程序文件本身损坏或由于传输错误导致指令格式错乱
- **架构不兼容** : 运行为特定CPU(如ARM或x86)编译的二进制文件，而当前硬件不支持该指令集
- **执行了非代码数据** : 代码段被意外修改，或由于栈溢出、指针越界，导致程序将普通数据或内存地址误当作机器指令来执行
- **特权指令异常** : 在普通用户态下执行了仅内核态允许执行的指令

由于我是在 :ref:`oclp_macos` 环境下使用 :ref:`colima` ，并且自己构建了 :ref:`colima_images` 的 :ref:`debian` 镜像，涉及的链路很复杂，需要进一步排查。

**究竟是nvim存在问题还是(第三方)插件问题**

- 首先需要确认是不是 ``nvim`` 自身程序坏了，所以执行以下命令，不加载任何LazyVim配置和插件，干净启动:

.. literalinclude:: debug_nvim_crash/nvim_none
   :caption: 不加载任何插件干净启动nvim

经过简单测试，发现没有出现闪退现象，这说明至少neovim自身是好的，怀疑对象转为配置或插件

- 通过clean方式启动nvim，这样就能加载nvim的基础内置行为，但不加载任何第三方自建插件:

.. literalinclude:: debug_nvim_crash/nvim_clean
   :caption: 不加载第三方插件启动nvim

经过验证，依然没有出现闪退，那么证明nvim的基本配置和内置功能都正常，怀疑进一步缩小到第三方插件

- (这步没有执行)另外一个可能是LSP语言服务器导致的崩溃，所以需要检查 ``:LspLog`` 看看是否存在日志报错。或者检查 ``~/.local/state/nvim/log`` 全局日志 

- 由于neovim闪退太快，所以需要通过Linux标准错误重定向和系统核心日志来确定最后一个的报错:

.. literalinclude:: debug_nvim_crash/nvim_log
   :caption: 记录crash日志方式启动nvim

我在nvim异常退出后检查 ``crash.log`` 发现有如下错误:

.. literalinclude:: debug_nvim_crash/nvim_log_output
   :caption: crash日志错误
   :emphasize-lines: 6,7

看来就是在访问 ``/home/admin/.local/state/nvim/shada/main.shada`` 触发了异常。这个 ``main.shada`` 是上一次编辑文件留下的历史记录和光标位置，但是为何处理这个 **目录** 会导致闪退？

Colima cpuType
================

我忽然想到我的一个特殊操作，我的 :ref:`colima_config` 采用了一个非常特殊的 :ref:`colima_mounttype_9p` ，为了避免OCLP伪装的内存页表和QEMU冲突，特别将 ``cpuType`` 从默认的 ``cpuType: host`` 修订为 ``cpuType: qemu64`` 。但是为了能够继续使用一些CPU硬件特性，所以将 ``cpuType`` 附加了一些指令集特性:

.. literalinclude:: ../../../container/colima/colima_mounttype_9p/default_i7.yaml
   :caption: 设置qemu64作为CPU类型，针对i7优化

这样在Colima VM中看到的CPU是一个特殊规格的 ``qemu64`` 处理器。由于gcc编译时默认会自动检测CPU架构和类型，并针对硬件做加速优化。这就有可能触发了误判( ``gcc -march=native`` )，由于指令集中包含了 ``+avx`` 和 ``+avx2`` ，可能会导致误判并编译出越界的硬件加速码。

.. note::

   实际上我在 :ref:`colima_images` 中Dockerfile中使用了 :ref:`mise` 来安装开发软件环境，这导致很多软件包可能采用了错误的优化编译

修正
-------

- 比较简单的修正是在环境变量中使用比较通用的编译参数:

.. literalinclude:: debug_nvim_crash/cflags_normal
   :caption: 比较通用的编译参数，使用x86-64基础指令集

这样对于Dockerfile，则使用 ``ENV`` 参数命令:

.. literalinclude:: debug_nvim_crash/cflags_normal_dockerfile
   :caption: 在Dockerfile中配置编译参数

- 然后重新编译nvim插件:

.. literalinclude:: debug_nvim_crash/rebuild_nvim
   :caption: 重新编译

.. note::

   经过验证，确实解决了nvim闪退问题。那么意味着之前没有正确配置的 :ref:`colima_images` 需要重新再构建一遍，以免编译程序中包含了错误的CPU指令集再导致指令错误。

进一步优化
-------------

按照之前 :ref:`colima_mounttype_9p` 的 ``cpuType`` ，其中手工拼接的参数（SSE4.2 + AVX + AVX2 + POPCNT），恰好完整覆盖了现代Linux社区为解决虚拟化兼容问题，定义的通用的 **微架构级别（Microarchitecture Levels）** ``x86-64-v3`` ，所以上述编译参数可以在 ``~/.bashrc`` 或 ``/etc/profile.d/compiler.sh`` 定义:

.. literalinclude:: debug_nvim_crash/compiler.sh
   :caption: 自定义cpuType对应的微架构级别 ``x86-64-v3``

如果发现某些极度激进的编译器(或者旧版本GCC)在 ``-march=x86-64-v3`` 下依然会使用 ``BMI2`` 或 ``FMA`` 指令集，则可以直接使用最高优先级的特征掩码(Feature Masking)明确指定:

.. literalinclude:: debug_nvim_crash/compiler_feature.sh
   :caption: 明确指定编译参数

这里 ``-mno-bmi -mno-bmi2 -mno-fma`` 表示即使GCC推测硬件支持 BMI 等指令集，也绝对禁止生成这些指令。

参考
======

- gemini
