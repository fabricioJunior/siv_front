import 'package:autenticacao/domain/models/terminal_do_usuario.dart';
import 'package:core/isar_anotacoes.dart';

part 'terminal_da_sessao_dto.g.dart';

@Collection(ignore: {'props', 'stringify'})
class TerminalDaSessaoDto implements TerminalDoUsuario, IsarDto {
  @override
  final int id;

  @override
  final int idEmpresa;

  @override
  final String nome;

  @override
  Id get dataBaseId => id;

  const TerminalDaSessaoDto({
    required this.id,
    required this.idEmpresa,
    required this.nome,
  });

  @override
  List<Object?> get props => [id, idEmpresa, nome];

  @override
  bool? get stringify => true;
}
