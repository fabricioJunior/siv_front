import 'package:autenticacao/domain/models/terminal_do_usuario.dart';

class TerminalDoUsuarioDto implements TerminalDoUsuario {
  @override
  final int id;

  @override
  final int idEmpresa;

  @override
  final String nome;

  const TerminalDoUsuarioDto({
    required this.id,
    required this.idEmpresa,
    required this.nome,
  });

  factory TerminalDoUsuarioDto.fromJson(Map<String, dynamic> json) {
    return TerminalDoUsuarioDto(
      id: (json['id'] as num).toInt(),
      idEmpresa: ((json['empresaId'] ?? json['idEmpresa']) as num).toInt(),
      nome: json['nome']?.toString() ?? '',
    );
  }

  @override
  List<Object?> get props => [id, idEmpresa, nome];

  @override
  bool? get stringify => true;
}
