from rest_framework import permissions

class IsAdminOrSelf(permissions.BasePermission):
    """
    Logic: 
    1. Admin ko full access hai.
    2. User sirf apni profile dekh aur update kar sakta hai.
    """
    def has_object_permission(self, request, view, obj):
        if request.user.is_authenticated:
            # Admin check
            if request.user.role == 'ADMIN':
                return True
            # Owner check
            return obj.id == request.user.id
        return False