cat <<EOF > containerd-config.patch
--- config.toml.orig    2020-12-18 18:21:41.884984894 +0000
+++ /etc/containerd/config.toml 2020-12-18 18:23:38.137796223 +0000
@@ -94,6 +94,15 @@
        privileged_without_host_devices = false
        base_runtime_spec = ""
        [plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runc.options]
+            SystemdCgroup = true
+       [plugins."io.containerd.grpc.v1.cri".containerd.runtimes.nvidia]
+          privileged_without_host_devices = false
+          runtime_engine = ""
+          runtime_root = ""
+          runtime_type = "io.containerd.runc.v1"
+          [plugins."io.containerd.grpc.v1.cri".containerd.runtimes.nvidia.options]
+            BinaryName = "/usr/bin/nvidia-container-runtime"
+            SystemdCgroup = true
    [plugins."io.containerd.grpc.v1.cri".cni]
    bin_dir = "/opt/cni/bin"
    conf_dir = "/etc/cni/net.d"
EOF
