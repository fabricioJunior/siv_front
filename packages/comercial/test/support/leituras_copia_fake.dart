import 'package:core/leituras_entrada.dart';

class LeiturasCopiaFake implements ILeiturasEntradaLocalDataSource {
  final copias = <int, LeiturasEntradaPendentes>{};
  int salvamentos = 0;

  @override
  Future<LeiturasEntradaPendentes?> recuperar(int pedidoId) async =>
      copias[pedidoId];

  @override
  Future<void> salvar(LeiturasEntradaPendentes leituras) async {
    salvamentos++;
    copias[leituras.pedidoId] = leituras;
  }

  @override
  Future<void> apagar(int pedidoId) async => copias.remove(pedidoId);
}
