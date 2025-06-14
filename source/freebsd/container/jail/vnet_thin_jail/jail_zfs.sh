export jail_zfs="zdata/jails"
export bsd_ver="14.2"

jail_name=$1
id=$2

zfs clone $jail_zfs/templates/$bsd_ver-RELEASE-skeleton@base $jail_zfs/containers/$jail_name
mkdir -p /$jail_zfs/$jail_name-nullfs-base

cat << EOF > /$jail_zfs/$jail_name-nullfs-base.fstab
/$jail_zfs/templates/14.2-RELEASE-base  /$jail_zfs/$jail_name-nullfs-base/         nullfs  ro  0 0
/$jail_zfs/containers/$jail_name               /$jail_zfs/$jail_name-nullfs-base/skeleton nullfs  rw  0 0
EOF

cat << 'EOF' > /etc/jail.conf.d/$jail_name.conf
JAIL_NAME {
  $id = "ID";
  $ip = "192.168.7.${id}/24";
}
EOF

sed -i '' "s@JAIL_NAME@$jail_name@" /etc/jail.conf.d/$jail_name.conf
sed -i '' "s@ID@$id@" /etc/jail.conf.d/$jail_name.conf
