import '../../../core/models/order_status.dart';
import '../../../core/models/pedido.dart';
import '../../../core/security/access_policy.dart';

abstract class AdminOrderRepository {
  /// Obtiene todos los pedidos si el rol tiene permiso de consulta global
  Future<List<Pedido>> getAllOrders({
    required UserRole? actorRole,
  });

  /// Filtra pedidos por estado específico (o devuelve todos si status es null)
  Future<List<Pedido>> getOrdersByStatus({
    required UserRole? actorRole,
    OrderStatus? status,
  });

  /// Actualiza el estado de un pedido validando rol y transiciones permitidas
  Future<Pedido> updateOrderStatus({
    required UserRole? actorRole,
    required String idPedido,
    required OrderStatus nextStatus,
  });

  /// Cancela un pedido activo si el estado actual lo permite
  Future<Pedido> cancelOrder({
    required UserRole? actorRole,
    required String idPedido,
  });
}