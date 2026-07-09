import 'package:comercial/data.dart';
import 'package:comercial/models.dart';
import 'package:core/remote_data_sourcers.dart';

class ReceberRomaneioNoCaixaRemoteDataSource extends RemoteDataSourceBase
    implements IReceberRomaneioNoCaixaRemoteDataSource {
  ReceberRomaneioNoCaixaRemoteDataSource(
      {required super.informacoesParaRequest});

  @override
  String get path => '/v1/caixas/{caixaId}/receber/romaneio';

  @override
  Future<void> receberRomaneio({
    required int caixaId,
    required int romaneioId,
    required List<RomaneioPagamentoRealizado> formasDePagamentoRealizadas,
    List<Map<String, dynamic>> descontosItens = const [],
    bool incluirCpfNaNota = true,
    String cpfNaNota = '',
  }) async {
    final formasDePagamento = formasDePagamentoRealizadas
        .map((forma) => _formaDePagamentoToJson(forma))
        .toList(growable: false);

    await post(
      pathParameters: {'caixaId': caixaId},
      body: {
        'romaneioId': romaneioId,
        if (formasDePagamento.isNotEmpty)
          'formasDePagamento': formasDePagamento,
        if (descontosItens.isNotEmpty) 'descontosItens': descontosItens,
        'incluirCpfNaNota': incluirCpfNaNota,
        if (incluirCpfNaNota && cpfNaNota.trim().isNotEmpty)
          'cpfNaNota': cpfNaNota.trim(),
      },
    );
  }

  Map<String, dynamic> _formaDePagamentoToJson(
      RomaneioPagamentoRealizado forma) {
    return {
      'controle': forma.controle,
      'formaDePagamentoId': forma.formaDePagamentoId,
      'parcela': forma.parcela,
      'valor': forma.valor,
    };
  }
}
