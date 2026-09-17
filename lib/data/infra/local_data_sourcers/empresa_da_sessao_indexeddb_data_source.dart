import 'package:autenticacao/data.dart';
import 'package:autenticacao/domain/models/empresa.dart';
import 'package:core/data_sourcers.dart';

import 'dtos/empresa_hive_dto.dart';

class EmpresaDaSessaoIndexedDbDataSource
    extends IndexedDbLocalDataSourceBase<EmpresaHiveDto, Empresa>
    implements IEmpresaDaSessaoLocalDataSource<EmpresaHiveDto> {
  EmpresaDaSessaoIndexedDbDataSource({required super.getDb})
      : super(
          storeName: 'common_data_EmpresaHiveDto',
          fromStorage: EmpresaHiveDto.fromStorage,
        );

  @override
  EmpresaHiveDto toDto(Empresa entity) {
    return EmpresaHiveDto(id: entity.id, nome: entity.nome);
  }
}
