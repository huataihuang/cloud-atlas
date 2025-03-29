from django.db import models

class User(models.Model):
    username = models.CharField(max_length=19)
    email = models.CharField(max_length=100)
    groups = models.CharField(max_length=100)
    create_time = models.DateTimeField()

    class Meta:
        ordering = ('create_time',)
