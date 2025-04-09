import 'package:empresas/domain/data/repositories/i_empresas_repository.dart';

import '../entities/empresa.dart';

class RecuperarEmpresas {
  final IEmpresasRepository _empresasRepository;

  RecuperarEmpresas({
    required IEmpresasRepository empresasRepository,
  }) : _empresasRepository = empresasRepository;

  Future<List<Empresa>> call() => _empresasRepository.getEmpresas();
}
