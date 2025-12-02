import 'package:restauran/models/cliente.dart'; // 1. Importar el nuevo modelo

class Pedido {
  final int pedidoId;
  final int? repartidorId;
  final String estadoPedido;
  final String descripcionPedido;
  final String direccionEntrega;
  final double montoTotal;
  final String? instruccionesEntrega;
  final DateTime fechaCreacion;
  final Cliente cliente; // 2. Añadir el objeto cliente
  final double? latitudCliente;
  final double? longitudCliente;

  Pedido({
    required this.pedidoId,
    this.repartidorId,
    required this.estadoPedido,
    required this.descripcionPedido,
    required this.direccionEntrega,
    required this.montoTotal,
    this.instruccionesEntrega,
    required this.fechaCreacion,
    required this.cliente,
    this.latitudCliente,
    this.longitudCliente,
  });

  factory Pedido.fromJson(Map<String, dynamic> json) {
    return Pedido(
      pedidoId: json['pedido_id'],
      repartidorId: json['repartidor_id'],
      estadoPedido: json['estado_pedido'],
      descripcionPedido: json['descripcion_pedido'],
      direccionEntrega: json['direccion_entrega'],
      montoTotal: (json['monto_total'] as num).toDouble(),
      instruccionesEntrega: json['instrucciones_entrega'],
      fechaCreacion: DateTime.parse(json['fecha_creacion']),
      cliente: Cliente.fromJson(json['cliente']),
      latitudCliente: json['latitud_cliente'] != null
          ? (json['latitud_cliente'] as num).toDouble()
          : null,
      longitudCliente: json['longitud_cliente'] != null
          ? (json['longitud_cliente'] as num).toDouble()
          : null,
    );
  }
}
