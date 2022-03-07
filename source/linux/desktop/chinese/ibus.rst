.. _ibus:

============
ibus输入法
============

Ubuntu安装
===========

- 安装::

   sudo apt install ibus ibus-libpinyin

配置ibus
===========

- 修改 ``.xinitrc`` 添加:

.. literalinclude:: ibus/xinitrc_base
   :language: bash
   :caption: ibus基本配置 ~/.xinitrc

- 对于字符终端中输入 ``startx`` 命令启动，还需要添加一行启动 ``ibus`` 服务的命令::

   ibus-daemon -drx

- 最后再加上需要启动的图形桌面命令，例如使用 :ref:`suckless` ::

   exec dwm

- 登陆系统后，可以使用 ``ibus-setup`` 进行设置

KDE环境
=========

- 在 ``Kubuntu`` 发行版安装后(选择了 ``china`` 时区)则默认安装中文字体以及 ``ibus`` 输入框架，所以不需要单独安装

- 但是需要安装中文输入法::

   sudo apt install ibus-pinyin

我在 :ref:`kubuntu` 中使用KDE环境，在设置中文输入中比上文要曲折一些，因为采用上文方式虽然能够启动 ``ibus`` 并切换中英文，但是我发现在应用程序中输入中文时实际显示的还是英文。

解决的方法似乎要遵循KDE图形环境的IM配置方法:

- 启动 ``Settings >> Input Method`` ，打开 ``Input Method`` 对话窗口:

此时提示当前 ``Input Method Configuration`` ::

   Current configuration for the input method:
    * Active configuration: ibus (normally missing)
    * Normal automatic choice: ibus (normally ibus or fcitx or uim)
    * Override rule: zh_CN,fcitx:zh_TW,fcitx:zh_HK,fcitx:zh_SG,fcitx:ja_JP,fcitx:ko_KR,fcitx:vi_VN,fcitx
    * Current override choice:  (en_US)
    * Current automatic choice: ibus
    * Number of valid choices: 2 (normally 1)
   The override rule is defined in /etc/default/im-config.
   The configuration set by im-config is activated by re-starting X.
   Explicit selection is not required to enable the automatic configuration if the active one is default/auto/cjkv/missing.
     Available input methods: ibus xim
   Unless you really need them all, please make sure to install only one input method tool.

- 点击 ``OK`` 之后提示::

   Do you explicitly select the user configuration?
   
    * Select NO, if you do not wish to update it. (recommended)
    * Select YES, if you wish to update it.

此时点击 ``Yes`` 按钮，表示更新

- 此时会有一个选择列表提示 ``Select user configuration. The user configuration supersedes the system one.`` ，选择列表如下::

   ...
   activate Intelligent Input Bus(IBus)@
   ...

选择上述这行激活 ``IBus`` 

- (可选，实际我没有执行) 然后可能需要移除 ``/etc/environment``` 和 ``~/.pam_environment`` 中有关输入法变量。Input Method设置了这些变量并设置登录时启动 ``ibus-daemon`` 

- 重启系统

- 再次登录KDE桌面后，运行 ``Settings >> IBus Perferences`` 并添加 ``Intelligent Pinyin`` 输入法，并(可选)配置激活快捷键就可以输入中文。

参考
======

- `Gentoo IBus <https://wiki.gentoo.org/wiki/IBus>`_
- `arch linux IBus <https://wiki.archlinux.org/title/IBus>`_
- `i3-wm gaps can't switch ibus method <https://www.reddit.com/r/i3wm/comments/jct4ti/i3wm_gaps_cant_switch_ibus_method/>`_
- `Getting Ibus working with tiling window manager <https://unix.stackexchange.com/questions/277692/getting-ibus-working-with-tiling-window-manager>`_
- `Chinese input not working Kubuntu 20.04 <https://askubuntu.com/questions/1299866/chinese-input-not-working-kubuntu-20-04>`_
