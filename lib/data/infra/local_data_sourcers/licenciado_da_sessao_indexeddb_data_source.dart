import 'package:autenticacao/data.dart';
import 'package:autenticacao/models.dart';
import 'package:core/data_sourcers.dart';

import 'dtos/licenciado_hive_dto.dart';

class LicenciadoDaSessaoIndexedDbDataSource
    extends IndexedDbLocalDataSourceBase<LicenciadoHiveDto, Licenciado>
    implements ILicenciadoDaSessaoLocalDataSource<LicenciadoHiveDto> {
  LicenciadoDaSessaoIndexedDbDataSource({required super.getDb})
      : super(
          storeName: 'common_data_LicenciadoHiveDto',
          fromStorage: LicenciadoHiveDto.fromStorage,
        );

  @override
  LicenciadoHiveDto toDto(Licenciado entity) {
    return LicenciadoHiveDto(
      id: entity.id,
      nome: entity.nome,
      urlApi: entity.urlApi,
    );
  }
}
