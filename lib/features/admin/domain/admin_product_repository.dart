import '../../../core/models/producto.dart';
import '../../../core/security/access_policy.dart';

abstract class AdminProductRepository {
  /// Obtiene el catálogo completo de productos para el panel administrativo
  Future<List<Producto>> getAllProducts();

  /// Crea un nuevo producto validando permisos de administrador
  Future<Producto> createProduct({
    required UserRole? actorRole,
    required Producto producto,
  });

  /// Actualiza los datos de un producto existente (nombre, precio, stock, disponibilidad)
  Future<Producto> updateProduct({
    required UserRole? actorRole,
    required Producto producto,
  });

  /// Actualiza únicamente el stock y recalcula disponibilidad automáticamente
  Future<Producto> updateStock({
    required UserRole? actorRole,
    required String idProducto,
    required int nuevoStock,
  });

  /// Cambia manualmente la disponibilidad (solo si hay stock > 0)
  Future<Producto> toggleAvailability({
    required UserRole? actorRole,
    required String idProducto,
    required bool disponible,
  });
}