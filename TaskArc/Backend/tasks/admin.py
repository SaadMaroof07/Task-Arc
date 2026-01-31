

# Register your models here.
from django.contrib import admin
from django.contrib.auth.admin import UserAdmin
from .models import User, Task, Category

# 1. Custom User Admin (Roles aur extra fields dikhane ke liye)
class CustomUserAdmin(UserAdmin):
    model = User
    # Admin panel ki list mein ye columns dikhen ge
    list_display = ['username', 'email', 'role', 'is_staff', 'phone_number']
    
    # User edit karte waqt ye fields nazar aayengi
    fieldsets = UserAdmin.fieldsets + (
        ('Extra Info', {'fields': ('role', 'phone_number')}),
    )
    # Naya user banate waqt ye fields
    add_fieldsets = UserAdmin.add_fieldsets + (
        ('Extra Info', {'fields': ('role', 'phone_number', 'email')}),
    )

# 2. Task Admin (Filters aur Search ke saath)
class TaskAdmin(admin.ModelAdmin):
    list_display = ['title', 'user', 'priority', 'is_completed', 'due_date']
    list_filter = ['is_completed', 'priority', 'created_at'] # Side pe filter lag jayega
    search_fields = ['title', 'description'] # Search bar kaam karega
    ordering = ['-created_at'] # Newest tasks top pe honge

# 3. Category Admin
class CategoryAdmin(admin.ModelAdmin):
    list_display = ['name', 'user']
    search_fields = ['name']




# Registering everything
admin.site.register(User, CustomUserAdmin)
admin.site.register(Task, TaskAdmin)
admin.site.register(Category, CategoryAdmin)
