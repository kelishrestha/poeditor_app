from django.db import models

class Language(models.Model):
    name = models.TextField(default='')
    code = models.CharField(max_length=5)
    created_at = models.DateTimeField('created date')

    def __str__(self):
        return self.name
