import 'package:autenticacao/data/local/dtos/token_dto.dart';
import 'package:autenticacao/domain/data/data_sourcers/local/i_token_local_data_source.dart';
import 'package:autenticacao/models.dart';
import 'package:core/data_sourcers.dart';

class TokenLocalDataSource extends IsarLocalDataSourceBase<TokenDto, Token>
    implements ITokenLocalDataSource<TokenDto> {
  TokenLocalDataSource({required super.getIsar});

  @override
  TokenDto toDto(Token entity) {
    return TokenDto(
      jwtToken: entity.jwtToken,
      dataDeCriacao: entity.dataDeCriacao,
      dataDeExpiracao: entity.dataDeExpiracao,
      idEmpresa: entity.idEmpresa,
      refreshToken: entity.refreshToken,
    );
  }
}
