import 'package:pessoas/models.dart';

abstract class IFuncionariosRemoteDataSource {
  Future<List<Funcionario>> getFuncionarios({int? pessoaId});

  Future<Funcionario?> getFuncionario({
    required int idFuncionario,
  });

  Future<Funcionario> criarFuncionario({
    required Funcionario funcionario,
    required int empresaId,
  });

  Future<Funcionario> atualizarFuncionario({
    required Funcionario funcionario,
  });

  Future<void> excluirFuncionario({
    required int idFuncionario,
  });

  Future<List<FuncionarioEmpresaVinculo>> getVinculosDoFuncionario({
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
