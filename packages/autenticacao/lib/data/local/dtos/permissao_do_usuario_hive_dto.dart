import 'package:autenticacao/models.dart';
import 'package:core/hive_anotacoes.dart';

// Tabela de typeIds em lib/hive_storage_types.dart (raiz do app siv_front).
class PermissaoDoUsuarioHiveDto extends PermissaoDoUsuario
    with HiveDto<PermissaoDoUsuario>, StorageEntity {
  PermissaoDoUsuarioHiveDto({
    required this.id,
    required this.empresaId,
    required this.grupoId,
    required this.grupoNome,
    required this.componenteId,
    required this.componenteNome,
    required this.descontinuado,
  });

  @override
  final int id;

  @override
  final int empresaId;

  @override
  final int grupoId;

  @override
  final String grupoNome;

  @override
  final String componenteId;

  @override
  final String componenteNome;

  @override
  final int descontinuado;

  @override
  int get dataBaseId => hiveHash(componenteId);

  @override
  Map<String, dynamic> get storageProperties => {
    'id': id,
    'empresaId': empresaId,
    'grupoId': grupoId,
    'grupoNome': grupoNome,
    'componenteId': componenteId,
    'componenteNome': componenteNome,
    'descontinuado': descontinuado,
  };

  static PermissaoDoUsuarioHiveDto fromStorage(Map<String, dynamic> props) {
    return PermissaoDoUsuarioHiveDto(
      id: props['id'] as int,
      empresaId: props['empresaId'] as int,
      grupoId: props['grupoId'] as int,
      grupoNome: props['grupoNome'] as String,
      componenteId: props['componenteId'] as String,
      componenteNome: props['componenteNome'] as String,
      descontinuado: props['descontinuado'] as int,
    );
  }
}
