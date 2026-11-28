import '../../../core/models/order_status.dart';
import '../../../core/models/pedido.dart';
import '../../../core/models/producto.dart';
import '../../../core/security/access_policy.dart';
import 'admin_order_repository.dart';
import 'admin_product_repository.dart';

class AdminOperationsService {
  final AdminProductRepository _productRepository;
  final AdminOrderRepository _orderRepository;

  const AdminOperationsService({
    required AdminProductRepository productRepository,
    required AdminOrderRepository orderRepository,
  })  : _productRepository = productRepository,
        _orderRepository = orderRepository;

  Future<List<Producto>> loadCatalog() => _productRepository.getAllProducts();

  Future<Producto> registerProduct({
    required UserRole? actorRole,
    required Producto producto,
  }) {
    return _productRepository.createProduct(
      actorRole: actorRole,
      producto: producto,
    );
  }

  Future<Producto> editProduct({
    required UserRole? actorRole,
    required Producto producto,
  }) {
    return _productRepository.updateProduct(
      actorRole: actorRole,
      producto: producto,
    );
  }

  Future<Producto> setProductStock({
    required UserRole? actorRole,
    required String idProducto,
    required int nuevoStock,
  }) {
    return _productRepository.updateStock(
      actorRole: actorRole,
      idProducto: idProducto,
      nuevoStock: nuevoStock,
    );
  }

  Future<Producto> markProductOutOfStock({
    required UserRole? actorRole,
    required String idProducto,
  }) {
    return _productRepository.updateStock(
      actorRole: actorRole,
      idProducto: idProducto,
      nuevoStock: 0,
    );
  }

  Future<Producto> setProductAvailability({
    required UserRole? actorRole,
    required String idProducto,
    required bool disponible,
  }) {
    return _productRepository.toggleAvailability(
      actorRole: actorRole,
      idProducto: idProducto,
      disponible: disponible,
    );
  }

  Future<List<Pedido>> loadOrders({
    required UserRole? actorRole,
    OrderStatus? filterByStatus,
  }) {
    return _orderRepository.getOrdersByStatus(
      actorRole: actorRole,
      status: filterByStatus,
    );
  }

  Future<Pedido> advanceOrderStatus({
    required UserRole? actorRole,
    required Pedido pedido,
  }) {
    final nextStatus = _nextSequentialStatus(pedido.estado);
    return _orderRepository.updateOrderStatus(
      actorRole: actorRole,
      idPedido: pedido.idPedido,
      nextStatus: nextStatus,
    );
  }

  Future<Pedido> setOrderStatus({
    required UserRole? actorRole,
    required String idPedido,
    required OrderStatus nextStatus,
  }) {
    return _orderRepository.updateOrderStatus(
      actorRole: actorRole,
      idPedido: idPedido,
      nextStatus: nextStatus,
    );
  }

  Future<Pedido> cancelOrder({
    required UserRole? actorRole,
    required String idPedido,
  }) {
    return _orderRepository.cancelOrder(
      actorRole: actorRole,
      idPedido: idPedido,
    );
  }

  OrderStatus _nextSequentialStatus(OrderStatus current) {
    switch (current) {
      case OrderStatus.recibido:
        return OrderStatus.enPreparacion;
      case OrderStatus.enPreparacion:
        return OrderStatus.listo;
      case OrderStatus.listo:
        return OrderStatus.entregado;
      case OrderStatus.entregado:
      case OrderStatus.cancelado:
        throw StateError(
          'El pedido ya se encuentra en estado final: ${current.firestoreValue}.',
        );
    }
  }
}