.. _oh_my_zsh:

===========
Oh My Zsh
===========

zsh是兼容bash的shell，具备了更为丰富的插件以及强大的自动不全参数、文件名以及自定义功能。在Linux的不同发行版中都提供了zsh，并且macOS在最新版本中，默认采用了zsh替代了bash。

为了方便使用zsh， `开源Oh My Zsh框架 <https://github.com/ohmyzsh/ohmyzsh>`_ 提供了管理zsh配置的能力，提高了我们使用效率

准备
======

Oh My Zsh需要以下运行要求:

- Unix操作系统： macOS, Linux, BSD, Windows:WSL2或cygwin
- Zsh v4.3.9以上，建议5.0.8或更高版本
- 系统已经安装了curl或wget
- 已经安装了 git

安装
===========

- 通过curl安装::

   sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

.. note::

   访问 https://raw.githubusercontent.com 可能需要使用 :ref:`openconnect_vpn` 翻墙，痛...

使用
=======

插件
------

- 插件: 通过编辑 ``~/.zshrc`` 来激活插件(默认只激活了git)::

   plugins=(
     git
     bundler
     dotenv
     osx
     rake
     rbenv
     ruby
   )

theme
------

`Oh My Zsh支持不同themes <https://github.com/ohmyzsh/ohmyzsh/wiki/Themes>`_ ，如果你不知道如何选择，可以参考一下 `What's the best theme for Oh My Zsh? 投票 <https://www.slant.co/topics/7553/~theme-for-oh-my-zsh>`_ 选择票数最高的几项进行尝试。

.. note::

   我在尝试了不同themes之后，还是回归到Oh My Zsh默认的theme ``robbyrussell`` ，原因是:

   - 大多数themes都需要安装字体，虽然比较炫酷，但是得到的收益有限
   - 我的日常工作都是通过 ``screen`` 和 :ref:`tmux` 来完成的，为的是确保随时能够回到中断的工作界面，但是附加字体不能显示

Powerlevel10k
~~~~~~~~~~~~~~~

使用 `Powerlevel10k <https://github.com/romkatv/powerlevel10k>`_

- 安装Powerlevel10k方法是针对不同plugin manager的，对于 Oh My Zsh 使用以下命令::

   git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k

- 修改 ``~/.zshrc`` ::

   ZSH_THEME="powerlevel10k/powerlevel10k"

- macOS平台如果使用iTerm2 或者 Termux ，则使用 ``p10k configure`` 可以只需要简单回答 ``Yes`` 就可以安装 Meslo Nerd Font，然后一系列交互问答就可以完成配置

如果手工安装字体，则在 iTerm2 中配置 ``Perferences -> Profiles -> Text`` 然后设置字体 ``MesloLGS NF``

- 其他平台需要针对不同的Terminal Emulator来安装字体，详见 `romkatv/powerlevel10k <https://github.com/romkatv/powerlevel10k>`_

:ref:`kali_linux` 默认QTerminal对Powerlevel10k支持极佳，无需再附加安装字体。

agnoster
~~~~~~~~~~

在 Oh My Zsh 官方github推荐的 ``agnoster`` 是一个非常简洁明快的theme，只需要调整 ``~/.zshrc`` ::

   ZSH_THEME="agnoster"

- 然后和大多数themes一样，需要安装 `Powerline Fonts <https://github.com/powerline/fonts>`_ 实现渲染(否则图标无法显示)::

   git clone https://github.com/powerline/fonts.git --depth=1
   cd fonts
   ./install.sh

- 在 macOS 上字体被安装到 ``/Users/huatai/Library/Fonts`` 目录下。同样，需要在终端模拟器中设置字体，例如可以设置为 ``DejaVu Sans Mono for Powerline`` ，这样就可以正常使用

不过，没有像上文 ``PowerLevel10K`` 那样有一个交互配置过程(可以细调)

.. note::

   推荐在编码工作环境，使用 `Solarized Dark colorscheme <https://ethanschoonover.com/solarized/>`_ ，字体清晰色调柔和。我在 :ref:`kali_linux` 的桌面默认使用的 QTerminal 风格也是非常简约美观，不用调整也非常舒适。

参考
=====

- `Linux 效率神器——开始使用 Zsh <https://zhuanlan.zhihu.com/p/63585679>`_
- `zsh快捷操作 <https://www.jianshu.com/p/44e8deab1839>`_
- `bash/zsh 快捷键 <https://blog.csdn.net/C_SESER/article/details/78108661>`_
- `Oh My Zsh + PowerLevel10k = terminal <https://dev.to/abdfnx/oh-my-zsh-powerlevel10k-cool-terminal-1no0>`_
- `Make your terminal beautiful and fast with ZSH shell and PowerLevel10K <https://medium.com/@shivam1/make-your-terminal-beautiful-and-fast-with-zsh-shell-and-powerlevel10k-6484461c6efb>`_
- `romkatv/powerlevel10k <https://github.com/romkatv/powerlevel10k>`_
