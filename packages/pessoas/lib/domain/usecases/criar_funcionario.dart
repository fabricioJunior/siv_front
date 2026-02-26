import 'package:pessoas/domain/data/repositories/i_funcionarios_repository.dart';
import 'package:pessoas/models.dart';

class CriarFuncionario {
  final IFuncionariosRepository _funcionariosRepository;

  CriarFuncionario({required IFuncionariosRepository funcionariosRepository})
      : _funcionariosRepository = funcionariosRepository;

  Future<Funcionario> call({required Funcionario funcionario}) {
    return _funcionariosRepository.novoFuncionario(funcionario: funcionario);
  }
}
