class Repartidor {
  final int repartidorId;
  final String nombreCompleto;
  final String email;
  final String edad;
  final String? telefono;
  final String estadoDisponibilidad;
  final DateTime fechaCreacion;

  Repartidor({
    required this.repartidorId,
    required this.nombreCompleto,
    required this.email,
    required this.edad,
    this.telefono,
    required this.estadoDisponibilidad,
    required this.fechaCreacion,
  });

  factory Repartidor.fromJson(Map<String, dynamic> json) {
    return Repartidor(
      repartidorId: json['repartidor_id'],
      nombreCompleto: json['nombre_completo'],
      email: json['email'],
      edad: json['edad'],
      telefono: json['telefono'],
      estadoDisponibilidad: json['estado_disponibilidad'],
      fechaCreacion: DateTime.parse(json['fecha_creacion']),
    );
  }
}
