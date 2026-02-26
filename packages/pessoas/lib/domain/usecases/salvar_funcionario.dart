import 'package:pessoas/domain/data/repositories/i_funcionarios_repository.dart';
import 'package:pessoas/models.dart';

class SalvarFuncionario {
  final IFuncionariosRepository _funcionariosRepository;

  SalvarFuncionario({required IFuncionariosRepository funcionariosRepository})
      : _funcionariosRepository = funcionariosRepository;

  Future<Funcionario> call({required Funcionario funcionario}) {
    return _funcionariosRepository.salvarFuncionario(funcionario: funcionario);
  }
}
