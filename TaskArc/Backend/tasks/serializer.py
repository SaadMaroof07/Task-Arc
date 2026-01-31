from rest_framework import serializers
from .models import User
from django.contrib.auth.hashers import make_password
from .models import Category, Task

class UserSerializer(serializers.ModelSerializer):
    # Password sirf bhej sakte hain (write_only), wapas response mein nahi dikhega
    password = serializers.CharField(
        write_only=True, 
        required=True, 
        style={'input_type': 'password'}
    )

    class Meta:
        model = User
        fields = ['id', 'username', 'email', 'password', 'role', 'phone_number']

    # Industry Logic: Email validation
    def validate_email(self, value):
        if User.objects.filter(email=value).exists():
            raise serializers.ValidationError("Yeh email pehle se register hai.")
        return value

    # Password hashing logic
    def create(self, validated_data):
        validated_data['password'] = make_password(validated_data['password'])
        return super(UserSerializer, self).create(validated_data)

    # Password hashing for updates (agar user password change kare)
    def update(self, instance, validated_data):
        if 'password' in validated_data:
            validated_data['password'] = make_password(validated_data['password'])
        return super(UserSerializer, self).update(instance, validated_data)
    

class CategorySerializer(serializers.ModelSerializer):
    class Meta:
        model = Category
        fields = ['id', 'name', 'user']
        read_only_fields = ['user'] # User automatically backend se set hoga


class TaskSerializer(serializers.ModelSerializer):
    # Category ka naam dikhane ke liye (Read Only)
    category_name = serializers.ReadOnlyField(source='category.name')
    # Priority ka label dikhane ke liye (e.g., 'M' ki jagah 'Medium')
    priority_display = serializers.CharField(source='get_priority_display', read_only=True)

    class Meta:
        model = Task
        fields = [
            'id', 'user', 'category', 'category_name', 
            'title', 'description', 'is_completed', 
            'priority', 'priority_display', 'created_at', 'due_date'
        ]
        read_only_fields = ['user', 'created_at'] # User backend se auto-set hoga        