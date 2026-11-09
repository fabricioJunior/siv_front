class Notificacao {
  final int id;
  final String tipo;
  final String titulo;
  final String corpo;
  final Map<String, dynamic>? payload;
  final DateTime criadoEm;
  final DateTime? lidaEm;

  const Notificacao({
    required this.id,
    required this.tipo,
    required this.titulo,
    required this.corpo,
    this.payload,
    required this.criadoEm,
    this.lidaEm,
  });

  factory Notificacao.fromJson(Map<String, dynamic> json) {
    final payload = json['payload'];
    return Notificacao(
      id: (json['id'] as num).toInt(),
      tipo: json['tipo'] as String? ?? '',
      titulo: json['titulo'] as String? ?? '',
      corpo: json['corpo'] as String? ?? '',
      payload: payload is Map ? Map<String, dynamic>.from(payload) : null,
      criadoEm:
          DateTime.tryParse(json['criadoEm'] as String? ?? '') ??
          DateTime.now(),
      lidaEm: DateTime.tryParse(json['lidaEm'] as String? ?? ''),
    );
  }
}
