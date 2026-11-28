import '../../../core/constants/firestore_paths.dart';
import '../../../core/models/order_status.dart';
import '../../../core/models/pedido.dart';
import '../../../core/models/producto.dart';
import '../../../core/security/access_policy.dart';
import '../domain/admin_order_repository.dart';
import '../domain/admin_product_repository.dart';

class AdminPermissionException implements Exception {
  final String message;
  const AdminPermissionException(this.message);

  @override
  String toString() => 'AdminPermissionException: $message';
}

class AdminValidationException implements Exception {
  final String message;
  const AdminValidationException(this.message);

  @override
  String toString() => 'AdminValidationException: $message';
}

class InMemoryAdminRepository
    implements AdminProductRepository, AdminOrderRepository {
  final Map<String, Producto> _products = {};
  final Map<String, Pedido> _orders = {};

  InMemoryAdminRepository({
    List<Producto>? initialProducts,
    List<Pedido>? initialOrders,
  }) {
    for (final p in initialProducts ?? const <Producto>[]) {
      _products[p.idProducto] = _normalizeProduct(p);
    }
    for (final o in initialOrders ?? const <Pedido>[]) {
      _orders[o.idPedido] = o;
    }
  }

  Producto _normalizeProduct(Producto producto) {
    final cleanName = producto.nombre.trim();
    if (cleanName.isEmpty) {
      throw const AdminValidationException('El nombre del producto es obligatorio.');
    }
    if (producto.precio < 0) {
      throw const AdminValidationException('El precio no puede ser negativo.');
    }
    final cleanStock = producto.stock < 0 ? 0 : producto.stock;
    final cleanAvailable = cleanStock <= 0 ? false : producto.disponible;

    return producto.copyWith(
      nombre: cleanName,
      stock: cleanStock,
      disponible: cleanAvailable,
    );
  }

  void _requireAdmin(UserRole? role, String actionDescription) {
    if (!AccessPolicy.canManageProducts(role) &&
        role != UserRole.admin) {
      throw AdminPermissionException(
        'Acceso denegado para: $actionDescription.',
      );
    }
  }

  @override
  Future<List<Producto>> getAllProducts() async {
    return _products.values.toList(growable: false);
  }

  @override
  Future<Producto> createProduct({
    required UserRole? actorRole,
    required Producto producto,
  }) async {
    _requireAdmin(actorRole, 'crear productos');
    if (producto.idProducto.trim().isEmpty) {
      throw const AdminValidationException('El idProducto es obligatorio.');
    }
    if (_products.containsKey(producto.idProducto)) {
      throw AdminValidationException(
        'Ya existe un producto con el id ${producto.idProducto}.',
      );
    }
    final normalized = _normalizeProduct(producto);
    _products[normalized.idProducto] = normalized;
    return normalized;
  }

  @override
  Future<Producto> updateProduct({
    required UserRole? actorRole,
    required Producto producto,
  }) async {
    _requireAdmin(actorRole, 'editar productos');
    if (!_products.containsKey(producto.idProducto)) {
      throw AdminValidationException(
        'No se encontró el producto ${producto.idProducto}.',
      );
    }
    final normalized = _normalizeProduct(producto);
    _products[normalized.idProducto] = normalized;
    return normalized;
  }

  @override
  Future<Producto> updateStock({
    required UserRole? actorRole,
    required String idProducto,
    required int nuevoStock,
  }) async {
    _requireAdmin(actorRole, 'actualizar stock');
    final existing = _products[idProducto];
    if (existing == null) {
      throw AdminValidationException('No se encontró el producto $idProducto.');
    }
    if (nuevoStock < 0) {
      throw const AdminValidationException('El stock no puede ser negativo.');
    }

    final updated = existing.copyWith(
      stock: nuevoStock,
      disponible: nuevoStock > 0 ? existing.disponible : false,
    );
    _products[idProducto] = updated;
    return updated;
  }

  @override
  Future<Producto> toggleAvailability({
    required UserRole? actorRole,
    required String idProducto,
    required bool disponible,
  }) async {
    _requireAdmin(actorRole, 'cambiar disponibilidad');
    final existing = _products[idProducto];
    if (existing == null) {
      throw AdminValidationException('No se encontró el producto $idProducto.');
    }
    if (disponible && existing.stock <= 0) {
      throw const AdminValidationException(
        'No se puede marcar como disponible un producto sin stock.',
      );
    }

    final updated = existing.copyWith(disponible: disponible);
    _products[idProducto] = updated;
    return updated;
  }

  @override
  Future<List<Pedido>> getAllOrders({required UserRole? actorRole}) async {
    if (!AccessPolicy.canViewAllOrders(actorRole)) {
      throw const AdminPermissionException(
        'Solo el rol admin puede consultar todos los pedidos.',
      );
    }
    return _orders.values.toList(growable: false);
  }

  @override
  Future<List<Pedido>> getOrdersByStatus({
    required UserRole? actorRole,
    OrderStatus? status,
  }) async {
    final all = await getAllOrders(actorRole: actorRole);
    if (status == null) {
      return all;
    }
    return all
        .where((order) => order.estado.firestoreValue == status.firestoreValue)
        .toList(growable: false);
  }

  @override
  Future<Pedido> updateOrderStatus({
    required UserRole? actorRole,
    required String idPedido,
    required OrderStatus nextStatus,
  }) async {
    if (!AccessPolicy.canUpdateOrderStatus(actorRole)) {
      throw const AdminPermissionException(
        'Solo el rol admin puede actualizar el estado de pedidos.',
      );
    }
    final existing = _orders[idPedido];
    if (existing == null) {
      throw AdminValidationException('No se encontró el pedido $idPedido.');
    }
    if (!existing.estado.canTransitionTo(nextStatus)) {
      throw AdminValidationException(
        'Transición inválida de ${existing.estado.firestoreValue} '
        '(${FirestorePaths.collectionPedidos}) a ${nextStatus.firestoreValue}.',
      );
    }

    final updated = existing.copyWith(estado: nextStatus);
    _orders[idPedido] = updated;
    return updated;
  }

  @override
  Future<Pedido> cancelOrder({
    required UserRole? actorRole,
    required String idPedido,
  }) async {
    return updateOrderStatus(
      actorRole: actorRole,
      idPedido: idPedido,
      nextStatus: OrderStatus.cancelado,
    );
  }
}