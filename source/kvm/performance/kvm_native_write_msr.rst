.. _kvm_native_write_msr:

============================
KVM运行时native_write_msr
============================

:ref:`archlinux_on_mbp` 的 :ref:`kvm_docker_in_studio` 上运行Windows 10的KVM虚拟机，感觉性能不佳，使用 ``top`` 检查发现虚拟机几乎空载情况下依然消耗了CPU 70% ::

   top - 06:38:17 up 22:08,  5 users,  load average: 0.70, 0.91, 1.12
   Tasks: 237 total,   1 running, 236 sleeping,   0 stopped,   0 zombie
   %Cpu(s):  5.1 us,  4.1 sy,  0.0 ni, 90.3 id,  0.0 wa,  0.4 hi,  0.2 si,  0.0 st
   MiB Mem :  15923.5 total,    582.5 free,   6878.5 used,   8462.5 buff/cache
   MiB Swap:      0.0 total,      0.0 free,      0.0 used.   7864.2 avail Mem 
   
       PID USER      PR  NI    VIRT    RES    SHR S  %CPU  %MEM     TIME+ COMMAND                              
     14493 nobody    20   0 5011304   4.1g  23856 S  70.1  26.4 143:26.38 qemu-system-x86                      
       543 root      20   0  582072 232040 153984 S   1.0   1.4  23:43.42 Xorg                                 
       918 huatai    20   0  521388  62116  40748 S   1.0   0.4   2:26.94 xfce4-terminal

在KVM虚拟机运行时，使用 ``perf top`` 可以看到系统最大消耗在内核 ``native_write_msr`` 上::

   6.32%  [kernel]                                 [k] native_write_msr
   2.56%  [kernel]                                 [k] __fget
   2.22%  [kernel]                                 [k] do_syscall_64
   2.05%  [kernel]                                 [k] do_sys_poll
   1.97%  [kernel]                                 [k] preempt_count_add
   1.81%  [kvm_intel]                              [k] vmx_vcpu_run
   1.74%  [kvm_intel]                              [k] vmx_vmexit
   1.65%  [kvm]                                    [k] kvm_arch_vcpu_ioctl_run
   1.28%  [kernel]                                 [k] _raw_spin_lock_irqsave
   1.22%  [kernel]                                 [k] psi_task_change
   1.13%  [kernel]                                 [k] preempt_count_sub
   1.11%  [kernel]                                 [k] __x86_indirect_thunk_rax
   0.98%  [kernel]                                 [k] eventfd_poll
   0.94%  [kernel]                                 [k] __pollwait
   0.91%  [kernel]                                 [k] _raw_spin_unlock_irqrestore
   0.90%  [kernel]                                 [k] fput_many
   0.86%  [kernel]                                 [k] entry_SYSCALL_64
   0.85%  [kernel]                                 [k] syscall_return_via_sysret
   0.84%  [kernel]                                 [k] __schedule
   0.83%  [kernel]                                 [k] menu_select
   0.81%  [kernel]                                 [k] debug_smp_processor_id
   0.79%  libglib-2.0.so.0.6200.2                  [.] g_main_context_check
   0.74%  [kernel]                                 [k] switch_mm_irqs_off
   0.68%  [kernel]                                 [k] __fget_light
   0.67%  [kernel]                                 [k] enqueue_entity
   0.64%  [kernel]                                 [k] update_cfs_group
   0.57%  [kernel]                                 [k] sock_poll
   0.54%  perf                                     [.] dso__find_symbol
   0.52%  [kernel]                                 [k] __srcu_read_lock
   0.51%  [kvm_intel]                              [k] __vmx_vcpu_run
   0.51%  [kernel]                                 [k] __rcu_read_unlock
   0.48%  [kernel]                                 [k] in_lock_functions

