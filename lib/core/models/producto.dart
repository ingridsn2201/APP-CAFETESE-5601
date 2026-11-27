import '../constants/firestore_paths.dart';

class Producto {
  final String idProducto;
  final String nombre;
  final double precio;
  final int stock;
  final bool disponible;

  Producto({
    required this.idProducto,
    required this.nombre,
    required this.precio,
    required this.stock,
    required bool disponible,
  }) : disponible = stock <= 0 ? false : disponible;

  Map<String, dynamic> toMap() {
    return {
      FirestorePaths.fieldIdProducto: idProducto,
      FirestorePaths.fieldNombre: nombre,
      FirestorePaths.fieldPrecio: precio,
      FirestorePaths.fieldStock: stock,
      FirestorePaths.fieldDisponible: disponible,
    };
  }

  factory Producto.fromMap(Map<String, dynamic> map, {String? docId}) {
    final rawPrecio = map[FirestorePaths.fieldPrecio];
    final rawStock = map[FirestorePaths.fieldStock];
    final rawDisponible = map[FirestorePaths.fieldDisponible];

    final parsedPrecio = rawPrecio is num
        ? rawPrecio.toDouble()
        : double.tryParse(rawPrecio?.toString() ?? '') ?? 0.0;

    final parsedStock = rawStock is int
        ? rawStock
        : int.tryParse(rawStock?.toString() ?? '') ?? 0;

    final parsedDisponible = rawDisponible is bool ? rawDisponible : false;

    return Producto(
      idProducto: (map[FirestorePaths.fieldIdProducto] ?? docId ?? '').toString(),
      nombre: (map[FirestorePaths.fieldNombre] ?? '').toString(),
      precio: parsedPrecio < 0 ? 0.0 : parsedPrecio,
      stock: parsedStock < 0 ? 0 : parsedStock,
      disponible: parsedDisponible,
    );
  }

  Producto copyWith({
    String? idProducto,
    String? nombre,
    double? precio,
    int? stock,
    bool? disponible,
  }) {
    return Producto(
      idProducto: idProducto ?? this.idProducto,
      nombre: nombre ?? this.nombre,
      precio: precio ?? this.precio,
      stock: stock ?? this.stock,
      disponible: disponible ?? this.disponible,
    );
  }
}