cat << EOF > Dockerfile
FROM kindest/node:v1.25.3
RUN apt install zfsutils-linux -y
EOF

docker build -t kindest/node:v1.25.3-zfs .
