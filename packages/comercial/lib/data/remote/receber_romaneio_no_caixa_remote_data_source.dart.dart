import 'package:comercial/data.dart';
import 'package:comercial/data/remote/dtos/romaneio_dto.dart';
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
    double? desconto,
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
        // `desconto` (nível romaneio) SUBSTITUI o valor persistido no
        // backend (receber.service.ts: descontoGlobalAplicado =
        // romaneioDto.desconto quando informado, em vez de somar). Não
        // enviar junto com `descontosItens` representando o mesmo valor --
        // contaria em dobro.
        if (desconto != null) 'desconto': desconto,
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

class CorrigirFormaDePagamentoRemoteDataSource extends RemoteDataSourceBase
    implements ICorrigirFormaDePagamentoRemoteDataSource {
  CorrigirFormaDePagamentoRemoteDataSource(
      {required super.informacoesParaRequest});

  @override
  String get path => '/v1/caixas/{caixaId}/receber/romaneio/forma-pagamento';

  @override
  Future<Romaneio> corrigirFormaDePagamento({
    required int caixaId,
    required int romaneioId,
    required List<Map<String, dynamic>> pagamentos,
  }) async {
    final response = await put(
      pathParameters: {'caixaId': caixaId},
      body: {
        'romaneioId': romaneioId,
        'pagamentos': pagamentos,
      },
    );
    return RomaneioDto.fromJson(response.body as Map<String, dynamic>);
  }
}
