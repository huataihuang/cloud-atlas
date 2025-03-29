#!/bin/bash -
set -e
vm="$1"

guestfish -d "$vm" -i <<'EOF'
  download /etc/netplan/01-netcfg.yaml /tmp/01-netcfg.yaml
  ! sed -i 's/192.168.6.247/192.168.6.102/g' /tmp/01-netcfg.yaml
  upload /tmp/01-netcfg.yaml /etc/netplan/01-netcfg.yaml
EOF
