import 'leituras_entrada_pendentes.dart';

abstract class ILeiturasEntradaLocalDataSource {
  Future<LeiturasEntradaPendentes?> recuperar(int pedidoId);

  Future<void> salvar(LeiturasEntradaPendentes leituras);

  Future<void> apagar(int pedidoId);
}
