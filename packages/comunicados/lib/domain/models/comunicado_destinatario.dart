import 'package:core/equals.dart';

class ComunicadoDestinatario extends Equatable {
  final int id;
  final int comunicadoId;
  final int pessoaId;
  final String emailDestino;
  final String status; // pendente, enviando, enviado, erro
  final String? erroMensagem;
  final int tentativas;
  final DateTime? enviadoEm;

  const ComunicadoDestinatario({
    required this.id,
    required this.comunicadoId,
    required this.pessoaId,
    required this.emailDestino,
    required this.status,
    this.erroMensagem,
    required this.tentativas,
    this.enviadoEm,
  });

  factory ComunicadoDestinatario.fromJson(Map<String, dynamic> json) {
    return ComunicadoDestinatario(
      id: json['id'] as int,
      comunicadoId: json['comunicadoId'] as int,
      pessoaId: json['pessoaId'] as int,
      emailDestino: json['emailDestino'] as String,
      status: json['status'] as String,
      erroMensagem: json['erroMensagem'] as String?,
      tentativas: json['tentativas'] as int? ?? 0,
      enviadoEm: json['enviadoEm'] != null
          ? DateTime.parse(json['enviadoEm'] as String)
          : null,
    );
  }

  @override
  List<Object?> get props => [
    id,
    comunicadoId,
    pessoaId,
    emailDestino,
    status,
    erroMensagem,
    tentativas,
    enviadoEm,
  ];
}

class PreviewDestinatarioComunicado extends Equatable {
  final int pessoaId;
  final String nome;
  final String email;

  const PreviewDestinatarioComunicado({
    required this.pessoaId,
    required this.nome,
    required this.email,
  });

  factory PreviewDestinatarioComunicado.fromJson(Map<String, dynamic> json) {
    return PreviewDestinatarioComunicado(
      pessoaId: json['pessoaId'] as int,
      nome: json['nome'] as String,
      email: json['email'] as String,
    );
  }

  @override
  List<Object?> get props => [pessoaId, nome, email];
}
