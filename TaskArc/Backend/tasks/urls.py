from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import UserViewSet # Humne jo ViewSet banaya tha
from .views import CategoryViewSet
from .views import TaskViewSet


# Router automatically saare raste (GET, POST, PUT, DELETE) bana deta hai
router = DefaultRouter()
router.register('user', UserViewSet, basename='user')
router.register('categories', CategoryViewSet, basename='category')
router.register('tasks', TaskViewSet, basename='task')

# Abhi humne sirf UserViewSet register kiya hai, 
# baad mein isi router mein tasks aur categories bhi add karenge.

urlpatterns = [
    path('', include(router.urls)),
]