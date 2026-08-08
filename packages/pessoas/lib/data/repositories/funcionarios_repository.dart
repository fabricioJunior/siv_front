import 'package:pessoas/domain/data/data_sourcers/remote/i_funcionarios_remote_data_source.dart';
import 'package:pessoas/domain/data/repositories/i_funcionarios_repository.dart';
import 'package:pessoas/models.dart';

class FuncionariosRepository implements IFuncionariosRepository {
  final IFuncionariosRemoteDataSource _funcionariosRemoteDataSource;

  FuncionariosRepository({
    required IFuncionariosRemoteDataSource funcionariosRemoteDataSource,
  }) : _funcionariosRemoteDataSource = funcionariosRemoteDataSource;

  @override
  Future<Funcionario?> recuperarFuncionario({required int idFuncionario}) {
    return _funcionariosRemoteDataSource.getFuncionario(
      idFuncionario: idFuncionario,
    );
  }

  @override
  Future<List<Funcionario>> recuperarFuncionarios({int? pessoaId}) {
    return _funcionariosRemoteDataSource.getFuncionarios(pessoaId: pessoaId);
  }

  @override
  Future<void> excluirFuncionario({required int idFuncionario}) {
    return _funcionariosRemoteDataSource.excluirFuncionario(
      idFuncionario: idFuncionario,
    );
  }

  @override
  Future<Funcionario> novoFuncionario({
    required Funcionario funcionario,
    required int empresaId,
  }) {
    return _funcionariosRemoteDataSource.criarFuncionario(
      funcionario: funcionario,
      empresaId: empresaId,
    );
  }

  @override
  Future<Funcionario> salvarFuncionario({required Funcionario funcionario}) {
    return _funcionariosRemoteDataSource.atualizarFuncionario(
      funcionario: funcionario,
    );
  }

  @override
  Future<List<FuncionarioEmpresaVinculo>> recuperarVinculosDoFuncionario({
    required int idFuncionario,
  }) {
    return _funcionariosRemoteDataSource.getVinculosDoFuncionario(
      idFuncionario: idFuncionario,
    );
  }

  @override
  Future<FuncionarioEmpresaVinculo> vincularEmpresa({
    required int idFuncionario,
    required int idEmpresa,
  }) {
    return _funcionariosRemoteDataSource.vincularEmpresa(
      idFuncionario: idFuncionario,
      idEmpresa: idEmpresa,
    );
  }

  @override
  Future<void> desativarVinculo({
    required int idFuncionario,
    required int idEmpresa,
  }) {
    return _funcionariosRemoteDataSource.desativarVinculo(
      idFuncionario: idFuncionario,
      idEmpresa: idEmpresa,
    );
  }

  @override
  Future<void> reativarVinculo({
    required int idFuncionario,
    required int idEmpresa,
  }) {
    return _funcionariosRemoteDataSource.reativarVinculo(
      idFuncionario: idFuncionario,
      idEmpresa: idEmpresa,
    );
  }
}
