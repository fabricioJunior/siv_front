import 'package:pessoas/models.dart';

abstract class IFuncionariosRemoteDataSource {
  Future<List<Funcionario>> getFuncionarios();

  Future<Funcionario?> getFuncionario({
    required int idFuncionario,
  });

  Future<Funcionario> criarFuncionario({
    required Funcionario funcionario,
  });

  Future<Funcionario> atualizarFuncionario({
    required Funcionario funcionario,
  });

  Future<void> excluirFuncionario({
    required int idFuncionario,
  });
}
