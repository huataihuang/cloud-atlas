.. _bpftrace:

============
bpftrace
============

``bpftrace`` 是高级跟踪语言，适用于Linux内核4.x以上提供的Linux :ref:`ebpf` 数据包过滤器。 ``bpftrace`` 使用LLVM最为后端，将脚本编译为BPF字节码，并利用BCC与Linux BPF系统交互，就像现有的Linux跟踪能力：内核动态跟踪(kernel dynamic tracing, kprobes)，用户级动态跟踪(user-level dynamic tracing, uprobes)以及 tracepoints。 ``bpftrace`` 语言的灵感来自 awk 和 C，以及 DTrace和SystemTap等跟踪器。

参考
=====

- `bpftrace (GitHub) <https://github.com/iovisor/bpftrace>`_
