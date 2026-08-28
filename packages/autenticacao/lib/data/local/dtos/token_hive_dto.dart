import 'package:autenticacao/domain/models/token.dart';
import 'package:core/hive_anotacoes.dart';

// Tabela de typeIds em lib/hive_storage_types.dart (raiz do app siv_front).
class TokenHiveDto extends Token with HiveDto<Token>, StorageEntity {
  TokenHiveDto({
    required super.jwtToken,
    required super.dataDeCriacao,
    required super.dataDeExpiracao,
    super.idEmpresa,
    super.refreshToken,
  });

  @override
  int get dataBaseId => hiveHash(jwtToken);

  @override
  Map<String, dynamic> get storageProperties => {
    'jwtToken': jwtToken,
    'dataDeCriacao': dataDeCriacao,
    'dataDeExpiracao': dataDeExpiracao,
    'idEmpresa': idEmpresa,
    'refreshToken': refreshToken,
  };

  static TokenHiveDto fromStorage(Map<String, dynamic> props) {
    return TokenHiveDto(
      jwtToken: props['jwtToken'] as String,
      dataDeCriacao: props['dataDeCriacao'] as DateTime,
      dataDeExpiracao: props['dataDeExpiracao'] as DateTime,
      idEmpresa: props['idEmpresa'] as int?,
      refreshToken: props['refreshToken'] as String?,
    );
  }
}
