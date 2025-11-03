import 'package:autenticacao/data.dart';
import 'package:autenticacao/domain/models/empresa.dart';
import 'package:core/data_sourcers.dart';

import 'dtos/empresa_dto.dart';

class EmpresaDaSessaoLocalDataSource
    extends IsarLocalDataSourceBase<EmpresaDto, Empresa>
    implements IEmpresaDaSessaoLocalDataSource<EmpresaDto> {
  EmpresaDaSessaoLocalDataSource({required super.getIsar});

  @override
  EmpresaDto toDto(Empresa entity) {
    return entity.toDto();
  }
}

extension _ToDto on Empresa {
  EmpresaDto toDto() => EmpresaDto(id: id, nome: nome);
}
