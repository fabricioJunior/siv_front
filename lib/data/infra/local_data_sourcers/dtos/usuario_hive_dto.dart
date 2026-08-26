import 'package:autenticacao/models.dart';
import 'package:core/hive_anotacoes.dart';

// typeId alocados no app (HiveType global, nunca reusar). Ver o mapa
// completo em lib/hive_storage_types.dart.
class UsuarioHiveDto implements Usuario, HiveDto, StorageEntity {
  @override
  final int id;

  @override
  final String login;

  @override
  final String nome;

  @override
  final TipoUsuario tipo;

  @override
  final String? senha;

  @override
  final bool ativo;

  UsuarioHiveDto({
    required this.id,
    required this.login,
    required this.nome,
    required this.tipo,
    required this.senha,
    this.ativo = true,
  });

  @override
  int get dataBaseId => id;

  @override
  Map<String, dynamic> get storageProperties => {
    'id': id,
    'login': login,
    'nome': nome,
    'tipoIndex': tipo.index,
    'senha': senha,
    'ativo': ativo,
  };

  static UsuarioHiveDto fromStorage(Map<String, dynamic> props) {
    return UsuarioHiveDto(
      id: props['id'] as int,
      login: props['login'] as String,
      nome: props['nome'] as String,
      tipo: TipoUsuario.values[props['tipoIndex'] as int],
      senha: props['senha'] as String?,
      ativo: props['ativo'] as bool,
    );
  }

  @override
  List<Object?> get props => [id, nome, tipo, login, ativo];

  @override
  bool? get stringify => true;
}
