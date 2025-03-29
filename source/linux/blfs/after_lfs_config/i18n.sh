cat > /etc/profile.d/i18n.sh << "EOF"
# Set up i18n variables
for i in $(locale); do
  unset ${i%=*}
done

# 这里我修改为直接设置 en_US.UTF-8
export LANG=en_US.UTF-8
EOF
