# Contratos Técnicos — APP CAFETESE (Christian Agustín Luna García)

## 1. Colecciones y campos en Cloud Firestore
- `productos`: `idProducto` (String), `nombre` (String), `precio` (double), `stock` (int), `disponible` (bool).
- `pedidos`: `usuarioId` (String), `items` (Array), `total` (double / num), `estado` (String), `fechaCreacion` (Timestamp), `metodoPago` (String).

## 2. Estados de pedido (coordinación con Omar)
Valores exactos en Firestore:
- `recibido`
- `en_preparacion`
- `listo`
- `entregado`
- `cancelado`

Transiciones permitidas:
- `recibido` -> `en_preparacion` o `cancelado`
- `en_preparacion` -> `listo` o `cancelado`
- `listo` -> `entregado` o `cancelado`
- `entregado` y `cancelado` son estados finales (no regresan a `recibido`).

## 3. Disponibilidad e inventario (coordinación con Daniela y Georgina)
- Si `stock <= 0`, `disponible` debe ser `false`.
- La validación de existencias al confirmar el pedido se coordina con Georgina y la selección de productos con Daniela.

## 4. Roles y seguridad (coordinación con Aracely)
- Los alumnos solo consultan sus propios pedidos y no pueden modificar estados ni administrar productos.
- Las operaciones administrativas requieren validación de rol confiable (nunca confiada solo a la interfaz).