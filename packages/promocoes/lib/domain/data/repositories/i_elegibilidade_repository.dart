import 'package:promocoes/domain/models/elegibilidade.dart';

abstract class IElegibilidadeRepository {
  Future<ResultadoElegibilidade> apurar({
    int? clienteId,
    required List<ItemApuracaoElegibilidade> itens,
    List<String> codigosCupom = const [],
  });
}
