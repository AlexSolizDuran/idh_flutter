class Vehiculo {
  final int vehiculoId;
  final String placa;
  final String? marca;
  final String? modelo;
  final String? color;
  final String tipo;
  final int repartidorId;

  Vehiculo({
    required this.vehiculoId,
    required this.placa,
    this.marca,
    this.modelo,
    this.color,
    required this.tipo,
    required this.repartidorId,
  });

  factory Vehiculo.fromJson(Map<String, dynamic> json) {
    return Vehiculo(
      vehiculoId: json['vehiculo_id'],
      placa: json['placa'],
      marca: json['marca'], // Dart maneja 'null' automáticamente aquí
      modelo: json['modelo'],
      color: json['color'],
      tipo: json['tipo'],
      repartidorId: json['repartidor_id'],
    );
  }
}
