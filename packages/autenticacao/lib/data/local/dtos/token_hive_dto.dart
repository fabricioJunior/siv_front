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
    // IndexedDB (web) exige valor "structured-clone safe" -- `DateTime` vira
    // ISO-8601 (Hive aceitava o objeto binário direto).
    'dataDeCriacao': dataDeCriacao.toIso8601String(),
    'dataDeExpiracao': dataDeExpiracao.toIso8601String(),
    'idEmpresa': idEmpresa,
    'refreshToken': refreshToken,
  };

  static TokenHiveDto fromStorage(Map<String, dynamic> props) {
    return TokenHiveDto(
      jwtToken: props['jwtToken'] as String,
      dataDeCriacao: DateTime.parse(props['dataDeCriacao'] as String),
      dataDeExpiracao: DateTime.parse(props['dataDeExpiracao'] as String),
      idEmpresa: props['idEmpresa'] as int?,
      refreshToken: props['refreshToken'] as String?,
    );
  }
}
