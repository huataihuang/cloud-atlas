.. _docker_post_install_quickstart:

=================================
Docker 安装后调整快速起步
=================================

当完成 :ref:`install_docker_linux` 后，对于 :ref:`debian` 系发行版，执行 ``docker info`` 有4行警告信息:

.. literalinclude:: docker_kernel_cgroup_mem_swap/docker_info_memory_swap_error
   :caption: ``docker info`` 显示不支持内存和swap限制的警告

.. literalinclude:: docker_kernel_bridge-nf-call-iptables/warning_bridge-nf-call-iptables
   :caption: ``docker info`` 显示 ``bridge-nf-call-iptables`` 被禁止的警告

**解决方法如下**

:ref:`docker_kernel_cgroup_mem_swap`
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

- 如果是使用 GRUB ( :ref:`gentoo_grub` / :ref:`ubuntu_grub` ) 的常规X86系统，则修改 ``/etc/default/grub`` ，添加 ``GRUB_CMDLINE_LINUX`` 行内容添加如下2个键值对，然后执行 ``update-grub`` 更新grub之后重启系统生效:

.. literalinclude:: docker_kernel_cgroup_mem_swap/grub
   :caption: 配置 ``/etc/default/grub`` ，添加 ``GRUB_CMDLINE_LINUX`` 行内容

- 如果使用 :ref:`raspberry_pi` :ref:`raspberry_pi_os` 则直接修订 ``/boot/firmware/cmdline.txt`` 在最后添加:

.. literalinclude:: docker_kernel_cgroup_mem_swap/cmdline
   :caption: 树莓派修订 ``/boot/firmware/cmdline.txt`` 激活cgroup内存和swap限制

:ref:`docker_kernel_bridge-nf-call-iptables`
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

- 确保加载 ``br_netfilter`` 模块( :ref:`debian` 系需要):

.. literalinclude:: docker_kernel_bridge-nf-call-iptables/modprobe_br_netfilter
   :caption: 加载 ``br_netfilter`` 内核模块

- 执行以下命令为Docker的host主机启用 ``bridge-nf-call-iptables`` (内核参数  ``1`` ):

.. literalinclude:: docker_kernel_bridge-nf-call-iptables/sysctl_bridge-nf-call-iptables_1
   :caption: 启用 ``bridge-nf-call-iptables`` (内核参数  ``1`` )
