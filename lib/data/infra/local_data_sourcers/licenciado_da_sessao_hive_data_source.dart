import 'package:autenticacao/data.dart';
import 'package:autenticacao/models.dart';
import 'package:core/data_sourcers.dart';

import 'dtos/licenciado_hive_dto.dart';

class LicenciadoDaSessaoHiveDataSource
    extends HiveLocalDataSourceBase<LicenciadoHiveDto, Licenciado>
    implements ILicenciadoDaSessaoLocalDataSource<LicenciadoHiveDto> {
  LicenciadoDaSessaoHiveDataSource({required super.getBox});

  @override
  LicenciadoHiveDto toDto(Licenciado entity) {
    return LicenciadoHiveDto(
      id: entity.id,
      nome: entity.nome,
      urlApi: entity.urlApi,
    );
  }
}
