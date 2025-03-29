# GPU芯片(按实际配置) => 0000:82:00.0
gpu_bdf="0000:"`lspci | grep GP102GL | awk '{print $1}'`

# vGPU profile从 mdevctl types 中查询
vgpu_type="nvidia-286"

cat << EOF > mdev_id
3eb9d560-0b31-11ee-91a9-bb28039c61eb
3eb9d718-0b31-11ee-91aa-2b17f51ee12d
EOF

for id in `cat mdev_id`;do
    sudo mdevctl start -u $id -p $gpu_bdf -t $vgpu_type
    sudo mdevctl define -a -u $id
done
