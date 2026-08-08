import 'package:promocoes/domain/models/elegibilidade.dart';

abstract class IElegibilidadeRemoteDataSource {
  Future<ResultadoElegibilidade> apurar({
    int? clienteId,
    required List<ItemApuracaoElegibilidade> itens,
    String? codigoCupom,
  });
}
