select alert,count(*) as num from notifier_alert_statistics group by alert order by num DESC;
