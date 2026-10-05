import 'dart:io';

import 'package:comercial/domain/data/remote/i_pedido_entrada_remote_data_source.dart';
import 'package:comercial/domain/models/pedido_entrada.dart';
import 'package:core/remote_data_sourcers.dart';

class PedidoEntradaRemoteDataSource extends RemoteDataSourceBase
    implements IPedidoEntradaRemoteDataSource {
  PedidoEntradaRemoteDataSource({required super.informacoesParaRequest});

  @override
  String get path => '/v1/pedidos{path}';

  EntradaResumo _resumo(dynamic body) =>
      EntradaResumo.fromJson(body as Map<String, dynamic>);

  String _linha(int pedidoId, int linhaId, String acao) =>
      '/$pedidoId/entrada/linhas/$linhaId/$acao';

  @override
  Future<EntradaResumo> importarNfe({
    required String filePath,
    required int tabelaPrecoId,
  }) async {
    final response = await postFile(
      field: 'file',
      bytes: await File(filePath).readAsBytes(),
      fileName: filePath.split(Platform.pathSeparator).last,
      fileType: FileType.other,
      pathParameters: {'path': '/entrada/nfe'},
      body: {'tabelaPrecoId': tabelaPrecoId.toString()},
    );
    return _resumo(response.body);
  }

  @override
  Future<EntradaResumo> criarPorContagem({
    required int pessoaId,
    required int tabelaPrecoId,
    String? observacao,
  }) async =>
      _resumo(
        (await post(
          body: {
            'pessoaId': pessoaId,
            'tabelaPrecoId': tabelaPrecoId,
            if (observacao != null) 'observacao': observacao,
          },
          pathParameters: {'path': '/entrada/contagem'},
        ))
            .body,
      );

  @override
  Future<EntradaResumo> obter(int pedidoId) async => _resumo(
        (await get(pathParameters: {'path': '/$pedidoId/entrada'})).body,
      );

  @override
  Future<EntradaResumo> vincularReferencia(
    int pedidoId,
    int linhaId,
    int referenciaId,
  ) async =>
      _resumo(
        (await put(
          body: {'referenciaId': referenciaId},
          pathParameters: {'path': _linha(pedidoId, linhaId, 'vinculo')},
        ))
            .body,
      );

  @override
  Future<EntradaResumo> preCadastrar(
    int pedidoId,
    int linhaId, {
    required int categoriaId,
    String? nome,
  }) async =>
      _resumo(
        (await post(
          body: {'categoriaId': categoriaId, if (nome != null) 'nome': nome},
          pathParameters: {'path': _linha(pedidoId, linhaId, 'pre-cadastro')},
        ))
            .body,
      );

  @override
  Future<EntradaResumo> ignorar(
    int pedidoId,
    int linhaId,
    bool ignorar,
  ) async =>
      _resumo(
        (await put(
          body: {'ignorar': ignorar},
          pathParameters: {'path': _linha(pedidoId, linhaId, 'ignorar')},
        ))
            .body,
      );

  @override
  Future<EntradaResumo> resolverDivergencia(
    int pedidoId,
    int linhaId,
    String? observacao,
  ) async =>
      _resumo(
        (await put(
          body: {if (observacao != null) 'observacao': observacao},
          pathParameters: {'path': _linha(pedidoId, linhaId, 'divergencia')},
        ))
            .body,
      );

  @override
  Future<EntradaResumo> registrarContagem(
    int pedidoId,
    List<ItemContagem> itens,
  ) async =>
      _resumo(
        (await put(
          body: {'itens': itens.map((i) => i.toJson()).toList()},
          pathParameters: {'path': '/$pedidoId/entrada/contagem'},
        ))
            .body,
      );
}
