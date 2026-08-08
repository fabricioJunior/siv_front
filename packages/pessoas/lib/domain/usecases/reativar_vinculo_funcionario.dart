import 'package:pessoas/domain/data/repositories/i_funcionarios_repository.dart';

class ReativarVinculoFuncionario {
  final IFuncionariosRepository _funcionariosRepository;

  ReativarVinculoFuncionario({
    required IFuncionariosRepository funcionariosRepository,
  }) : _funcionariosRepository = funcionariosRepository;

  Future<void> call({
    required int idFuncionario,
    required int idEmpresa,
  }) {
    return _funcionariosRepository.reativarVinculo(
      idFuncionario: idFuncionario,
      idEmpresa: idEmpresa,
    );
  }
}
