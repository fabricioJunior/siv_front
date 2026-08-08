import 'package:promocoes/domain/data/remote/i_elegibilidade_remote_data_source.dart';
import 'package:promocoes/domain/data/repositories/i_elegibilidade_repository.dart';
import 'package:promocoes/domain/models/elegibilidade.dart';

class ElegibilidadeRepository implements IElegibilidadeRepository {
  final IElegibilidadeRemoteDataSource remoteDataSource;

  ElegibilidadeRepository({required this.remoteDataSource});

  @override
  Future<ResultadoElegibilidade> apurar({
    int? clienteId,
    required List<ItemApuracaoElegibilidade> itens,
    String? codigoCupom,
  }) {
    return remoteDataSource.apurar(
      clienteId: clienteId,
      itens: itens,
      codigoCupom: codigoCupom,
    );
  }
}
