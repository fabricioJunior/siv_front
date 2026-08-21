import 'package:core/equals.dart';

class Comunicado extends Equatable {
  final int id;
  final int empresaId;
  final String assunto;
  final String corpoHtml;
  final bool modoHtmlAvancado;
  final Map<String, dynamic>? filtroAplicado;
  final int totalDestinatarios;
  final String status; // pendente, enviando, enviado, erro
  final int criadoPor;
  final DateTime? enviadoEm;
  final DateTime criadoEm;
  final DateTime atualizadoEm;

  const Comunicado({
    required this.id,
    required this.empresaId,
    required this.assunto,
    required this.corpoHtml,
    required this.modoHtmlAvancado,
    this.filtroAplicado,
    required this.totalDestinatarios,
    required this.status,
    required this.criadoPor,
    this.enviadoEm,
    required this.criadoEm,
    required this.atualizadoEm,
  });

  factory Comunicado.fromJson(Map<String, dynamic> json) {
    return Comunicado(
      id: json['id'] as int,
      empresaId: json['empresaId'] as int,
      assunto: json['assunto'] as String,
      corpoHtml: json['corpoHtml'] as String,
      modoHtmlAvancado: json['modoHtmlAvancado'] as bool? ?? false,
      filtroAplicado: (json['filtroAplicado'] as Map?)?.cast<String, dynamic>(),
      totalDestinatarios: json['totalDestinatarios'] as int? ?? 0,
      status: json['status'] as String,
      criadoPor: json['criadoPor'] as int,
      enviadoEm: json['enviadoEm'] != null
          ? DateTime.parse(json['enviadoEm'] as String)
          : null,
      criadoEm: DateTime.parse(json['criadoEm'] as String),
      atualizadoEm: DateTime.parse(json['atualizadoEm'] as String),
    );
  }

  @override
  List<Object?> get props => [
    id,
    empresaId,
    assunto,
    corpoHtml,
    modoHtmlAvancado,
    filtroAplicado,
    totalDestinatarios,
    status,
    criadoPor,
    enviadoEm,
    criadoEm,
    atualizadoEm,
  ];
}
