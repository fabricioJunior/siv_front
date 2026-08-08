import 'package:promocoes/domain/models/promocao.dart';

abstract class IPromocoesRemoteDataSource {
  Future<List<Promocao>> recuperarPromocoes({
    String? nome,
    bool? ativa,
    bool? vigente,
  });

  Future<Promocao?> recuperarPromocao(int id);

  Future<Promocao> criarPromocao(Promocao promocao);

  Future<Promocao> atualizarPromocao(Promocao promocao);
}
