import 'package:precos/models.dart';
import 'package:precos/repositorios.dart';

class ObterPrecoDaReferencia {
  final IPrecosDeReferenciasRepository _precosDeReferenciasRepository;

  ObterPrecoDaReferencia({
    required IPrecosDeReferenciasRepository precosDeReferenciasRepository,
  }) : _precosDeReferenciasRepository = precosDeReferenciasRepository;

  Future<PrecoDaReferencia> call({
    required int tabelaDePrecoId,
    required int referenciaId,
  }) {
    return _precosDeReferenciasRepository.obterPrecoDaReferencia(
      tabelaDePrecoId: tabelaDePrecoId,
      referenciaId: referenciaId,
    );
  }
}
