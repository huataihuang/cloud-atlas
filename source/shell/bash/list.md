显示所有用户的定时任务

```
for user in $(cut -f1 -d: /etc/passwd); do crontab -u $user -l; done
```

系统级别的cron需要检查多个位置：

* `/etc/crontab`
* 每日：`/etc/cron.daily/`目录下文件
* 每小时：`/etc/cron.hourly/`目录下文件
* 每周：`/etc/cron.weekly/`目录下文件
* 每月：`/etc/cron.monthly/`目录下文件
* 软件包特定定时任务：`/etc/cron.d/`目录下文件

# 参考

* [Linux: List / Display All Cron Jobs](https://www.cyberciti.biz/faq/linux-show-what-cron-jobs-are-setup/)
* [How do I list all cron jobs for all users?](http://stackoverflow.com/questions/134906/how-do-i-list-all-cron-jobs-for-all-users)
