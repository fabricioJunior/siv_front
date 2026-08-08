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
    double? valorTaxaEntrega,
    List<Map<String, dynamic>> descontosItens = const [],
    List<Map<String, dynamic>> descontosPromocao = const [],
    Map<String, dynamic>? cupom,
    bool incluirCpfNaNota = true,
    String cpfNaNota = '',
    bool pontuarFidelidade = false,
    bool enviarNotaPorEmail = false,
    String emailNota = '',
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
        if (valorTaxaEntrega != null) 'valorTaxaEntrega': valorTaxaEntrega,
        if (descontosItens.isNotEmpty) 'descontosItens': descontosItens,
        if (descontosPromocao.isNotEmpty)
          'descontosPromocao': descontosPromocao,
        if (cupom != null) 'cupom': cupom,
        'incluirCpfNaNota': incluirCpfNaNota,
        if (incluirCpfNaNota && cpfNaNota.trim().isNotEmpty)
          'cpfNaNota': cpfNaNota.trim(),
        if (pontuarFidelidade) 'pontuarFidelidade': pontuarFidelidade,
        if (enviarNotaPorEmail) 'enviarNotaPorEmail': enviarNotaPorEmail,
        if (enviarNotaPorEmail && emailNota.trim().isNotEmpty)
          'emailNota': emailNota.trim(),
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
