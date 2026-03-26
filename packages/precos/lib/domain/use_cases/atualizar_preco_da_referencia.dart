import 'package:precos/models.dart';
import 'package:precos/repositorios.dart';

class AtualizarPrecoDaReferencia {
  final IPrecosDeReferenciasRepository _precosDeReferenciasRepository;

  AtualizarPrecoDaReferencia({
    required IPrecosDeReferenciasRepository precosDeReferenciasRepository,
  }) : _precosDeReferenciasRepository = precosDeReferenciasRepository;

  Future<PrecoDaReferencia> call({
    required int tabelaDePrecoId,
    required int referenciaId,
    required double valor,
  }) {
    return _precosDeReferenciasRepository.atualizarPrecoDaReferencia(
      tabelaDePrecoId: tabelaDePrecoId,
      referenciaId: referenciaId,
      valor: valor,
    );
  }
}
