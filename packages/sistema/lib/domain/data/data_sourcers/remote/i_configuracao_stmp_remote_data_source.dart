import 'package:sistema/domain/models/configuracao_stmp.dart';

abstract class IConfiguracaoSTMPRemoteDataSource {
  Future<ConfiguracaoSTMP?> recuperarConfiguracao();

  Future<ConfiguracaoSTMP> criarConfiguracao(
    ConfiguracaoSTMP configuracao,
  );

  Future<ConfiguracaoSTMP> atualizarConfiguracao(
    ConfiguracaoSTMP configuracao,
  );

  Future<bool> verificarConexao();
}
