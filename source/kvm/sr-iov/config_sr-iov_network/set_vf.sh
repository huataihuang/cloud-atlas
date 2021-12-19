
for i in {0..3};do
    n=$[49+$i]

    # 激活VF eno49 ~ eno52
    echo 7 | tee /sys/class/net/eno${n}/device/sriov_numvfs

    # 为每个VF配置固定MAC
    for j in {0..6};do
        echo "ip link set eno${n} vf $j mac 2a:9d:79:68:6${i}:0${j}"
    done
done
