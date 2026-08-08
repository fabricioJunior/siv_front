import 'package:pessoas/domain/data/repositories/i_funcionarios_repository.dart';

class DesativarVinculoFuncionario {
  final IFuncionariosRepository _funcionariosRepository;

  DesativarVinculoFuncionario({
    required IFuncionariosRepository funcionariosRepository,
  }) : _funcionariosRepository = funcionariosRepository;

  Future<void> call({
    required int idFuncionario,
    required int idEmpresa,
  }) {
    return _funcionariosRepository.desativarVinculo(
      idFuncionario: idFuncionario,
      idEmpresa: idEmpresa,
    );
  }
}
