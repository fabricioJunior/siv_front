import 'package:empresas/domain/data/repositories/i_empresas_repository.dart';

import '../entities/empresa.dart';

class SalvarEmpresa {
  final IEmpresasRepository _empresasRepository;

  SalvarEmpresa({required IEmpresasRepository empresasRepository})
      : _empresasRepository = empresasRepository;
  Future<Empresa> call({
    required Empresa empresa,
  }) async {
    return _empresasRepository.atualizarEmpresa(empresa);
  }
}
