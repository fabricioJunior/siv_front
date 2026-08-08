import 'package:promocoes/domain/data/remote/i_promocoes_remote_data_source.dart';
import 'package:promocoes/domain/data/repositories/i_promocoes_repository.dart';
import 'package:promocoes/domain/models/promocao.dart';

class PromocoesRepository implements IPromocoesRepository {
  final IPromocoesRemoteDataSource remoteDataSource;

  PromocoesRepository({required this.remoteDataSource});

  @override
  Future<Promocao> atualizarPromocao(Promocao promocao) {
    return remoteDataSource.atualizarPromocao(promocao);
  }

  @override
  Future<Promocao> criarPromocao(Promocao promocao) {
    return remoteDataSource.criarPromocao(promocao);
  }

  @override
  Future<Promocao?> recuperarPromocao(int id) {
    return remoteDataSource.recuperarPromocao(id);
  }

  @override
  Future<List<Promocao>> recuperarPromocoes({
    String? nome,
    bool? ativa,
    bool? vigente,
  }) {
    return remoteDataSource.recuperarPromocoes(
      nome: nome,
      ativa: ativa,
      vigente: vigente,
    );
  }
}
