.. _systemd_manage_resources:

========================
systemd管理应用资源
========================

在 :ref:`parallel_make_oom` 了解到现代操作系统 :ref:`systemd` 可以结合 :ref:`cgroup` 来管理应用资源，这对生产环境管理非常重要

- 检查 ``sshd.service`` 资源:

.. literalinclude:: systemd_manage_resources/systemctl_show_sshd
   :caption: 使用 ``systemctl show`` 检查 ``sshd.service`` 配置

输出显示:

.. literalinclude:: systemd_manage_resources/systemctl_show_sshd_output
   :caption: 使用 ``systemctl show`` 检查 ``sshd.service`` 配置可以看到 cgruop 是 ``/system.slice/sshd.service``

调整用户cgroup(待验证)
=========================

参考 `systemd, per-user cpu and/or memory limits <https://serverfault.com/questions/874274/systemd-per-user-cpu-and-or-memory-limits>`_ 待实践

参考
=======

- `Red Hat Enterprise Linux > 9 > Monitoring and managing system status and performance > Chapter 33. Using systemd to manage resources used by applications <https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/9/html/monitoring_and_managing_system_status_and_performance/assembly_using-systemd-to-manage-resources-used-by-applications_monitoring-and-managing-system-status-and-performance>`_
- `systemd, per-user cpu and/or memory limits <https://serverfault.com/questions/874274/systemd-per-user-cpu-and-or-memory-limits>`_
