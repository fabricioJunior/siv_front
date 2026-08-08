import 'package:pessoas/domain/data/repositories/i_funcionarios_repository.dart';
import 'package:pessoas/models.dart';

class RecuperarVinculosFuncionario {
  final IFuncionariosRepository _funcionariosRepository;

  RecuperarVinculosFuncionario({
    required IFuncionariosRepository funcionariosRepository,
  }) : _funcionariosRepository = funcionariosRepository;

  Future<List<FuncionarioEmpresaVinculo>> call({
    required int idFuncionario,
  }) {
    return _funcionariosRepository.recuperarVinculosDoFuncionario(
      idFuncionario: idFuncionario,
    );
  }
}
