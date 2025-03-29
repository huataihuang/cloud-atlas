.. _systemd_rc_local:

========================
Systemd的rc.local配置
========================

在早期的操作系统中，系统管理员很喜欢把一些操作系统启动时最后需要运行的脚本写在 ``/etc/rc.local`` 中，这个执行脚本（ ``需要具有可执行属性`` ）是操作系统启动时最后执行的启动脚本。

切换到RHEL/CentOS 7之后， ``systemd`` 接管了 ``init`` 模式的启动脚本，实际上已经不再适合使用 ``rc.local`` 启动脚本。但是为了兼容一些老系统习惯，保留了一个称为 ``rc.lcoal.service`` 的服务来引用 ``/etc/rc.local`` 。

.. note::

   实际上 ``systemd`` 执行的并不是 ``/etc/rc.local`` ，而是 ``/etc/rc.d/rc.local`` 脚本，这个执行程序可以通过 ``sudo systemctl status rc-local`` 指令看到输出如下::

      ● rc-local.service - /etc/rc.d/rc.local Compatibility
         Loaded: loaded (/usr/lib/systemd/system/rc-local.service; static; vendor preset: disabled)
         Active: active (exited) since Thu 2017-08-31 10:21:19 CST; 4 days ago

   ``/etc/rc.local`` 实际上是指向 ``/etc/rc.d/rc.local`` 的软链接。曾经线上有出现过有人直接通过脚本 ``rm /etc/rc.local`` 然后又复制一个启动脚本到 ``/etc/rc.local`` ，愿意是用让新脚本在系统启动时运行。但是实际上破坏了系统默认的 ``/etc/rc.local`` 软链接，而系统自动执行的 ``/etc/rc.d/rc.local`` 并没有正确修改，也就无法执行正确的rc.local内容。

配置 rc.local 服务
====================

* 编辑兼容 ``rc.local`` 的 ``systemd`` 配置文件 ``/usr/lib/systemd/system/rc-local.service`` ，其内容如下::

   [Unit]
   Description=/etc/rc.d/rc.local Compatibility
   ConditionFileIsExecutable=/etc/rc.d/rc.local
   After=network.target

   [Service]
   Type=forking
   ExecStart=/etc/rc.d/rc.local start
   TimeoutSec=0
   RemainAfterExit=yes

   [Install]
   WantedBy=multi-user.target

.. note::

   以上配置是 Red Hat 的 rc-local.service 配置，因为Red Hat依然向后兼容 rc.local ，所以预先存放了 ``/etc/rc.d/rc.local`` 配置，只需要上述简单配置就可以。

   在 Arch Linux中，默认都没有 ``/etc/rc.local`` ，则该配置文件 ``/etc/systemd/system/rc-local.service`` 还需要做一些调整::

      [Unit]
      Description=/etc/rc.local compatibility

      [Service]
      Type=oneshot
      ExecStart=/etc/rc.local
      # disable timeout logic
      TimeoutSec=0
      #StandardOutput=tty
      RemainAfterExit=yes
      SysVStartPriority=99

      [Install]
      WantedBy=multi-user.target

   或者::

      [Unit]
      Description=/etc/rc.local compatibility

      [Service]
      Type=oneshot
      ExecStart=/etc/rc.local
      RemainAfterExit=yes

      [Install]
      WantedBy=multi-user.target

* 激活rc-local服务::

   sudo systemctl enable rc-local

* 配置 ``/etc/rc.d/rc.local`` ::

   #!/usr/bin/bash
   XXXXX

.. note::

   ``rc.local`` 开头的第一行必须要指定shell解释器，否则不能正常运行

* 创建软链接，并设置 ``rc.local`` 可执行属性::

   ln -s /etc/rc.d/rc.local /etc/rc.local
   chmod 755 /etc/rc.d/rc.local

.. note::

   ``rc.local`` 必须具备可执行属性，否则启动系统不会自动执行。

.. warning::

   systemd启动服务默认是并发执行，如果没有在配置中指定先后顺序，则启动脚本顺序可能有随机行，所以不能脚本之间不能有依赖关系，也不要在多个脚本中执行相同或相互影响的内容，否则会出现不可预料的结果。

详细的一些配置systemd rc-local的经验教训，可以参考我的实践 `systemd管理rc.local启动 <https://github.com/huataihuang/cloud-atlas-draft/blob/master/os/linux/redhat/system_administration/systemd/rc_local.md>`_

参考
=======

- `How to Enable /etc/rc.local with Systemd <https://www.linuxbabe.com/linux-server/how-to-enable-etcrc-local-with-systemd>`_
- `Replacing rc.local in systemd Linux systems <https://www.redhat.com/sysadmin/replacing-rclocal-systemd>`_
- `How to run script with systemd right before shutdown in Linux <https://www.golinuxcloud.com/run-script-with-systemd-before-shutdown-linux/>`_
- `User:Herodotus/Rc-Local-Systemd <https://wiki.archlinux.org/index.php/User:Herodotus/Rc-Local-Systemd>`_
