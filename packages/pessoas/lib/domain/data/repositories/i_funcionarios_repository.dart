import 'package:pessoas/models.dart';

abstract class IFuncionariosRepository {
  Future<List<Funcionario>> recuperarFuncionarios();

  Future<Funcionario?> recuperarFuncionario({
    required int idFuncionario,
  });

  Future<Funcionario> novoFuncionario({
    required Funcionario funcionario,
  });

  Future<Funcionario> salvarFuncionario({
    required Funcionario funcionario,
  });

  Future<void> excluirFuncionario({
    required int idFuncionario,
  });
}
