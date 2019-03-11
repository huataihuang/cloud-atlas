.. _ubuntu_desktop:

===================
Ubuntu Desktop
===================

Desktop软件
=============

- 安装了Desktop版本之后，有一些必要软件推荐安装::

   sudo apt install screen openssh-server nmon net-tools

- 由于我只是把MacBook Pro上安装的Xubuntu的Xfce4桌面作为第二块屏幕（主要桌面工作在另一台MacBook Pro上的macOS），所以我卸载了Xubuntu默认安装的办公软件以及不需要的组件::

   sudo apt remove --purge libreoffice*
   sudo apt clean
   sudo apt autoremove

.. note::

   可以通过命令行 ``sudo apt list --installed`` 检查已经安装的软件包。

   个人觉得和简洁桌面无关的应用有:

   - Accessories
      - Character Map ( ``gucharmap`` )
      - Mousepad ( ``mousepad`` )
      - Notes ( ``xfce4-notes-plugin`` )
      - Onboard ( ``onboard`` )
      - Xfburn ( ``xfburn`` )
   - Games
      - Mines ( ``gnome-mines`` )
      - SGT Puzzles Collection ( ``sgt-puzzles`` )
      - Sudoku ( ``gnome-sudoku`` )
   - Graphics
      - Simple Scan ( ``simple-scan`` )
   - Internet
      - Firefox Web Browser ( ``firefox`` )
      - Pidgin Internet Messager ( ``pidgin`` )
      - Thunderbird Mail ( ``thunderbird`` )
      - Transmission ( ``transmission-gtk`` )
   - Multimedia
      - Parole Media Player ( ``parole`` ) (这个可选，或许也需要播放器)

- 完整卸载我不需要的软件（仅供参考）::

   sudo apt remove --purge gucharmap mousepad xfce4-notes-plugin onboard xfburn \
   gnome-mines sgt-puzzles gnome-sudoku \
   simple-scan \
   firefox pidgin thunderbird transmission-gtk \
   parole

.. note::

   `How to uninstall pre-installed programs in Xubuntu <https://askubuntu.com/questions/319764/how-to-uninstall-pre-installed-programs-in-xubuntu>`_ : Ubuntu提供了一个 ``synaptic`` 图形化软件包管理工具，同时安装的软件包列表::

      docbook-xml libept1.5.0 libgtk2-perl libpango-perl librarian0 libxapian30 rarian-compat sgml-base sgml-data
        synaptic xml-core

- 安装需要的软件::

   sudo apt install chromium-browser

无线网卡
=============

- Ubuntu Desktop LiveCD

Ubuntu Desktop在安装过程中是可以识别MacBook Pro的无线网卡（Broadcom BCM 43xx），但是，安装完成后，由于Licence限制，默>认是没有安装网卡驱动，导致无法识别网卡，也不能连接网络。

不过，Ubuntu Desktop的LiveCD是包含了网卡驱动的，所以通过将LiveCD镜像挂载并作为APT的软件仓库源，就可以直接安装 ``Broadcom STA无线驱动（私有）``::

   mkdir /media/cdrom
   mount -t iso9660 -o loop ~/ubuntu-budgie-18.10-desktop-amd64.iso /media/cdrom
   apt-cdrom -m -d /media/cdrom add

   sudo apt-get update
   sudo apt-get --reinstall install bcmwl-kernel-source

.. _ubuntu_desktop_nvidia:

显卡
=========

.. note::

   只有需要使用图形界面才需要安装Nvdia驱动，如果只是单纯使Ubuntu作为服务器，可忽略此步骤。

MacBook Pro使用的显卡是NVIDIA GeForce GT 750M Mac Edition ，默认安装的显卡驱动是开源的 nouveau ，这个驱动对于硬件加速>比官方的闭源驱动要差，所以推荐采用官方驱动。

.. note::

   详细参考 `在Ubuntu 18.10安装Nvidia驱动 <https://github.com/huataihuang/cloud-atlas-draft/tree/master/os/linux/ubuntu/install/install_nvidia_drivers_on_ubuntu_18_10.md>`_

- 安装 ``ubuntu-drivers`` 工具包::

   sudo apt install ubuntu-drivers-common

- 列出建议驱动版本::

   ubuntu-drivers devices

- 安装推荐驱动（默认推荐驱动是 ``nvidia-driver-390`` ）::

   sudo ubuntu-drivers autoinstall

