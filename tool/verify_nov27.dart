import 'package:app_cafetese_5601/core/models/order_status.dart';
import 'package:app_cafetese_5601/core/models/pedido.dart';
import 'package:app_cafetese_5601/core/models/producto.dart';
import 'package:app_cafetese_5601/core/security/access_policy.dart';
import 'package:app_cafetese_5601/features/admin/data/in_memory_admin_repository.dart';
import 'package:app_cafetese_5601/features/admin/domain/admin_operations_service.dart';

Future<void> main() async {
  final repo = InMemoryAdminRepository(
    initialProducts: [
      const Producto(
        idProducto: 'prod-01',
        nombre: 'Torta de milanesa',
        precio: 38.0,
        stock: 10,
        disponible: true,
      ),
    ],
    initialOrders: [
      Pedido(
        idPedido: 'ord-01',
        usuarioId: 'alumno-101',
        items: const [
          PedidoItem(
            idProducto: 'prod-01',
            nombre: 'Torta de milanesa',
            precioUnitario: 38.0,
            cantidad: 1,
          ),
        ],
        total: 38.0,
        estado: OrderStatus.recibido,
        fechaCreacion: DateTime(2026, 11, 27, 10, 0),
      ),
    ],
  );

  final service = AdminOperationsService(
    productRepository: repo,
    orderRepository: repo,
  );

  // 1. Stock en 0 debe forzar disponible = false
  final sinStock = await service.markProductOutOfStock(
    actorRole: UserRole.admin,
    idProducto: 'prod-01',
  );
  assert(sinStock.stock == 0 && sinStock.disponible == false);

  // 2. No permitir activar disponibilidad si stock es 0
  var bloqueoActivacion = false;
  try {
    await service.setProductAvailability(
      actorRole: UserRole.admin,
      idProducto: 'prod-01',
      disponible: true,
    );
  } on AdminValidationException {
    bloqueoActivacion = true;
  }
  assert(bloqueoActivacion);

  // 3. Bloquear acciones admin a un rol alumno
  var bloqueoAlumno = false;
  try {
    await service.loadOrders(actorRole: UserRole.alumno);
  } on AdminPermissionException {
    bloqueoAlumno = true;
  }
  assert(bloqueoAlumno);

  // 4. Avanzar estado del pedido: recibido -> en_preparacion -> listo -> entregado
  var pedido = (await service.loadOrders(actorRole: UserRole.admin)).first;
  pedido = await service.advanceOrderStatus(
    actorRole: UserRole.admin,
    pedido: pedido,
  );
  assert(pedido.estado == OrderStatus.enPreparacion);

  pedido = await service.advanceOrderStatus(
    actorRole: UserRole.admin,
    pedido: pedido,
  );
  assert(pedido.estado == OrderStatus.listo);

  pedido = await service.advanceOrderStatus(
    actorRole: actorRoleAdmin(),
    pedido: pedido,
  );
  assert(pedido.estado == OrderStatus.entregado);

  print('OK: Verificacion del 27 de noviembre completada.');
}

UserRole actorRoleAdmin() => UserRole.admin;