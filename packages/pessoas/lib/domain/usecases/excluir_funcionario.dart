import 'package:pessoas/domain/data/repositories/i_funcionarios_repository.dart';

class ExcluirFuncionario {
  final IFuncionariosRepository _funcionariosRepository;

  ExcluirFuncionario({required IFuncionariosRepository funcionariosRepository})
      : _funcionariosRepository = funcionariosRepository;

  Future<void> call({required int idFuncionario}) {
    return _funcionariosRepository.excluirFuncionario(
      idFuncionario: idFuncionario,
    );
  }
}
