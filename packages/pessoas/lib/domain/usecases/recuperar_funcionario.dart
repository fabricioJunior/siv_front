import 'package:pessoas/domain/data/repositories/i_funcionarios_repository.dart';
import 'package:pessoas/models.dart';

class RecuperarFuncionario {
  final IFuncionariosRepository _funcionariosRepository;

  RecuperarFuncionario({
    required IFuncionariosRepository funcionariosRepository,
  }) : _funcionariosRepository = funcionariosRepository;

  Future<Funcionario?> call({required int idFuncionario}) {
    return _funcionariosRepository.recuperarFuncionario(
      idFuncionario: idFuncionario,
    );
  }
}
