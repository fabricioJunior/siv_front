import 'package:autenticacao/data.dart';
import 'package:autenticacao/models.dart';
import 'package:core/data_sourcers.dart';

import 'dtos/licenciado_dto.dart';

class LicenciadoDaSessaoLocalDataSource
    extends IsarLocalDataSourceBase<LicenciadoDto, Licenciado>
    implements ILicenciadoDaSessaoLocalDataSource<LicenciadoDto> {
  LicenciadoDaSessaoLocalDataSource({required super.getIsar});

  @override
  LicenciadoDto toDto(Licenciado entity) {
    return entity.toDto();
  }
}

extension _ToDto on Licenciado {
  LicenciadoDto toDto() => LicenciadoDto(
        id: id,
        nome: nome,
        urlApi: urlApi,
      );
}
