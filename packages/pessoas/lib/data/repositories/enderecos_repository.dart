import 'package:pessoas/domain/data/data_sourcers/remote/i_enderecos_remote_data_source.dart';
import 'package:pessoas/domain/data/repositories/i_enderecos_repository.dart';
import 'package:pessoas/models.dart';

class EnderecosRepository implements IEnderecosRepository {
  final IEnderecosRemoteDataSource _enderecosRemoteDataSource;

  EnderecosRepository({
    required IEnderecosRemoteDataSource enderecosRemoteDataSource,
  }) : _enderecosRemoteDataSource = enderecosRemoteDataSource;

  @override
  Future<void> excluirEndereco(
      {required int idPessoa, required int idEndereco}) {
    return _enderecosRemoteDataSource.excluirEndereco(
      idPessoa: idPessoa,
      idEndereco: idEndereco,
    );
  }

  @override
  Future<List<Endereco>> recuperarEnderecos({required int idPessoa}) {
    return _enderecosRemoteDataSource.getEnderecos(idPessoa: idPessoa);
  }

  @override
  Future<Endereco> novoEndereco({
    required int idPessoa,
    required Endereco endereco,
  }) {
    return _enderecosRemoteDataSource.criarEndereco(
      idPessoa: idPessoa,
      endereco: endereco,
    );
  }

  @override
  Future<Endereco> salvarEndereco({
    required int idPessoa,
    required Endereco endereco,
  }) {
    return _enderecosRemoteDataSource.atualizarEndereco(
      idPessoa: idPessoa,
      endereco: endereco,
    );
  }
}
