import 'package:autenticacao/domain/models/terminal_do_usuario.dart';
import 'package:core/hive_anotacoes.dart';

// Tabela de typeIds em lib/hive_storage_types.dart.
class TerminalDaSessaoHiveDto
    implements TerminalDoUsuario, HiveDto, StorageEntity {
  @override
  final int id;

  @override
  final int idEmpresa;

  @override
  final String nome;

  const TerminalDaSessaoHiveDto({
    required this.id,
    required this.idEmpresa,
    required this.nome,
  });

  @override
  int get dataBaseId => id;

  @override
  Map<String, dynamic> get storageProperties => {
    'id': id,
    'idEmpresa': idEmpresa,
    'nome': nome,
  };

  static TerminalDaSessaoHiveDto fromStorage(Map<String, dynamic> props) {
    return TerminalDaSessaoHiveDto(
      id: props['id'] as int,
      idEmpresa: props['idEmpresa'] as int,
      nome: props['nome'] as String,
    );
  }

  @override
  List<Object?> get props => [id, idEmpresa, nome];

  @override
  bool? get stringify => true;
}
