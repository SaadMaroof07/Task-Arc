

from django.contrib.auth.models import AbstractUser
from django.db import models

class User(AbstractUser):
    # Roles define karein
    ROLE_CHOICES = [
        ('ADMIN', 'Admin'),
        ('USER', 'Regular User'),
    ]
    
    role = models.CharField(max_length=10, choices=ROLE_CHOICES, default='USER')
    email = models.EmailField(unique=True) # Email ko unique banaya login ke liye
    phone_number = models.CharField(max_length=15, blank=True, null=True)

    def __str__(self):
        return f"{self.username} ({self.role})"
    

# ... (User model jo upar likha hai woh yahan rahega)

class Category(models.Model):
    name = models.CharField(max_length=100)
    user = models.ForeignKey(User, on_delete=models.CASCADE) 

    def __str__(self):
        return self.name
    


class Task(models.Model):
    PRIORITY_CHOICES = [('L', 'Low'), ('M', 'Medium'), ('H', 'High')]

    # ForeignKey ab hamare Custom User se link hai
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='tasks')
    category = models.ForeignKey(Category, on_delete=models.SET_NULL, null=True, blank=True)
    
    title = models.CharField(max_length=255)
    description = models.TextField(blank=True, null=True)
    is_completed = models.BooleanField(default=False)
    priority = models.CharField(max_length=1, choices=PRIORITY_CHOICES, default='M')
    created_at = models.DateTimeField(auto_now_add=True)
    due_date = models.DateTimeField(null=True, blank=True)

    def __str__(self):
        return self.title  
    
      
    


