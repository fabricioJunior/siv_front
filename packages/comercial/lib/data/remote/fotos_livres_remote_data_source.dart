import 'dart:typed_data';

import 'package:comercial/domain/data/remote/i_fotos_livres_remote_data_source.dart';
import 'package:comercial/domain/models/pedido_entrada.dart';
import 'package:core/remote_data_sourcers.dart';

class FotosLivresRemoteDataSource extends RemoteDataSourceBase
    implements IFotosLivresRemoteDataSource {
  FotosLivresRemoteDataSource({required super.informacoesParaRequest});

  @override
  String get path => '/v1/pedidos{path}';

  String _caminho(int pedidoId) => '/$pedidoId/entrada/contagem-livre/fotos';

  @override
  Future<EntradaResumo> adicionar(
    int pedidoId, {
    required String descricao,
    required String origem,
    required Uint8List bytes,
    required String fileName,
  }) async =>
      EntradaResumo.fromJson(
        (await postFile(
          bytes: bytes,
          fileName: fileName,
          fileType: FileType.image,
          pathParameters: {'path': _caminho(pedidoId)},
          body: {'descricao': descricao, 'origem': origem},
        ))
            .body as Map<String, dynamic>,
      );

  @override
  Future<EntradaResumo> remover(int pedidoId, int fotoId) async =>
      EntradaResumo.fromJson(
        (await delete(
          pathParameters: {'path': '${_caminho(pedidoId)}/$fotoId'},
        ))
            .body as Map<String, dynamic>,
      );
}
