.. _upgrade_centos_7_to_8:

=========================
升级CentOS 7到CentOS 8
=========================

.. note::

  从CentOS FAQ来看RHEL7升级RHEL8使用了工具leapp，但是这个工具没有移植到CentOS。

   CentOS论坛有 `Upgrade process from CentOS7 <https://www.centos.org/forums/viewtopic.php?t=71745>`_ 讨论，使用的工具 `leapp <https://leapp-to.github.io/gettingstarted#centos-7>`_ 据测试还存在问题。

   Red Hat官方文档 `UPGRADING TO RHEL 8 <https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/8/html-single/upgrading_to_rhel_8/index>`_ 有一个文档说明，可以参考学习。

.. warning::

   本文实践是参考第三方文档 `How to Upgrade CentOS 7 to CentOS 8 <https://www.tecmint.com/upgrade-centos-7-to-centos-8/>`_ 完成，但是其中也做了一些问题排查和hack。

   由于CentOS官方没有提供大版本升级到CentOS 8的工具，本文实践完全是手工操作，其中可能也有不完善和潜在的风险，所以请务必谨慎操作，并且不建议用于生产环境，具体风险请自行把控。

准备工作
===============

- 首先需要安装EPEL仓库::

   yum install epel-release -y

- 安装yum-utils工具::

   yum install yum-utils -y

- 解析RPM包::

   yum install rpmconf -y
   rpmconf -a

注意，这里 ``rpmconf -a`` 有一些交互问答，采用默认选项。

- 清理所有不需要的软件包::

   package-cleanup --leaves
   package-cleanup --orphans

安装dnf
=========

- 需要首先安装CentOS 8的默认包管理器 dnf ::

   yum install dnf -y

- 然后移除yum包管理器::

   dnf -y remove yum yum-metadata-parser
   rm -Rf /etc/yum

升级CentOS 7到CentOS 8
=========================

- 现在执行CentOS 7升级到CentOS 8前需要线升级从::

   dnf upgrade

- 然后安装CentOS 8的release软件包::

   dnf install http://mirrors.163.com/centos/8/BaseOS/x86_64/os/Packages/centos-repos-8.1-1.1911.0.9.el8.x86_64.rpm \
   http://mirrors.163.com/centos/8/BaseOS/x86_64/os/Packages/centos-release-8.1-1.1911.0.9.el8.x86_64.rpm \
   http://mirrors.163.com/centos/8/BaseOS/x86_64/os/Packages/centos-gpg-keys-8.1-1.1911.0.9.el8.noarch.rpm

- 升级EPEL仓库::

   dnf -y upgrade https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm

- 在升级了EPEL仓库后，移除所有临时文件::

   dnf clean all

- 删除CentOS 7的旧内核core::

   rpm -e `rpm -q kernel`

- 移除冲突的软件包::

   rpm -e --nodeps sysvinit-tools

- 然后执行CentOS 8升级::

   dnf -y --releasever=8 --allowerasing --setopt=deltarpm=false distro-sync

报错::

   Running transaction check
   Error: transaction check vs depsolve:
   (gcc >= 8 with gcc < 9) is needed by annobin-8.78-1.el8.x86_64
   rpmlib(RichDependencies) <= 4.12.0-1 is needed by annobin-8.78-1.el8.x86_64
   (annobin if gcc) is needed by redhat-rpm-config-120-1.el8.noarch
   rpmlib(RichDependencies) <= 4.12.0-1 is needed by redhat-rpm-config-120-1.el8.noarch
   To diagnose the problem, try running: 'rpm -Va --nofiles --nodigest'.
   You probably have corrupted RPMDB, running 'rpm --rebuilddb' might fix the issue.
   The downloaded packages were saved in cache until the next successful transaction.
   You can remove cached packages by executing 'dnf clean packages'.

不过，此时 ``cat /etc/redhat-release`` 已经显示是 ``CentOS Linux release 8.1.1911 (Core)`` 所以我们需要解决这个软件依赖的冲突问题：

- 升级gcc(升级以后gcc版本是8.3.1)::

   dnf upgrade gcc

但是升级以后报错依旧，看起来是因为依赖 ``rpm-4.14.2-26.el8_1.x86_64`` 才能完成。

参考 `dnf upgrade and dnf update fails <https://forums.centos.org/viewtopic.php?f=54&t=73160>`_ 这是因为升级CentOS 7到8时候broken了7系统导致的。

检查发现当前系统使用的 rpm 版本还是el7使用的 ``rpm-4.11.3-43.el7.x86_64`` ，似乎是这个版本没有满足要求，所以先升级rpm::

   dnf upgrade --best --allowerasing rpm

但是上述会遇到很多文件冲突::

   file /usr/lib/python3.6/site-packages/setuptools/command/__pycache__/upload_docs.cpython-36.pyc from install of platform-python-setuptools-39.2.0-5.el8.noarch conflicts with file from package python3-setuptools-39.2.0-10.el7.noarch
   file /usr/lib/python3.6/site-packages/rpmconf/__pycache__/__init__.cpython-36.opt-1.pyc from install of python3-rpmconf-1.0.21-1.el8.noarch conflicts with file from package python36-rpmconf-1.0.22-1.el7.noarch

这是因为，CentOS 7 的软件包 ``python36-rpmconf`` 到 CentOS 8改成了 ``python3-rpmconf`` ，所以由于包名字不同，所以没有对应进行升级，导致了文件冲突。注意类似和rpm相关到依赖不能直接卸载否则会导致rpm无法正常工作，所以改成删除 ``python36-rpmconf`` 包信息但是不实际删除文件::

   rpm -e --justdb python36-rpmconf-1.0.22-1.el7.noarch rpmconf-1.0.22-1.el7.noarch
   rpm -e --justdb --nodeps python3-setuptools-39.2.0-10.el7.noarch
   rpm -e --justdb --nodeps python3-pip-9.0.3-7.el7_7.noarch
   rpm -e --justdb --nodeps vim-minimal

.. note::

   CentOS 7到CentOS 8中，有包名字修改的有::

      python36-rpmconf => python3-rpmconf
      python3-setuptools => platform-python-setuptools
      vim-minimal (CentOS 7) 和 vim-common (CentOS 8)冲突

.. note::

   在 `How to Upgrade Centos 7 to 8 <https://www.howtoforge.com/how-to-upgrade-centos-7-core-to-8/>`_ 的comments中，stafwag提出解决方法是删除 gcc 和所有 devel 软件包::

      rpm -qa | grep -i devel | xargs -n 1 dnf remove -y

   但是我验证这个方法没有成功，所以还是采用我自己摸索出来的方法。

- 然后再次执行CentOS 8升级就可以成功::

   dnf -y --releasever=8 --allowerasing --setopt=deltarpm=false distro-sync

- 安装CentOS 8的新Kernel Core::

   dnf -y reinstall kernel-core

.. note::

   这里比较奇怪，虽然 ``/boot`` 目录下没有 ``vmlinuz-4.18.0-147.8.1.el8_1.x86_64`` 文件，显示内核并没有安装成功。但是系统提示我 ``kernel-core`` 已经安装，所以我采用的是 ``reinstall`` 指令。

- 最后安装CentOS 8最小化包::

   dnf -y groupupdate "Core" "Minimal Install"

.. note::

   这里会提示需要安装的 rsyslog 和 syslog-ng 冲突(原因是原先CentOS 7安装的是syslog-ng，虽然升级到了CentOS 8版本，但是和CentOS 8的rsyslog冲突)，所以我先卸载syslog-ng，然后再重新执行上述CentOS 8最小化包安装::

      rpm -e syslog-ng-3.23.1-1.el8.x86_64

- 现在可以检查CentOS版本信息::

   cat /etc/redhat-release

.. note::

   注意，上述步骤中每一步都需要仔细检查是否正确执行，千万不能跳过失败都步骤，否则会导致升级错乱失败。

到目前为止，已经完成了CentOS 7升级到CentOS 8的过程，现在重启操作系统::

   shutdown -r now

sshd服务启动
==================

升级到CentOS 8之后，遇到 sshd 服务无法启动问题。登陆到终端检查::

   systemctl status sshd.service

显示::

   ● sshd.service - OpenSSH server daemon
      Loaded: loaded (/usr/lib/systemd/system/sshd.service; enabled; vendor preset: enabled)
      Active: activating (auto-restart) (Result: exit-code) since Sat 2020-06-06 22:58:23 CST; 7s ago
        Docs: man:sshd(8)
              man:sshd_config(5)
     Process: 12412 ExecStart=/usr/sbin/sshd -D $OPTIONS $CRYPTO_POLICY (code=exited, status=255)
    Main PID: 12412 (code=exited, status=255)

原因是原先CentOS 7上sshd配置 ``/etc/ssh/sshd_config`` 和升级到CentOS 8之后的sshd不兼容::

   Jun 06 23:00:29 worker-1.huatai.me sshd[13564]: /etc/ssh/sshd_config line 21: Deprecated option KeyRegenerationInterval
   Jun 06 23:00:29 worker-1.huatai.me sshd[13564]: /etc/ssh/sshd_config line 22: Deprecated option ServerKeyBits
   Jun 06 23:00:29 worker-1.huatai.me sshd[13564]: /etc/ssh/sshd_config line 36: Deprecated option RSAAuthentication
   Jun 06 23:00:29 worker-1.huatai.me sshd[13564]: /etc/ssh/sshd_config line 41: Deprecated option RhostsRSAAuthentication
   Jun 06 23:00:29 worker-1.huatai.me sshd[13564]: /etc/ssh/sshd_config line 83: Deprecated option UseLogin
   Jun 06 23:00:29 worker-1.huatai.me sshd[13564]: /etc/ssh/sshd_config line 84: Deprecated option UsePrivilegeSeparation
   Jun 06 23:00:29 worker-1.huatai.me sshd[13564]: /etc/ssh/sshd_config line 98: Bad SSH2 cipher spec 'aes128-ctr,aes192-ctr,aes256-ctr,aes128-gcm>
   Jun 06 23:00:29 worker-1.huatai.me systemd[1]: sshd.service: Main process exited, code=exited, status=255/n/a
   Jun 06 23:00:29 worker-1.huatai.me systemd[1]: sshd.service: Failed with result 'exit-code'.
   Jun 06 23:00:29 worker-1.huatai.me systemd[1]: Failed to start OpenSSH server daemon.

   Jun 06 23:00:34 worker-1.huatai.me su[13589]: PAM unable to dlopen(/usr/lib64/security/pam_tally2.so): /usr/lib64/security/pam_tally2.so: canno>
   Jun 06 23:00:34 worker-1.huatai.me su[13589]: PAM adding faulty module: /usr/lib64/security/pam_tally2.so
   Jun 06 23:00:34 worker-1.huatai.me su[13589]: (to root) root on none
   Jun 06 23:00:34 worker-1.huatai.me su[13589]: pam_unix(su:session): session opened for user root by (uid=0)
   Jun 06 23:00:34 worker-1.huatai.me su[13589]: pam_unix(su:session): session closed for user root

解决的方法是使用新软件包配置覆盖::

   cd /etc/ssh
   cp sshd_config.rpmnew sshd_config
   cp ssh_config.rpmnew ssh_config

现在sshd可以成功启动了，但是用户依然无法通过密码认证登陆，在 ``systemctl status sshd`` 中可以看到报错原因是PAM库加载错误::

   Jun 06 23:05:36 worker-1.huatai.me sshd[16040]: PAM unable to dlopen(/usr/lib64/security/pam_tally2.so): /usr/lib64/security/pam_tally2.so: can>
   Jun 06 23:05:36 worker-1.huatai.me sshd[16040]: PAM adding faulty module: /usr/lib64/security/pam_tally2.so

实际上系统缺少 ``/usr/lib64/security/pam_tally2.so`` 文件，原因是 ``/etc/pam.d/system-auth`` 包含了该认证策略。检查 ``/etc/pam.d`` 可以看到，升级CentOS 8的很多配置文件没有覆盖原先旧系统的配置文件，需要修正::

   mv sshd sshd.bak
   mv sshd.rpmnew sshd
   sysemctl restart sshd

然后就可以通过ssh远程登陆了。

CentOS 7旧软件包和升级
========================

现在已经完成了操作系统大版本升级，并且解决了基本的ssh登陆。但是系统中依然有一些软件包是el7版本，原因可能是旧操作系统软件包名字在新版本已经不同，所以没有得到直接升级。可以通过 ``rpm -qa | grep el7`` 检查列表，并进行清理。

除了少数el7软件包被依赖，例如 ``nss-pem-1.0.3-7.el7.x86_64`` 被 ``rpm`` 工具包依赖，不能删除。其他非重要的软件包可以手工清理。

::

   rpm -qa | grep .el7. | xargs -n 1 dnf remove -y

清理无用软件包
===============

:ref:`dnf` 提供了类似apt的autoremove的功能，可以自动清理不需要的(没有被依赖的)软件包::

   dnf autoremove

.. note::

   参考 `How to remove orphaned packages on CentOS Linux <https://linuxconfig.org/how-to-remove-orphaned-packages-on-centos-linux>`_ 对于CentOS 7版本， ``yum-utils`` 提供了类似功能::

      yum install yun-utils
      # 获取孤儿软件包
      package-cleanup --leaves
      # 删除孤儿软件包
      yum remove `package-cleanup --leaves`

参考
======

- `How to Upgrade CentOS 7 to CentOS 8 <https://www.tecmint.com/upgrade-centos-7-to-centos-8/>`_
