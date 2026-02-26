import 'package:pessoas/domain/data/repositories/i_funcionarios_repository.dart';
import 'package:pessoas/models.dart';

class RecuperarFuncionarios {
  final IFuncionariosRepository _funcionariosRepository;

  RecuperarFuncionarios({
    required IFuncionariosRepository funcionariosRepository,
  }) : _funcionariosRepository = funcionariosRepository;

  Future<Iterable<Funcionario>> call() {
    return _funcionariosRepository.recuperarFuncionarios();
  }
}
