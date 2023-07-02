
cat << EOF > glusterfs-11.repo
[centos-gluster11]
name=CentOS-$releasever - Gluster 11
baseurl=http://REPO:8080/glusterfs/11.0/CentOS/7.2/
enabled=1
gpgcheck=0
EOF

repo=$1
sed -i "s/REPO/$repo/g" glusterfs-11.repo
