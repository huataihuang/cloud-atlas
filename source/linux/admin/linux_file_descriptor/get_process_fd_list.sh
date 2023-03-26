$ sudo lsof -p 79058
COMMAND     PID         USER   FD      TYPE             DEVICE SIZE/OFF    NODE NAME
qemu-syst 79058 libvirt-qemu  cwd       DIR                8,2     4096       2 /
qemu-syst 79058 libvirt-qemu  rtd       DIR                8,2     4096       2 /
qemu-syst 79058 libvirt-qemu  txt       REG                8,2 15791488 1840034 /usr/bin/qemu-system-x86_64
qemu-syst 79058 libvirt-qemu  DEL       REG               0,19          2955594 /[aio]
qemu-syst 79058 libvirt-qemu  mem       REG                8,2  4451632 1835291 /usr/lib/x86_64-linux-gnu/libcrypto.so.3
qemu-syst 79058 libvirt-qemu  mem       REG                8,2   170456 1835036 /usr/lib/x86_64-linux-gnu/liblzma.so.5.2.5
...
