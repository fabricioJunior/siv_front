import 'package:autenticacao/data/local/dtos/token_hive_dto.dart';
import 'package:autenticacao/domain/data/data_sourcers/local/i_token_local_data_source.dart';
import 'package:autenticacao/models.dart';
import 'package:core/data_sourcers.dart';

class TokenIndexedDbDataSource
    extends IndexedDbLocalDataSourceBase<TokenHiveDto, Token>
    implements ITokenLocalDataSource<TokenHiveDto> {
  TokenIndexedDbDataSource({required super.getDb})
      : super(
          storeName: 'autenticacao_TokenHiveDto',
          fromStorage: TokenHiveDto.fromStorage,
        );

  @override
  TokenHiveDto toDto(Token entity) {
    return TokenHiveDto(
      jwtToken: entity.jwtToken,
      dataDeCriacao: entity.dataDeCriacao,
      dataDeExpiracao: entity.dataDeExpiracao,
      idEmpresa: entity.idEmpresa,
      refreshToken: entity.refreshToken,
    );
  }
}
