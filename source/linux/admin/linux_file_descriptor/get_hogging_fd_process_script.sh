ps aux | grep -v PID > ps.log
cat ps.log | awk '{print $2}' > pids
> pid_fd.log
for pid in `cat pids`;do
    fd_num=`sudo ls /proc/${pid}/fd | wc -l`
    echo "${pid},${fd_num}" >> pid_fd.log
done
