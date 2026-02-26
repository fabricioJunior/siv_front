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
  Future<List<Funcionario>> recuperarFuncionarios() {
    return _funcionariosRemoteDataSource.getFuncionarios();
  }

  @override
  Future<void> excluirFuncionario({required int idFuncionario}) {
    return _funcionariosRemoteDataSource.excluirFuncionario(
      idFuncionario: idFuncionario,
    );
  }

  @override
  Future<Funcionario> novoFuncionario({required Funcionario funcionario}) {
    return _funcionariosRemoteDataSource.criarFuncionario(
      funcionario: funcionario,
    );
  }

  @override
  Future<Funcionario> salvarFuncionario({required Funcionario funcionario}) {
    return _funcionariosRemoteDataSource.atualizarFuncionario(
      funcionario: funcionario,
    );
  }
}
