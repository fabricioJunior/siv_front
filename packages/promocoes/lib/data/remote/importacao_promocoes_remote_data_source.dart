import 'dart:io';
import 'dart:typed_data';

import 'package:core/remote_data_sourcers.dart';
import 'package:promocoes/domain/data/remote/i_importacao_promocoes_remote_data_source.dart';
import 'package:promocoes/domain/models/importacao_promocao.dart';
import 'package:promocoes/domain/models/promocao.dart';
import 'package:promocoes/domain/models/regra_desconto.dart';

class ImportacaoPromocoesRemoteDataSource extends RemoteDataSourceBase
    implements IImportacaoPromocoesRemoteDataSource {
  ImportacaoPromocoesRemoteDataSource({required super.informacoesParaRequest});

  // Consulta de status usa uma raiz diferente (`/v1/importacoes/:id`, endpoint
  // genérico já existente) da de template/upload (`/v1/importacao/promocoes`)
  // -- mesma técnica de override do datasource fiscal pra alternar a raiz
  // sem duas classes.
  bool _consultandoStatus = false;

  @override
  String get path => _consultandoStatus
      ? '/v1/importacoes{path}'
      : '/v1/importacao/promocoes{path}';

  @override
  Future<Uint8List> baixarTemplateCsv({required TipoDesconto tipoDesconto}) {
    return getBytes(
      pathParameters: {'path': '/template'},
      queryParameters: {'tipo': tipoDesconto.value},
    );
  }

  @override
  Future<ImportacaoPromocao> importarCsv({
    required String filePath,
    required String nome,
    required DateTime dataInicio,
    required DateTime dataFim,
    required TipoDesconto tipoDesconto,
    PromocaoCanal? canal,
  }) async {
    final response = await postFile(
      field: 'file',
      file: File(filePath),
      fileType: FileType.other,
      pathParameters: {'path': '/csv'},
      body: {
        'nome': nome,
        'dataInicio': _formatarData(dataInicio),
        'dataFim': _formatarData(dataFim),
        'tipoDesconto': tipoDesconto.value,
        if (canal != null) 'canal': canal.value,
      },
    );
    return ImportacaoPromocao.fromJson(response.body as Map<String, dynamic>);
  }

  @override
  Future<ImportacaoPromocao> consultarImportacao(int id) async {
    _consultandoStatus = true;
    try {
      final response = await get(pathParameters: {'path': '/$id'});
      return ImportacaoPromocao.fromJson(
        response.body as Map<String, dynamic>,
      );
    } finally {
      _consultandoStatus = false;
    }
  }

  String _formatarData(DateTime data) {
    final ano = data.year.toString().padLeft(4, '0');
    final mes = data.month.toString().padLeft(2, '0');
    final dia = data.day.toString().padLeft(2, '0');
    return '$ano-$mes-$dia';
  }
}
