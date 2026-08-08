import 'package:pessoas/domain/data/repositories/i_funcionarios_repository.dart';
import 'package:pessoas/models.dart';

class VincularEmpresaFuncionario {
  final IFuncionariosRepository _funcionariosRepository;

  VincularEmpresaFuncionario({
    required IFuncionariosRepository funcionariosRepository,
  }) : _funcionariosRepository = funcionariosRepository;

  Future<FuncionarioEmpresaVinculo> call({
    required int idFuncionario,
    required int idEmpresa,
  }) {
    return _funcionariosRepository.vincularEmpresa(
      idFuncionario: idFuncionario,
      idEmpresa: idEmpresa,
    );
  }
}
