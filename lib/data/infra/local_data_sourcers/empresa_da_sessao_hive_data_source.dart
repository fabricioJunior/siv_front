import 'package:autenticacao/data.dart';
import 'package:autenticacao/domain/models/empresa.dart';
import 'package:core/data_sourcers.dart';

import 'dtos/empresa_hive_dto.dart';

class EmpresaDaSessaoHiveDataSource
    extends HiveLocalDataSourceBase<EmpresaHiveDto, Empresa>
    implements IEmpresaDaSessaoLocalDataSource<EmpresaHiveDto> {
  EmpresaDaSessaoHiveDataSource({required super.getBox});

  @override
  EmpresaHiveDto toDto(Empresa entity) {
    return EmpresaHiveDto(id: entity.id, nome: entity.nome);
  }
}
