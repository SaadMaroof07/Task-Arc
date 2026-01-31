from django.shortcuts import render
from rest_framework import viewsets, permissions, filters
from rest_framework.exceptions import ValidationError
from rest_framework.response import Response
from rest_framework.decorators import action
from rest_framework.permissions import AllowAny, IsAuthenticated
from .models import User,Category,Task
from .serializer import UserSerializer,CategorySerializer,TaskSerializer
from django_filters.rest_framework import DjangoFilterBackend
from .permissions import IsAdminOrSelf

class UserViewSet(viewsets.ModelViewSet):
    queryset = User.objects.all()
    serializer_class = UserSerializer

    # Industry Logic: Action ke hisab se permission change karna
    def get_permissions(self):
        if self.action == 'create': # Signup ke liye sab allowed hain
            return [AllowAny()]
        if self.action in ['update', 'partial_update', 'retrieve']: # Edit/View ke liye owner ya admin
            return [IsAdminOrSelf()]
        return [IsAuthenticated()] # Baqi sab (list/delete) ke liye login zaroori

    # Industry Logic: Admin ko sab dikhao, user ko sirf apni details
    def get_queryset(self):
        if self.request.user.is_authenticated:
            if self.request.user.role == 'ADMIN':
                return User.objects.all()
            return User.objects.filter(id=self.request.user.id)
        return User.objects.none()

    # Extra Action: Flutter app mein "Me" ya "Profile" api ke liye
    @action(detail=False, methods=['get'], permission_classes=[IsAuthenticated])
    def me(self, request):
        serializer = self.get_serializer(request.user)
        return Response(serializer.data)
    

class CategoryViewSet(viewsets.ModelViewSet):
    # 1. Base Queryset (Required for Router and Filters)
    queryset = Category.objects.all() 
    
    serializer_class = CategorySerializer
    permission_classes = [permissions.IsAuthenticated]
    
    filter_backends = [filters.SearchFilter, filters.OrderingFilter]
    search_fields = ['name']
    ordering = ['id']

    def get_queryset(self):
        # 2. Actual Filtering (Sirf login user ka data)
        # Yeh upar wali 'queryset' ko override kar dega runtime par
        return Category.objects.filter(user=self.request.user)

    def perform_create(self, serializer):
        name = serializer.validated_data.get('name')
        if Category.objects.filter(user=self.request.user, name__iexact=name).exists():
            raise ValidationError({"error": f"Category '{name}' pehle se maujood hai."})
        
        serializer.save(user=self.request.user)   


class TaskViewSet(viewsets.ModelViewSet):
    queryset = Task.objects.all()
    serializer_class = TaskSerializer
    permission_classes = [permissions.IsAuthenticated]
    
    # Advanced Filtering, Searching aur Ordering
    filter_backends = [DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter]
    filterset_fields = ['is_completed', 'priority', 'category']
    search_fields = ['title', 'description']
    ordering_fields = ['due_date', 'priority', 'created_at']
    ordering = ['due_date'] # Default order: Jo task pehle khatam karna hai wo upar

    def get_queryset(self):
        # Security: User ko sirf apne tasks nazar aayein
        return Task.objects.filter(user=self.request.user)

    def perform_create(self, serializer):
        # Security Check: Kya user apni hi category use kar raha hai?
        category = serializer.validated_data.get('category')
        if category and category.user != self.request.user:
            raise ValidationError({"error": "Aap dusre user ki category use nahi kar sakte!"})
        
        serializer.save(user=self.request.user)

    # Custom Action: Task status toggle karne ke liye (Flutter se call karna asaan hoga)
    @action(detail=True, methods=['post'])
    def toggle_status(self, request, pk=None):
        task = self.get_object()
        task.is_completed = not task.is_completed
        task.save()
        return Response({
            'status': 'Task status updated',
            'is_completed': task.is_completed
        })         