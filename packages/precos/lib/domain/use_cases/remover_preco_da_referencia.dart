import 'package:precos/repositorios.dart';

class RemoverPrecoDaReferencia {
  final IPrecosDeReferenciasRepository _precosDeReferenciasRepository;

  RemoverPrecoDaReferencia({
    required IPrecosDeReferenciasRepository precosDeReferenciasRepository,
  }) : _precosDeReferenciasRepository = precosDeReferenciasRepository;

  Future<void> call({required int tabelaDePrecoId, required int referenciaId}) {
    return _precosDeReferenciasRepository.removerPrecoDaReferencia(
      tabelaDePrecoId: tabelaDePrecoId,
      referenciaId: referenciaId,
    );
  }
}
