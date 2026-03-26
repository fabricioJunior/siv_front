import 'package:precos/models.dart';
import 'package:precos/repositorios.dart';

class RecuperarPrecosDasReferencias {
  final IPrecosDeReferenciasRepository _precosDeReferenciasRepository;

  RecuperarPrecosDasReferencias({
    required IPrecosDeReferenciasRepository precosDeReferenciasRepository,
  }) : _precosDeReferenciasRepository = precosDeReferenciasRepository;

  Future<List<PrecoDaReferencia>> call({required int tabelaDePrecoId}) {
    return _precosDeReferenciasRepository.obterPrecosDasReferencias(
      tabelaDePrecoId: tabelaDePrecoId,
    );
  }
}
