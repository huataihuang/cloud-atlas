.. _introduce_kali_linux:

=================
Kali Linux介绍
=================

未来世界的幸存者
==================

阮一峰的 `未来世界的幸存者 <https://book.douban.com/subject/30259509/>`_ 促使我一直思考，究竟具备什么样的生存技能才能不被即将到来的未来世界所淘汰。或许有些突兀，但是我有一个念头，就是至少要具备基本的计算机安全技术的人才能生存。

我们几乎所有的数据资料、财富、人与人的联系和协作，都是通过赛博空间实现。倘若没有基本的信息安全技术，所有的一切可能在弹指间灰飞烟灭。

Kali Linux是什么
==================

面向安全领域的Linux
----------------------

`Kali Linux <https://www.kali.org>`_ 是基于Debian的Linux发行版，目标是提供高级的渗透测试(Penetration Testing)和安全审计(Security Auditing)。Kali包含了数百个工具可以提供不同的安全任务实现，例如:

- 渗透测试(Penetration Testing)
- 安全研究(Security research)
- 计算机取证(Computer Forensics)
- 反向工程(Reverse Engiiineering)

Kali Linux是有 `Offensive Security <http://www.offensive-security.com/>`_ 开发、资助和维护。最早于2013年3月13日发布，从 `BackTrack Linux <http://www.backtrack-linux.org/>`_ 完全从头开始重建，并且完全遵循Debian开发标准。

- 包含超过600种渗透测试工具：详情请参考 `Kali Tools 官方网站 <http://tools.kali.org/>`_ 
- 永久免费：Kali Linux发行版是免费提供的， `Offensive Security <http://www.offensive-security.com/>`_ 主要通过培训和认证来获得收入。
- 开源：在 `Kali Linux GitHub 仓库 <https://gitlab.com/kalilinux/>`_ 提供所有构建Kali Linux的源代码，任何人都可以调整和重新编译 `Kali Linux 软件包 <http://pkg.kali.org/>`_ 来满足其特定需求
- 支持广泛的无线网络设备
- 定制的内核，针对注入(injection)做了补丁： 由于需要渗透测试，Kali Linux开发团队已经在内核包含了最新的注入补丁
- GPG签名软件包和仓库： 所有Kali Linux软件包都是安全签名
- 多语言支持
- 完全可定制化：提供 `定制Kali Linux指导文档 <https://docs.kali.org/?cat_ID=7>`_ 帮助有冒险精神的用户自己从内核到软件包的全面定制
- ARM系列硬件支持： `Kali Linux支持广泛的ARM设备 <https://docs.kali.org/?cat_ID=170>`_ 并且有ARM仓储提供主线发行版支持

支持多种硬件平台以及不同桌面版本运行：

- `常规x86 i386/x86_64 <https://www.kali.org/downloads/>`_
- `ARM不同硬件平台 <https://www.offensive-security.com/kali-linux-arm-images/>`_
- `Vmware和VirtualBox镜像 <https://www.offensive-security.com/kali-linux-vm-vmware-virtualbox-image-download/>`_

我的Kali
-------------

我主要在两个运行环境中学习Kali Linux:

- VMware虚拟机运行
- Raspberry Pi Zero
  
 | 树莓派Zero是一个非常小巧的类似口香糖大小的单片机，通过转换USB连接笔记本，可以非常方便携带使用，是一个非常有意思的玩具。

其他有趣的Kali版本
---------------------

- USB armory

`Inverse Path公司 <https://inversepath.com>`_ 在2015年推出一种非常有趣小巧的USB计算棒 `USB Armory <https://inversepath.com/usbarmory>`_ （155美元） ，基于ARM芯片的安全设备。类似U盘，集成了加密数据存储、Tor路由器、密码保险箱等诸多安全特性。Kali Linux也提供了该硬件设备的支持镜像，也许是非常好玩的工具。

USB armory是一个开源硬件设计的USB计算棒，目前 `Mk II第二代产品正在开发中 <https://github.com/inversepath/usbarmory/wiki/Mk-II-Roadmap>`_

- Gemini PDA

`Gemini PDA <https://en.wikipedia.org/wiki/Gemini_(PDA)>`_ 是一个非常小众然而却很有意思的具备4G+Wifi的PDA设备，2018年发布的非常酷炫的个人电脑，可以运行Android, Sailfish OS, Debian。当然，也可以 `在Gemini PDA上运行Kali Linux <https://www.kali.org/news/kali-linux-for-the-gemini-pda/>`_ 。

全尺寸键盘，完全面向Geek的移动设备，可以切换启动5个操作系统：Android, rooted Android, Sailfish, Debian, Kali Linux，非常好玩。

- `Kali Linux for Android Mobile Devices <https://www.offensive-security.com/kali-linux-nethunter-download/>`_

基于Android设备中运行Kali Linux，可以工作在不同的Android手机或者平板。例如，你可以在Nexus 5手机内部安装一个Kali Linux系统来实现安全扫描。
