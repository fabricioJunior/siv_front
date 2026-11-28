import 'dart:typed_data';

import 'package:comercial/domain/models/pedido_entrada.dart';

/// Fotos de produtos contados sem referência (agrupadas pela descrição).
abstract class IFotosLivresRemoteDataSource {
  Future<EntradaResumo> adicionar(
    int pedidoId, {
    required String descricao,
    required String origem,
    required Uint8List bytes,
    required String fileName,
  });

  Future<EntradaResumo> remover(int pedidoId, int fotoId);
}
