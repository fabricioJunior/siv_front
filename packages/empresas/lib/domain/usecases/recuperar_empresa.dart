import 'package:empresas/domain/data/repositories/i_empresas_repository.dart';
import 'package:empresas/domain/entities/empresa.dart';

class RecuperarEmpresa {
  final IEmpresasRepository empresasRepository;

  RecuperarEmpresa({required this.empresasRepository});

  Future<Empresa?> call(int idEmpresa) async {
    return empresasRepository.getEmpresa(idEmpresa);
  }
}
