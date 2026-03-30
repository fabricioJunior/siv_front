import 'package:autenticacao/models.dart';
import 'package:core/isar_anotacoes.dart';
import 'package:core/local_data_sourcers/isar/isar_dto.dart';

part 'licenciado_dto.g.dart';

@Collection(ignore: {'props'})
class LicenciadoDto implements Licenciado, IsarDto {
  @override
  final String id;

  @override
  final String nome;

  @override
  final String urlApi;

  const LicenciadoDto({
    required this.id,
    required this.nome,
    required this.urlApi,
  });

  @override
  Id get dataBaseId => _idToIsarId(id);

  @override
  List<Object?> get props => [id, nome, urlApi];

  @override
  bool? get stringify => true;
}

int _idToIsarId(String value) {
  int hash = 17;
  for (final code in value.codeUnits) {
    hash = 37 * hash + code;
  }
  return hash;
}
