import '../constants/firestore_paths.dart';
import 'order_status.dart';

class PedidoItem {
  final String idProducto;
  final String nombre;
  final double precioUnitario;
  final int cantidad;

  const PedidoItem({
    required this.idProducto,
    required this.nombre,
    required this.precioUnitario,
    required this.cantidad,
  });

  double get subtotal => precioUnitario * cantidad;

  Map<String, dynamic> toMap() {
    return {
      FirestorePaths.fieldIdProducto: idProducto,
      FirestorePaths.fieldNombre: nombre,
      FirestorePaths.fieldPrecio: precioUnitario,
      'cantidad': cantidad,
    };
  }

  factory PedidoItem.fromMap(Map<String, dynamic> map) {
    final rawPrecio = map[FirestorePaths.fieldPrecio];
    final rawCantidad = map['cantidad'];

    final precio = rawPrecio is num
        ? rawPrecio.toDouble()
        : double.tryParse(rawPrecio?.toString() ?? '') ?? 0.0;

    final cantidad = rawCantidad is int
        ? rawCantidad
        : int.tryParse(rawCantidad?.toString() ?? '') ?? 0;

    return PedidoItem(
      idProducto: (map[FirestorePaths.fieldIdProducto] ?? '').toString(),
      nombre: (map[FirestorePaths.fieldNombre] ?? '').toString(),
      precioUnitario: precio < 0 ? 0.0 : precio,
      cantidad: cantidad < 0 ? 0 : cantidad,
    );
  }
}

class Pedido {
  final String idPedido;
  final String usuarioId;
  final List<PedidoItem> items;
  final double total;
  final OrderStatus estado;
  final DateTime fechaCreacion;
  final String metodoPago;

  const Pedido({
    required this.idPedido,
    required this.usuarioId,
    required this.items,
    required this.total,
    required this.estado,
    required this.fechaCreacion,
    this.metodoPago = 'efectivo',
  });

  Map<String, dynamic> toMap() {
    return {
      FirestorePaths.fieldUsuarioId: usuarioId,
      FirestorePaths.fieldItems: items.map((item) => item.toMap()).toList(),
      FirestorePaths.fieldTotal: total,
      FirestorePaths.fieldEstado: estado.firestoreValue,
      FirestorePaths.fieldFechaCreacion: fechaCreacion.toIso8601String(),
      FirestorePaths.fieldMetodoPago: metodoPago,
    };
  }

  factory Pedido.fromMap(Map<String, dynamic> map, {String? docId}) {
    final rawTotal = map[FirestorePaths.fieldTotal];
    final parsedTotal = rawTotal is num
        ? rawTotal.toDouble()
        : double.tryParse(rawTotal?.toString() ?? '') ?? 0.0;

    final rawItems = map[FirestorePaths.fieldItems];
    final parsedItems = rawItems is List
        ? rawItems
            .whereType()
            .map((e) => PedidoItem.fromMap(Map<String, dynamic>.from(e)))
            .toList()
        : <PedidoItem>[];

    final rawFecha = map[FirestorePaths.fieldFechaCreacion];
    DateTime parsedFecha;
    if (rawFecha is DateTime) {
      parsedFecha = rawFecha;
    } else if (rawFecha != null) {
      parsedFecha = DateTime.tryParse(rawFecha.toString()) ?? DateTime.now();
    } else {
      parsedFecha = DateTime.now();
    }

    return Pedido(
      idPedido: (docId ?? map['idPedido'] ?? '').toString(),
      usuarioId: (map[FirestorePaths.fieldUsuarioId] ?? '').toString(),
      items: parsedItems,
      total: parsedTotal < 0 ? 0.0 : parsedTotal,
      estado: OrderStatus.fromString((map[FirestorePaths.fieldEstado] ?? '').toString()),
      fechaCreacion: parsedFecha,
      metodoPago: (map[FirestorePaths.fieldMetodoPago] ?? 'efectivo').toString(),
    );
  }

  Pedido copyWith({
    String? idPedido,
    String? usuarioId,
    List<PedidoItem>? items,
    double? total,
    OrderStatus? estado,
    DateTime? fechaCreacion,
    String? metodoPago,
  }) {
    return Pedido(
      idPedido: idPedido ?? this.idPedido,
      usuarioId: usuarioId ?? this.usuarioId,
      items: items ?? this.items,
      total: total ?? this.total,
      estado: estado ?? this.estado,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
      metodoPago: metodoPago ?? this.metodoPago,
    );
  }
}