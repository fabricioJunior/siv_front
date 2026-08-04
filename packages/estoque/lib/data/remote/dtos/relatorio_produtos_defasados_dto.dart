import 'package:estoque/domain/models/relatorio_produtos_defasados.dart';

class RelatorioProdutoDefasadoItemDto implements RelatorioProdutoDefasadoItem {
  @override
  final int? produtoId;
  @override
  final String produtoIdExterno;
  @override
  final int referenciaId;
  @override
  final String referenciaIdExterno;
  @override
  final String referenciaNome;
  @override
  final int? corId;
  @override
  final String corNome;
  @override
  final int? tamanhoId;
  @override
  final String tamanhoNome;
  @override
  final int quantidadeProdutos;
  @override
  final int saldo;
  @override
  final double valorUnitario;
  @override
  final double valorTotal;
  @override
  final String? ultimaEntrada;
  @override
  final String? ultimaSaida;
  @override
  final int? diasSemMovimentacao;

  const RelatorioProdutoDefasadoItemDto({
    required this.produtoId,
    required this.produtoIdExterno,
    required this.referenciaId,
    required this.referenciaIdExterno,
    required this.referenciaNome,
    required this.corId,
    required this.corNome,
    required this.tamanhoId,
    required this.tamanhoNome,
    required this.quantidadeProdutos,
    required this.saldo,
    required this.valorUnitario,
    required this.valorTotal,
    this.ultimaEntrada,
    this.ultimaSaida,
    this.diasSemMovimentacao,
  });

  factory RelatorioProdutoDefasadoItemDto.fromJson(Map<String, dynamic> j) =>
      RelatorioProdutoDefasadoItemDto(
        produtoId: (j['produtoId'] as num?)?.toInt(),
        produtoIdExterno: j['produtoIdExterno'] as String? ?? '',
        referenciaId: (j['referenciaId'] as num).toInt(),
        referenciaIdExterno: j['referenciaIdExterno'] as String? ?? '',
        referenciaNome: j['referenciaNome'] as String? ?? '',
        corId: (j['corId'] as num?)?.toInt(),
        corNome: j['corNome'] as String? ?? '',
        tamanhoId: (j['tamanhoId'] as num?)?.toInt(),
        tamanhoNome: j['tamanhoNome'] as String? ?? '',
        quantidadeProdutos: (j['quantidadeProdutos'] as num).toInt(),
        saldo: (j['saldo'] as num).toInt(),
        valorUnitario: (j['valorUnitario'] as num).toDouble(),
        valorTotal: (j['valorTotal'] as num).toDouble(),
        ultimaEntrada: j['ultimaEntrada'] as String?,
        ultimaSaida: j['ultimaSaida'] as String?,
        diasSemMovimentacao: (j['diasSemMovimentacao'] as num?)?.toInt(),
      );
}

class RelatorioProdutosDefasadosMetaDto
    implements RelatorioProdutosDefasadosMeta {
  @override
  final int totalItems;
  @override
  final int itemCount;
  @override
  final int itemsPerPage;
  @override
  final int currentPage;
  @override
  final int totalPages;

  const RelatorioProdutosDefasadosMetaDto({
    required this.totalItems,
    required this.itemCount,
    required this.itemsPerPage,
    required this.currentPage,
    required this.totalPages,
  });

  factory RelatorioProdutosDefasadosMetaDto.fromJson(Map<String, dynamic> j) =>
      RelatorioProdutosDefasadosMetaDto(
        totalItems: (j['totalItems'] as num).toInt(),
        itemCount: (j['itemCount'] as num).toInt(),
        itemsPerPage: (j['itemsPerPage'] as num).toInt(),
        currentPage: (j['currentPage'] as num).toInt(),
        totalPages: (j['totalPages'] as num).toInt(),
      );
}

class RelatorioProdutosDefasadosResumoDto
    implements RelatorioProdutosDefasadosResumo {
  @override
  final int quantidadeDefasados;
  @override
  final int totalEmEstoque;
  @override
  final double percentualDefasado;
  @override
  final double valorTotalDefasado;

  const RelatorioProdutosDefasadosResumoDto({
    required this.quantidadeDefasados,
    required this.totalEmEstoque,
    required this.percentualDefasado,
    required this.valorTotalDefasado,
  });

  factory RelatorioProdutosDefasadosResumoDto.fromJson(
    Map<String, dynamic> j,
  ) => RelatorioProdutosDefasadosResumoDto(
    quantidadeDefasados: (j['quantidadeDefasados'] as num).toInt(),
    totalEmEstoque: (j['totalEmEstoque'] as num).toInt(),
    percentualDefasado: (j['percentualDefasado'] as num).toDouble(),
    valorTotalDefasado: (j['valorTotalDefasado'] as num).toDouble(),
  );
}

class RelatorioProdutosDefasadosDto implements RelatorioProdutosDefasados {
  @override
  final List<RelatorioProdutoDefasadoItem> items;
  @override
  final RelatorioProdutosDefasadosMeta meta;
  @override
  final RelatorioProdutosDefasadosResumo resumo;

  const RelatorioProdutosDefasadosDto({
    required this.items,
    required this.meta,
    required this.resumo,
  });

  factory RelatorioProdutosDefasadosDto.fromJson(Map<String, dynamic> j) =>
      RelatorioProdutosDefasadosDto(
        items: (j['items'] as List<dynamic>? ?? [])
            .map(
              (e) => RelatorioProdutoDefasadoItemDto.fromJson(
                e as Map<String, dynamic>,
              ),
            )
            .toList(),
        meta: RelatorioProdutosDefasadosMetaDto.fromJson(
          j['meta'] as Map<String, dynamic>,
        ),
        resumo: RelatorioProdutosDefasadosResumoDto.fromJson(
          j['resumo'] as Map<String, dynamic>,
        ),
      );
}
