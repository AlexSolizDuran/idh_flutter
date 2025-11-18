class Cliente {
  final int clienteId;
  final int telegramUserId;
  final String? nombreTelegram;

  Cliente({
    required this.clienteId,
    required this.telegramUserId,
    this.nombreTelegram,
  });

  factory Cliente.fromJson(Map<String, dynamic> json) {
    return Cliente(
      clienteId: json['cliente_id'],
      telegramUserId: json['telegram_user_id'],
      nombreTelegram: json['nombre_telegram'],
    );
  }
}
