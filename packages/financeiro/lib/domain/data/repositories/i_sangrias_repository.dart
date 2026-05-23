import 'package:financeiro/domain/models/sangria.dart';

abstract class ISangriasRepository {
  Future<Sangria> criarSangria({
    required int caixaId,
    required double valor,
    required String descricao,
    required String origem,
  });

  Future<List<Sangria>> recuperarSangrias({required int caixaId});

  Future<Sangria> recuperarSangria({
    required int caixaId,
    required int sangriaId,
  });

  Future<void> cancelarSangria({
    required int caixaId,
    required int sangriaId,
    required String motivo,
  });
}
