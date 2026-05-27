# ===================================================================== #
# ADVANCED CONFIGURATION
# ===================================================================== #

# Custom provision scripts for the virtual machine.
# Provisioning scripts are executed on startup and therefore needs to be idempotent.
provision:
  # -----------------------------------------------------------------
  # 任务一：系统底层工具链补齐（使用系统管理员 root 权限执行）
  # -----------------------------------------------------------------
  - mode: system
    script: |
      #!/bin/sh
      echo "=== [Task 1/2] Updating package list and installing system tools ==="
      # 1. 禁用交互式弹窗，防止 apt 阻塞开机流程
      export DEBIAN_FRONTEND=noninteractive
      
      # 2. 规范执行更新并同步安装你需要的工具（例如 htop, vim, rsync）
      apt-get update -y
      apt-get install -y htop vim rsync
      
      echo "=== [Task 1/2] Infrastructure tools installed successfully ==="

  # -----------------------------------------------------------------
  # 任务二：9p 文件系统高性能挂载优化（同样使用 root 权限在线重挂载）
  # -----------------------------------------------------------------
  - mode: system
    script: |
      #!/bin/sh
      echo "=== [Task 2/2] Optimizing 9p volume mount with mmap cache ==="
      
      # 1. 为底层的 9p 挂载点注入满血的内存映射缓存（cache=mmap）和 256K 巨型传输包（msize=262144）
      # 这能瞬间终结 Sphinx (make html) 等海量小文件读写时的网络 I/O 放大黑洞
      mount -o remount,cache=mmap,msize=262144 /home/admin
      
      echo "=== [Task 2/2] 9p filesystem performance unlock complete ==="
