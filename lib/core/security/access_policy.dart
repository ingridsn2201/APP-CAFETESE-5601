enum UserRole {
  alumno,
  admin;

  static UserRole fromString(String? rawRole) {
    switch (rawRole?.trim().toLowerCase()) {
      case 'admin':
      case 'administrador':
        return UserRole.admin;
      case 'alumno':
      case 'estudiante':
      default:
        return UserRole.alumno;
    }
  }
}

class AccessPolicy {
  AccessPolicy._();

  /// Solo el rol admin puede crear/editar productos o cambiar disponibilidad
  static bool canManageProducts(UserRole? role) {
    return role == UserRole.admin;
  }

  /// Solo el rol admin puede actualizar el estado de pedidos
  static bool canUpdateOrderStatus(UserRole? role) {
    return role == UserRole.admin;
  }

  /// Admin ve todos los pedidos; alumno solo los propios
  static bool canViewAllOrders(UserRole? role) {
    return role == UserRole.admin;
  }

  static bool canViewOrder({
    required UserRole? role,
    required String? currentUserId,
    required String orderOwnerId,
  }) {
    if (currentUserId == null || currentUserId.isEmpty) {
      return false;
    }
    if (role == UserRole.admin) {
      return true;
    }
    return currentUserId == orderOwnerId;
  }
}