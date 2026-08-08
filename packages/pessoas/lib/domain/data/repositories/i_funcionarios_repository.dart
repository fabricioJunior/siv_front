import 'package:pessoas/models.dart';

abstract class IFuncionariosRepository {
  Future<List<Funcionario>> recuperarFuncionarios({int? pessoaId});

  Future<Funcionario?> recuperarFuncionario({
    required int idFuncionario,
  });

  Future<Funcionario> novoFuncionario({
    required Funcionario funcionario,
    required int empresaId,
  });

  Future<Funcionario> salvarFuncionario({
    required Funcionario funcionario,
  });

  Future<void> excluirFuncionario({
    required int idFuncionario,
  });

  Future<List<FuncionarioEmpresaVinculo>> recuperarVinculosDoFuncionario({
    required int idFuncionario,
  });

  Future<FuncionarioEmpresaVinculo> vincularEmpresa({
    required int idFuncionario,
    required int idEmpresa,
  });

  Future<void> desativarVinculo({
    required int idFuncionario,
    required int idEmpresa,
  });

  Future<void> reativarVinculo({
    required int idFuncionario,
    required int idEmpresa,
  });
}
