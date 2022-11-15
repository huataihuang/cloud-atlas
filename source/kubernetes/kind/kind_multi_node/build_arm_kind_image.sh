cat << EOF > Dockerfile
FROM --platform=arm64 kindest/node:v1.25.3
RUN arch
EOF

docker build -t kindest/node:v1.25.3-arm64 .
