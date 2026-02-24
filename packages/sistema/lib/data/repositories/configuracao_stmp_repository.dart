import 'package:sistema/domain/data/data_sourcers/remote/i_configuracao_stmp_remote_data_source.dart';
import 'package:sistema/domain/data/repositories/i_configuracao_stmp_repository.dart';
import 'package:sistema/domain/models/configuracao_stmp.dart';

class ConfiguracaoSTMPRepository implements IConfiguracaoSTMPRepository {
  final IConfiguracaoSTMPRemoteDataSource remoteDataSource;

  ConfiguracaoSTMPRepository({required this.remoteDataSource});

  @override
  Future<ConfiguracaoSTMP?> recuperarConfiguracao() {
    return remoteDataSource.recuperarConfiguracao();
  }

  @override
  Future<ConfiguracaoSTMP> criarConfiguracao(ConfiguracaoSTMP configuracao) {
    return remoteDataSource.criarConfiguracao(configuracao);
  }

  @override
  Future<ConfiguracaoSTMP> atualizarConfiguracao(
      ConfiguracaoSTMP configuracao) {
    return remoteDataSource.atualizarConfiguracao(configuracao);
  }

  @override
  Future<bool> verificarConexao() {
    return remoteDataSource.verificarConexao();
  }
}
