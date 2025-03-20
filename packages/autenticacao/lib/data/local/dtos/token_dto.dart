import 'package:autenticacao/domain/models/token.dart';
import 'package:core/isar_anotacoes.dart';
import 'package:core/local_data_sourcers/isar/isar_dto.dart';

part 'token_dto.g.dart';

@Collection(ignore: {'props'})
class TokenDto extends Token implements IsarDto {
  const TokenDto({
    required super.jwtToken,
    required super.dataDeCriacao,
    required super.dataDeExpiracao,
  });

  @override
  Id get dataBaseId => fastHash(jwtToken);
}
