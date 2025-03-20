import 'package:core/equals.dart';

class Usuario extends Equatable {
  final int id;
  final DateTime criadoEm;
  final DateTime atualizadoEm;
  final String login;
  final String nome;
  final String tipo;

  const Usuario({
    required this.id,
    required this.criadoEm,
    required this.atualizadoEm,
    required this.login,
    required this.nome,
    required this.tipo,
  });

  @override
  List<Object?> get props => [
        id,
        criadoEm,
        atualizadoEm,
        login,
        nome,
        tipo,
      ];
}
