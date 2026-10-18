import 'package:comercial/data/remote/dtos/relatorio_frequencia_clientes_dto.dart';
import 'package:comercial/domain/models/relatorio_frequencia_clientes.dart';
import 'package:comercial/data/remote/dtos/relatorio_movimentacoes_dto.dart';
import 'package:comercial/domain/models/relatorio_movimentacoes.dart';
import 'package:comercial/data/remote/dtos/relatorio_dto.dart';
import 'package:comercial/domain/data/remote/i_relatorio_remote_data_source.dart';
import 'package:comercial/domain/models/relatorios.dart';
import 'package:core/remote_data_sourcers.dart';

class RelatorioRemoteDataSource extends RemoteDataSourceBase
    implements IRelatorioRemoteDataSource {
  RelatorioRemoteDataSource({required super.informacoesParaRequest});

  @override
  String get path => '/v1/relatorios{path}';

  @override
  Future<RelatorioFaturamento> faturamento({
    required List<int> empresaIds,
    required String dataInicial,
    required String dataFinal,
  }) async {
    final response = await get(
      pathParameters: {'path': '/faturamento/ticket-medio'},
      queryParameters: {
        'empresaIds': empresaIds.join(','),
        'dataInicial': dataInicial,
        'dataFinal': dataFinal,
      },
    );
    return RelatorioFaturamentoDto.fromJson(
        response.body as Map<String, dynamic>);
  }

  @override
  Future<RelatorioFaturamentoComparativo> faturamentoComparativo({
    required List<int> empresaIds,
    required String dataInicial,
    required String dataFinal,
    required String agruparPor,
  }) async {
    final response = await get(
      pathParameters: {'path': '/faturamento/comparativo'},
      queryParameters: {
        'empresaIds': empresaIds.join(','),
        'dataInicial': dataInicial,
        'dataFinal': dataFinal,
        'agruparPor': agruparPor,
      },
    );
    return RelatorioFaturamentoComparativoDto.fromJson(
        response.body as Map<String, dynamic>);
  }

  @override
  Future<RelatorioCurvaAbc> curvaAbc({
    required List<int> empresaIds,
    required String dataInicial,
    required String dataFinal,
    String? busca,
    int page = 1,
    int limit = 100,
    String agruparPor = 'produto',
    List<int>? referenciaIds,
    List<int>? categoriaIds,
  }) async {
    final response = await get(
      pathParameters: {'path': '/produtos/curva-abc'},
      queryParameters: {
        'empresaIds': empresaIds.join(','),
        'dataInicial': dataInicial,
        'dataFinal': dataFinal,
        'page': '$page',
        'limit': '$limit',
        'agruparPor': agruparPor,
        if (busca != null && busca.isNotEmpty) 'busca': busca,
        if (referenciaIds != null && referenciaIds.isNotEmpty)
          'referenciaIds': referenciaIds.join(','),
        if (categoriaIds != null && categoriaIds.isNotEmpty)
          'categoriaIds': categoriaIds.join(','),
      },
    );
    return RelatorioCurvaAbcDto.fromJson(response.body as Map<String, dynamic>);
  }

  @override
  Future<RelatorioClientesAtivos> clientesAtivos({
    required List<int> empresaIds,
    required int dias,
    String? dataReferencia,
    int page = 1,
    int limit = 100,
  }) async {
    final response = await get(
      pathParameters: {'path': '/clientes/ativos'},
      queryParameters: {
        'empresaIds': empresaIds.join(','),
        'dias': '$dias',
        if (dataReferencia != null) 'dataReferencia': dataReferencia,
        'page': '$page',
        'limit': '$limit',
      },
    );
    return RelatorioClientesAtivosDto.fromJson(
        response.body as Map<String, dynamic>);
  }

  @override
  Future<RelatorioComprasClientes> comprasClientes({
    required List<int> empresaIds,
    required String dataInicial,
    required String dataFinal,
    String agruparPor = 'produto',
    List<int>? produtoIds,
    List<int>? referenciaIds,
    List<int>? categoriaIds,
    List<int>? corIds,
    List<int>? tamanhoIds,
    int page = 1,
    int limit = 100,
  }) async {
    final response = await get(
      pathParameters: {'path': '/clientes/compras'},
      queryParameters: {
        'empresaIds': empresaIds.join(','),
        'dataInicial': dataInicial,
        'dataFinal': dataFinal,
        'agruparPor': agruparPor,
        'page': '$page',
        'limit': '$limit',
        if (produtoIds != null && produtoIds.isNotEmpty)
          'produtoIds': produtoIds.join(','),
        if (referenciaIds != null && referenciaIds.isNotEmpty)
          'referenciaIds': referenciaIds.join(','),
        if (categoriaIds != null && categoriaIds.isNotEmpty)
          'categoriaIds': categoriaIds.join(','),
        if (corIds != null && corIds.isNotEmpty) 'corIds': corIds.join(','),
        if (tamanhoIds != null && tamanhoIds.isNotEmpty)
          'tamanhoIds': tamanhoIds.join(','),
      },
    );
    return RelatorioComprasClientesDto.fromJson(
        response.body as Map<String, dynamic>);
  }

  @override
  Future<List<RelatorioVendasPorFuncionarioItem>> vendasPorFuncionario({
    required List<int> empresaIds,
    required List<int> funcionarioIds,
    required String dataInicial,
    required String dataFinal,
  }) async {
    final response = await get(
      pathParameters: {'path': '/faturamento/vendas-por-funcionario'},
      queryParameters: {
        'empresaIds': empresaIds.join(','),
        'funcionarioIds': funcionarioIds.join(','),
        'dataInicial': dataInicial,
        'dataFinal': dataFinal,
      },
    );
    return RelatorioVendasPorFuncionarioItemDto.listFromJson(
        response.body as Map<String, dynamic>);
  }

  @override
  Future<RelatorioPontosFidelidade> pontosFidelidade({
    required List<int> empresaIds,
    String? situacaoCadastro,
    int page = 1,
    int limit = 100,
  }) async {
    final response = await get(
      pathParameters: {'path': '/fidelidade/pontos'},
      queryParameters: {
        'empresaIds': empresaIds.join(','),
        if (situacaoCadastro != null) 'situacaoCadastro': situacaoCadastro,
        'page': '$page',
        'limit': '$limit',
      },
    );
    return RelatorioPontosFidelidadeDto.fromJson(
        response.body as Map<String, dynamic>);
  }

  @override
  Future<RelatorioClientesAniversariantes> clientesAniversariantes({
    required List<int> empresaIds,
    int? mes,
    String? dataUltimaCompraInicial,
    String? dataUltimaCompraFinal,
    int page = 1,
    int limit = 100,
  }) async {
    final response = await get(
      pathParameters: {'path': '/clientes/aniversariantes'},
      queryParameters: {
        'empresaIds': empresaIds.join(','),
        if (mes != null) 'mes': '$mes',
        if (dataUltimaCompraInicial != null)
          'dataUltimaCompraInicial': dataUltimaCompraInicial,
        if (dataUltimaCompraFinal != null)
          'dataUltimaCompraFinal': dataUltimaCompraFinal,
        'page': '$page',
        'limit': '$limit',
      },
    );
    return RelatorioClientesAniversariantesDto.fromJson(
        response.body as Map<String, dynamic>);
  }

  @override
  Future<RelatorioClienteCompras> comprasDoCliente({
    required List<int> empresaIds,
    required int pessoaId,
    int limit = 10,
    String? dataInicial,
    String? dataFinal,
  }) async {
    final response = await get(
      pathParameters: {'path': '/clientes/$pessoaId/compras'},
      queryParameters: {
        'empresaIds': empresaIds.join(','),
        'limit': '$limit',
        if (dataInicial != null) 'dataInicial': dataInicial,
        if (dataFinal != null) 'dataFinal': dataFinal,
      },
    );
    return RelatorioClienteComprasDto.fromJson(
        response.body as Map<String, dynamic>);
  }

  @override
  Future<RelatorioMovimentacoes> movimentacoes({
    required List<int> empresaIds,
    required String dataInicial,
    required String dataFinal,
    List<String>? tipos,
    String? busca,
    int page = 1,
    int limit = 50,
  }) async {
    final response = await get(
      pathParameters: {'path': '/movimentacoes'},
      queryParameters: {
        'empresaIds': empresaIds.join(','),
        'dataInicial': dataInicial,
        'dataFinal': dataFinal,
        if (tipos != null && tipos.isNotEmpty) 'tipos': tipos.join(','),
        if (busca != null && busca.isNotEmpty) 'busca': busca,
        'page': '$page',
        'limit': '$limit',
      },
    );
    return movimentacoesFromJson(response.body as Map<String, dynamic>);
  }

  @override
  Future<RelatorioFrequenciaClientes> frequenciaClientes({
    required List<int> empresaIds,
    required String dataInicial,
    required String dataFinal,
    List<int>? funcionarioIds,
    List<int>? categoriaIds,
    String? classe,
    bool atrasados = false,
    String? busca,
    String ordenarPor = 'rank',
    String ordem = 'asc',
    int page = 1,
    int limit = 20,
  }) async {
    final response = await get(
      pathParameters: {'path': '/clientes/frequencia'},
      queryParameters: {
        'empresaIds': empresaIds.join(','),
        'dataInicial': dataInicial,
        'dataFinal': dataFinal,
        if (funcionarioIds != null && funcionarioIds.isNotEmpty)
          'funcionarioIds': funcionarioIds.join(','),
        if (categoriaIds != null && categoriaIds.isNotEmpty)
          'categoriaIds': categoriaIds.join(','),
        if (classe != null) 'classe': classe,
        if (atrasados) 'atrasados': 'true',
        if (busca != null && busca.isNotEmpty) 'busca': busca,
        'ordenarPor': ordenarPor,
        'ordem': ordem,
        'page': '$page',
        'limit': '$limit',
      },
    );
    return frequenciaClientesFromJson(response.body as Map<String, dynamic>);
  }
}
