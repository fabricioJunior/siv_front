import 'package:sistema/domain/models/configuracao_stmp.dart';

abstract class IConfiguracaoSTMPRepository {
  Future<ConfiguracaoSTMP?> recuperarConfiguracao();

  Future<ConfiguracaoSTMP> criarConfiguracao(
    ConfiguracaoSTMP configuracao,
  );

  Future<ConfiguracaoSTMP> atualizarConfiguracao(
    ConfiguracaoSTMP configuracao,
  );

  Future<bool> verificarConexao();
}
