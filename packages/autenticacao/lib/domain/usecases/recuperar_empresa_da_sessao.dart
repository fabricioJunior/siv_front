import 'package:autenticacao/domain/data/repositories/i_empresas_repository.dart';
import 'package:autenticacao/models.dart';

class RecuperarEmpresaDaSessao {
  final IEmpresasRepository empresasRepository;

  RecuperarEmpresaDaSessao({required this.empresasRepository});

  Future<Empresa?> call() {
    return empresasRepository.getEmpressaDaSessaoSalva();
  }
}
