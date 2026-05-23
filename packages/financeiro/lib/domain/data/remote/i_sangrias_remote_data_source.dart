import 'package:financeiro/domain/models/sangria.dart';

abstract class ISangriasRemoteDataSource {
  Future<Sangria> criarSangria({
    required int caixaId,
    required double valor,
    required String descricao,
    required String origem,
  });

  Future<List<Sangria>> recuperarSangrias({required int caixaId});

  Future<Sangria> recuperarSangria({
    required int sangriaId,
    required int caixaId,
  });

  Future<void> cancelarSangria({
    required int sangriaId,
    required int caixaId,
    required String motivo,
  });
}
