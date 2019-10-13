.. _wine:

=========================
wine环境运行Windows程序
=========================

Wine可以通过激活 multilib 软件仓库进行安装，可以安装 wine (稳定) 和 wine-staging (测试) 软件包。

- 激活multilib仓库，即编辑 ``/etc/pacman.conf`` 激活::

   [multilib]
   Include = /etc/pacman.d/mirrorlist

- 然后更新一次仓库::

   pacman -Syu

- 安装wine-staging::

   pacman -S wine-staging

- 安装wine_gecko(Internet Explorer)和wine-mono(.NET)::

   pacman -S wine_gecko wine-mono

- 运行winecfg对系统进行配制::

   winecfg

目前采用默认配制，实际上就是先更新一下home目录。其他配制工具还有 ``regedit`` (注册表) 和 ``wine control`` (Windows Control Pannel)。

- 启动IE expolre ``wine iexplore`` ，无法访问https服务报错(可以访问http服务)::

   0036:err:winediag:schan_imp_init Failed to load libgnutls, secure connections will not be available.
   0036:err:winediag:SECUR32_initNTLMSP ntlm_auth was not found or is outdated. Make sure that ntlm_auth >= 3.0.25 is in your path. Usually, you can find it in the winbind package of your distribution.
   0036:err:winediag:load_gssapi_krb5 Failed to load libgssapi_krb5, Kerberos SSP support will not be available.
   0009:fixme:ieframe:handle_navigation_error Navigate to error page
   0009:err:ole:CoReleaseMarshalData StdMarshal ReleaseMarshalData failed with error 0x8001011d

对应安装::

   yay -S lib32-libwbclient

字体
----

如果Wine应用程序不能显示良好字体


