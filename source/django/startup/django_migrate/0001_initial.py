from django.db import migrations, models


class Migration(migrations.Migration):

    initial = True

    dependencies = [
    ]

    operations = [
        migrations.CreateModel(
            name='GuestPanic',
            fields=[
                ('id', models.AutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('username', models.CharField(max_length=19)),
                ('email', models.CharField(max_length=100)),
                ('gruops', models.CharField(max_length=100)),
                ('create_time', models.DateTimeField()),
            ],
            options={
                'ordering': ('create_time',),
            },
        ),
    ]
