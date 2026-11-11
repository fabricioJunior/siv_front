import 'package:core/equals.dart';

enum SituacaoContagem { aberto, faturado, todos }

/// Ordem das etapas da trilha (a mesma do pedido de entrada).
const etapasContagem = [
  'contando',
  'associando',
  'etiquetando',
  'conferindo',
  'faturando',
];

String _iso(DateTime d) =>
    '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

const _manter = Object();

class FiltroPedidosContagem extends Equatable {
  final SituacaoContagem situacao;
  final DateTime? de;
  final DateTime? ate;
  final int? categoriaId;
  final int? referenciaId;
  final int? produtoId;
  final int? pessoaId;
  final int? tabelaPrecoId;
  final String busca;
  final String? etapa;
  final String ordenarPor;
  final String ordem;

  const FiltroPedidosContagem({
    this.situacao = SituacaoContagem.aberto,
    this.de,
    this.ate,
    this.categoriaId,
    this.referenciaId,
    this.produtoId,
    this.pessoaId,
    this.tabelaPrecoId,
    this.busca = '',
    this.etapa,
    this.ordenarPor = 'data',
    this.ordem = 'desc',
  });

  bool get temFiltroItem =>
      categoriaId != null || referenciaId != null || produtoId != null;

  /// Campos anuláveis: passe `null` para limpar, omita para manter.
  FiltroPedidosContagem copyWith({
    SituacaoContagem? situacao,
    Object? de = _manter,
    Object? ate = _manter,
    Object? categoriaId = _manter,
    Object? referenciaId = _manter,
    Object? produtoId = _manter,
    Object? pessoaId = _manter,
    Object? tabelaPrecoId = _manter,
    String? busca,
    Object? etapa = _manter,
    String? ordenarPor,
    String? ordem,
  }) =>
      FiltroPedidosContagem(
        situacao: situacao ?? this.situacao,
        de: identical(de, _manter) ? this.de : de as DateTime?,
        ate: identical(ate, _manter) ? this.ate : ate as DateTime?,
        categoriaId: identical(categoriaId, _manter)
            ? this.categoriaId
            : categoriaId as int?,
        referenciaId: identical(referenciaId, _manter)
            ? this.referenciaId
            : referenciaId as int?,
        produtoId:
            identical(produtoId, _manter) ? this.produtoId : produtoId as int?,
        pessoaId:
            identical(pessoaId, _manter) ? this.pessoaId : pessoaId as int?,
        tabelaPrecoId: identical(tabelaPrecoId, _manter)
            ? this.tabelaPrecoId
            : tabelaPrecoId as int?,
        busca: busca ?? this.busca,
        etapa: identical(etapa, _manter) ? this.etapa : etapa as String?,
        ordenarPor: ordenarPor ?? this.ordenarPor,
        ordem: ordem ?? this.ordem,
      );

  Map<String, String> toQuery({int pagina = 1, int tamanho = 30}) => {
        'situacao': situacao.name,
        if (de != null) 'de': _iso(de!),
        if (ate != null) 'ate': _iso(ate!),
        if (categoriaId != null) 'categoriaId': '$categoriaId',
        if (referenciaId != null) 'referenciaId': '$referenciaId',
        if (produtoId != null) 'produtoId': '$produtoId',
        if (pessoaId != null) 'pessoaId': '$pessoaId',
        if (tabelaPrecoId != null) 'tabelaPrecoId': '$tabelaPrecoId',
        if (busca.trim().isNotEmpty) 'busca': busca.trim(),
        if (etapa != null) 'etapa': etapa!,
        'ordenarPor': ordenarPor,
        'ordem': ordem,
        'pagina': '$pagina',
        'tamanho': '$tamanho',
      };

  @override
  List<Object?> get props => [
        situacao,
        de,
        ate,
        categoriaId,
        referenciaId,
        produtoId,
        pessoaId,
        tabelaPrecoId,
        busca,
        etapa,
        ordenarPor,
        ordem,
      ];
}

double _d(dynamic v) => (v as num?)?.toDouble() ?? 0;

DateTime? _data(dynamic v) => v == null ? null : DateTime.tryParse('$v');

class EtapaResumo {
  final String etapa;
  final int pedidos;
  final double custo;
  final double valor;
  const EtapaResumo(this.etapa, this.pedidos, this.custo, [this.valor = 0]);
}

class ResumoPedidosContagem {
  final int pedidos;
  final double pecas;
  final double custo;
  final double pecasSemCusto;
  final double valor;
  final double pecasSemValor;

  /// Vazio quando não há pedido em aberto no resultado.
  final List<EtapaResumo> porEtapa;

  const ResumoPedidosContagem({
    this.pedidos = 0,
    this.pecas = 0,
    this.custo = 0,
    this.pecasSemCusto = 0,
    this.valor = 0,
    this.pecasSemValor = 0,
    this.porEtapa = const [],
  });

  factory ResumoPedidosContagem.fromJson(Map<String, dynamic> j) =>
      ResumoPedidosContagem(
        pedidos: (j['pedidos'] as num?)?.toInt() ?? 0,
        pecas: _d(j['pecas']),
        custo: _d(j['custo']),
        pecasSemCusto: _d(j['pecasSemCusto']),
        valor: _d(j['valor']),
        pecasSemValor: _d(j['pecasSemValor']),
        porEtapa: [
          for (final e in (j['porEtapa'] as List?) ?? const [])
            EtapaResumo(
              (e as Map<String, dynamic>)['etapa'] as String,
              (e['pedidos'] as num?)?.toInt() ?? 0,
              _d(e['custo']),
              _d(e['valor']),
            ),
        ],
      );
}

class PrimeiroProdutoContagem {
  final String referenciaNome;
  final String? cor;
  final String? tamanho;
  const PrimeiroProdutoContagem(this.referenciaNome, {this.cor, this.tamanho});
}

class PedidoContagemLinha {
  final int pedidoId;
  final String fornecedor;
  final String? funcionario;
  final DateTime? abertoEm;
  final DateTime? faturadoEm;
  final String etapa;
  final double pecas;
  final double custo;
  final double pecasSemCusto;
  final double custoPedido;
  final double valor;
  final double valorPedido;
  final double pecasSemValor;
  final int? tabelaPrecoId;
  final String? tabelaPrecoNome;
  final PrimeiroProdutoContagem? primeiroProduto;
  final int quantidadeReferencias;

  const PedidoContagemLinha({
    required this.pedidoId,
    required this.fornecedor,
    required this.etapa,
    this.funcionario,
    this.abertoEm,
    this.faturadoEm,
    this.pecas = 0,
    this.custo = 0,
    this.pecasSemCusto = 0,
    this.custoPedido = 0,
    this.valor = 0,
    this.valorPedido = 0,
    this.pecasSemValor = 0,
    this.tabelaPrecoId,
    this.tabelaPrecoNome,
    this.primeiroProduto,
    this.quantidadeReferencias = 0,
  });

  bool get faturado => etapa == 'faturado';

  factory PedidoContagemLinha.fromJson(Map<String, dynamic> j) {
    final p = j['primeiroProduto'] as Map<String, dynamic>?;
    return PedidoContagemLinha(
      pedidoId: (j['pedidoId'] as num).toInt(),
      fornecedor:
          (j['fornecedor'] as Map<String, dynamic>?)?['nome'] as String? ?? '',
      funcionario:
          (j['funcionario'] as Map<String, dynamic>?)?['nome'] as String?,
      abertoEm: _data(j['abertoEm']),
      faturadoEm: _data(j['faturadoEm']),
      etapa: j['etapa'] as String? ?? 'contando',
      pecas: _d(j['pecas']),
      custo: _d(j['custo']),
      pecasSemCusto: _d(j['pecasSemCusto']),
      custoPedido: _d(j['custoPedido']),
      valor: _d(j['valor']),
      valorPedido: _d(j['valorPedido']),
      pecasSemValor: _d(j['pecasSemValor']),
      tabelaPrecoId: (j['tabelaPrecoId'] as num?)?.toInt(),
      tabelaPrecoNome: j['tabelaPrecoNome'] as String?,
      primeiroProduto: p == null
          ? null
          : PrimeiroProdutoContagem(
              p['referenciaNome'] as String? ?? '',
              cor: p['cor'] as String?,
              tamanho: p['tamanho'] as String?,
            ),
      quantidadeReferencias: (j['quantidadeReferencias'] as num?)?.toInt() ?? 0,
    );
  }
}

class RelatorioPedidosContagem {
  final ResumoPedidosContagem resumo;
  final List<PedidoContagemLinha> itens;
  final int pagina;
  final int totalItems;

  const RelatorioPedidosContagem({
    this.resumo = const ResumoPedidosContagem(),
    this.itens = const [],
    this.pagina = 1,
    this.totalItems = 0,
  });

  factory RelatorioPedidosContagem.fromJson(Map<String, dynamic> j) {
    final m = j['meta'] as Map<String, dynamic>? ?? const {};
    return RelatorioPedidosContagem(
      resumo: ResumoPedidosContagem.fromJson(
        j['resumo'] as Map<String, dynamic>? ?? const {},
      ),
      itens: [
        for (final e in (j['itens'] as List?) ?? const [])
          PedidoContagemLinha.fromJson(e as Map<String, dynamic>),
      ],
      pagina: (m['pagina'] as num?)?.toInt() ?? 1,
      totalItems: (m['totalItems'] as num?)?.toInt() ?? 0,
    );
  }
}

/// Item de um pedido na linha expandida (B2).
class ItemPedidoContagem {
  final String referenciaNome;
  final String? referenciaIdExterno;
  final String? cor;
  final String? tamanho;
  final String? estampa;
  final double quantidade;
  final double? custoUnitario;
  final double? subtotal;
  final double? valorUnitario;
  final double? subtotalVenda;
  final bool semReferencia;
  final bool bateFiltro;

  const ItemPedidoContagem({
    required this.referenciaNome,
    this.referenciaIdExterno,
    this.cor,
    this.tamanho,
    this.estampa,
    this.quantidade = 0,
    this.custoUnitario,
    this.subtotal,
    this.valorUnitario,
    this.subtotalVenda,
    this.semReferencia = false,
    this.bateFiltro = true,
  });

  /// `cor · tamanho` (+ ` · estampa`), sem os vazios.
  String get variacao => [cor, tamanho, estampa]
      .whereType<String>()
      .where((s) => s.isNotEmpty)
      .join(' · ');

  factory ItemPedidoContagem.fromJson(Map<String, dynamic> j) =>
      ItemPedidoContagem(
        referenciaNome: j['referenciaNome'] as String? ?? '',
        referenciaIdExterno: j['referenciaIdExterno'] as String?,
        cor: j['cor'] as String?,
        tamanho: j['tamanho'] as String?,
        estampa: j['estampa'] as String?,
        quantidade: _d(j['quantidade']),
        custoUnitario: (j['custoUnitario'] as num?)?.toDouble(),
        subtotal: (j['subtotal'] as num?)?.toDouble(),
        valorUnitario: (j['valorUnitario'] as num?)?.toDouble(),
        subtotalVenda: (j['subtotalVenda'] as num?)?.toDouble(),
        semReferencia: j['semReferencia'] as bool? ?? false,
        bateFiltro: j['bateFiltro'] as bool? ?? true,
      );
}
