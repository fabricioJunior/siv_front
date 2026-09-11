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

// Endpoint próprio (path diferente) -- cria o romaneio, adiciona os itens e recebe no caixa em 1
// request só, substituindo o fluxo de 3+ chamadas (POST /romaneios, N x POST .../itens, POST
// .../receber/romaneio) usado hoje pra toda operação. Só serve venda (romaneio novo do zero) --
// ver CriarVendaCompletaDto no backend.
class CriarVendaCompletaRemoteDataSource extends RemoteDataSourceBase
    implements ICriarVendaCompletaRemoteDataSource {
  CriarVendaCompletaRemoteDataSource({required super.informacoesParaRequest});

  @override
  String get path => '/v1/caixas/{caixaId}/receber/venda-completa';

  @override
  Future<Romaneio> criarVendaCompleta({
    required int caixaId,
    int? pessoaId,
    required int funcionarioId,
    required int tabelaPrecoId,
    required List<RomaneioItem> itens,
    required List<RomaneioPagamentoRealizado> formasDePagamentoRealizadas,
    List<Map<String, dynamic>> descontosItens = const [],
    List<Map<String, dynamic>> descontosPromocao = const [],
    Map<String, dynamic>? cupom,
    double? valorTaxaEntrega,
    bool incluirCpfNaNota = true,
    String cpfNaNota = '',
    bool pontuarFidelidade = false,
    bool enviarNotaPorEmail = false,
    String emailNota = '',
  }) async {
    final response = await post(
      pathParameters: {'caixaId': caixaId},
      body: {
        if (pessoaId != null) 'pessoaId': pessoaId,
        'funcionarioId': funcionarioId,
        'tabelaPrecoId': tabelaPrecoId,
        'itens': itens
            .map((item) => {
                  'produtoId': item.produtoId,
                  'quantidade': item.quantidade,
                })
            .toList(growable: false),
        'formasDePagamento': formasDePagamentoRealizadas
            .map((forma) => {
                  'controle': forma.controle,
                  'formaDePagamentoId': forma.formaDePagamentoId,
                  'parcela': forma.parcela,
                  'valor': forma.valor,
                })
            .toList(growable: false),
        if (descontosItens.isNotEmpty) 'descontosItens': descontosItens,
        if (descontosPromocao.isNotEmpty)
          'descontosPromocao': descontosPromocao,
        if (cupom != null) 'cupom': cupom,
        if (valorTaxaEntrega != null) 'valorTaxaEntrega': valorTaxaEntrega,
        'incluirCpfNaNota': incluirCpfNaNota,
        if (incluirCpfNaNota && cpfNaNota.trim().isNotEmpty)
          'cpfNaNota': cpfNaNota.trim(),
        if (pontuarFidelidade) 'pontuarFidelidade': pontuarFidelidade,
        if (enviarNotaPorEmail) 'enviarNotaPorEmail': enviarNotaPorEmail,
        if (enviarNotaPorEmail && emailNota.trim().isNotEmpty)
          'emailNota': emailNota.trim(),
      },
    );
    return RomaneioDto.fromJson(response.body as Map<String, dynamic>);
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
