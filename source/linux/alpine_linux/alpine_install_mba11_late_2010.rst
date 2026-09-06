.. _alpine_install_mba11_late_2010:

===========================================
MacBook Air 11" Late 2010安装Alpine Linux
===========================================

我在尝试复活 :ref:`mavericks_mba11_late_2010` 还是遇到系统陈旧存在效率低下的问题。但是我不甘心，因为 :ref:`mba11_late_2010` 实在太小巧了，而且能够用十六年前复古的设备，想想还是很酷的。

想到我一直考虑采用 :ref:`sunshine` / :ref:`moonlight` 以及 :ref:`rdp` 远程使用 :ref:`hackintosh` ，我忽然想到最轻量级的 :ref:`alpine_linux` 或许可以帮助我实现一个非常巧妙的移动工作的方案:

- Alpine Linux作为始终持续开发和进步的Linux发行版，能够用最先进的技术来充分发掘我这台古老设备的能力: 没错， :ref:`moonlight-embedded` 能够用服务器端部署端 :ref:`linux` , :ref:`macos` 和 :ref:`windows` 来运行高负载极度复杂端软件，相当于我通过类似 ``chromebook`` 调用超级计算机或集群。
- 本地只运行轻量级的 :ref:`vim` 配合纯C+ :ref:`python` 开发，以及良好配置的文本编辑能力，让我能够随时编辑 :ref:`devops_docs` 并通过CI/CD推送自动部署

准备工作
==========

.. note::

   这次启动安装U盘比我预期的要折腾

我首先用 ``dd`` 命令将下载的alpine linux ISO文件写入U盘:

.. literalinclude:: alpine_install_mba11_late_2010/dd
   :caption: 制作启动U盘

但是，出乎我的意料，很久以前的这种制作启动Linux U盘的经验，现在居然失效了: 启动 :ref:`mba11_late_2010` 时按住 ``option`` 键选择启动U盘，现在居然毫无反应，只看到屏幕上一片灰色。

我以为是U盘写入时错误，但是发现重新制作U盘启动依然是相同情况。而且，我发现U盘是好的，这个Alpine Linux启动U盘在 :ref:`thinkpad_x220` 使用完全正常，能够启动Alpine Linux安装。

gemini提示: Alpine Linux 官方 ISO 在部分老款 Mac 的 EFI 引导上有一个 Known Issue（已知问题）：Alpine 默认的 ISO 采用了 iso-hybrid 格式，有时 Mac 固件会将其误识别为光盘驱动，导致卡在初始化阶段。

解决的方法是采用 :ref:`ventoy` ，Ventoy 对老旧 Mac 固件的 EFI 兼容性比原始 dd 模式要强得多。

在使用 Ventoy 之前我也尝试了手动解压方法: 直接将 U 盘格式化为 FAT32，然后把 ISO 里的内容解压进去

.. literalinclude:: alpine_install_mba11_late_2010/tar
   :caption: 通过 tar 解压ISO文件到U盘

不过实践发现还是解决不了启动问题，虽然屏幕不再灰色，而且Macbook Air的BIOS也将这个U盘视为一个可启动磁盘，但是启动后Alpine Linux报错显示无法挂载分区。看来启动问题是可以解决，但是Linux安装程序预设的启动分区存在问题。

我又尝试 :ref:`ventoy` 来解决老旧Mac系统启动Linux安装ISO镜像转启动U盘问题，没有想到之前还能启动的ventoy居然也无法启动了: 要么是灰色屏幕，要么嵌套在rEFInd里面作为一个分区来启动，但是依然在mount media卡住。

现在问题回归到 ``rEFInd`` ，看来这个修订EFI到软件触发了 :ref:`mba11_late_2010` 无法按照常规方式启动用ISO转换到U盘。我尝试删除 ``rEFInd`` :

.. literalinclude:: alpine_install_mba11_late_2010/uninstall_refind
   :caption: 删除rEFInd

不过，删除rEFInd并没有解决 ``dd`` 直接制作的U盘启动"灰色屏幕"卡住问题，所以我结合删除rEFInd和 :ref:`ventoy` 来尝试启动U盘: 即先回复默认的Mac标准启动，然后用 :ref:`ventoy` 启动U盘来启动Alpine Linux的ISO镜像。然而，这条路也失败了。

那么，根据上述排查，我推测:

- 我的 :ref:`mba11_late_2010` 太古老了，EFI协议应该是早期版本，无法处理现代Linux发行版的 ``iso-hybrid`` 格式启动，甚至也无法启动 :ref:`ventoy` 现在提供的启动ISO镜像
- 我在去年的时候，在 :ref:`mba13_early_2014` 是成功完成  :ref:`alpine_install` 的，通过U盘启动完全没有问题。但是今天，这个 Alpine Linux 3.24.1 的安装U盘也无法在 :ref:`mba13_early_2014` 启动。

我考虑用一个旧版本Alpine Linux镜像ISO来启动安装，然后通过滚动升级来追平最新版本。另一种可能是真实地刻录一张CD光盘来进行安装。

i3.14.x release
-------------------

考虑到很久很久以前曾经在 :ref:`alpine_install` 使用过 ``3.14.1`` ，这个release是2021年发布的，所以我想尝试一下:

.. literalinclude:: alpine_install_mba11_late_2010/dd_3.14
   :caption: 制作3.14系列启动U盘

果然，有进展: 回退到2021年发布的 ``3.14.9`` ISO制作的启动U盘，就能够成功引导启动 :ref:`mba13_early_2014` ，但是很不幸，2010年的 :ref:`mba11_late_2010` 还是无法启动。

这说明回滚早期Alpine Linux发行版ISO是有效果的，苹果的各代Macbook看来确实支持的是不同格式的Linux ``iso-hybrid`` ，按照这个思路，采用更早发行版ISO应该能够启动2010年的古早 :ref:`mba11_late_2010` 。

考虑到2021年发行版ISO能够在2014年的Macbook工作，这种兼容支持一般都有几年持续。所以我可以尝试用2015年的v3.2版本Alpine Linux ISO来启动 :ref:`mba11_late_2010` - 这里选择了 ``3.2.3`` :

.. literalinclude:: alpine_install_mba11_late_2010/dd_3.2
   :caption: 制作3.2系列启动U盘

但是，我发现回滚到2015年的ISO之后，已经不再是 ``iso-hybrid`` 格式了，而是纯粹的CD－ROM镜像格式。直接用 ``dd`` 命令写入U盘是无法启动的，在OS X 10.9中，这个直接dd生成的U盘显示就是一个CDROM，但是无法在开机时使用 ``option`` 选择启动。

那么，我想，是不是回过去用我在 :ref:`archlinux_on_mbp` (当时是2019年)的方法(先把iso转换成dmg再写入U盘)来制作启动U盘:

.. literalinclude:: alpine_install_mba11_late_2010/dd_dmg
   :caption: 先把.iso转为.dmg再dd写入U盘
