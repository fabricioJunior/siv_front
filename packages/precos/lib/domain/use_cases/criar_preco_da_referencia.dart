import 'package:precos/models.dart';
import 'package:precos/repositorios.dart';

class CriarPrecoDaReferencia {
  final IPrecosDeReferenciasRepository _precosDeReferenciasRepository;

  CriarPrecoDaReferencia({
    required IPrecosDeReferenciasRepository precosDeReferenciasRepository,
  }) : _precosDeReferenciasRepository = precosDeReferenciasRepository;

  Future<PrecoDaReferencia> call({
    required int tabelaDePrecoId,
    required int referenciaId,
    required double valor,
  }) {
    return _precosDeReferenciasRepository.criarPrecoDaReferencia(
      tabelaDePrecoId: tabelaDePrecoId,
      referenciaId: referenciaId,
      valor: valor,
    );
  }
}
