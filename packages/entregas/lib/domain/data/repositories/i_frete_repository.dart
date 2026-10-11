import 'package:entregas/domain/models/frete.dart';

abstract class IFreteRepository {
  Future<ConfiguracaoFrete> getConfiguracao();

  Future<List<String>> getTransportadoras();

  Future<void> salvarTransportadoras({
    required bool ativo,
    required List<String> transportadoras,
  });
}
