import 'package:core/equals.dart';

/// Espelha `StatusLinhaEntrada` do backend.
enum StatusLinhaEntrada {
  naoCadastrado('nao_cadastrado', 'Produto não cadastrado'),
  referenciaVinculada('referencia_vinculada', 'Referência (falta a contagem)'),
  mapeado('mapeado', 'Identificado'),
  ignorada('ignorada', 'Ignorado');

  final String valor;
  final String rotulo;
  const StatusLinhaEntrada(this.valor, this.rotulo);

  static StatusLinhaEntrada deValor(String? v) => StatusLinhaEntrada.values
      .firstWhere((s) => s.valor == v, orElse: () => naoCadastrado);
}

double _num(dynamic v) => v == null ? 0 : double.tryParse('$v') ?? 0;
int? _int(dynamic v) => v == null ? null : int.tryParse('$v');

/// Cabeçalho da NF-e que originou o pedido (sem o XML).
class EntradaNfe extends Equatable {
  final String chaveAcesso;
  final String numero;
  final String serie;
  final String emitenteNome;
  final String emitenteDocumento;
  final DateTime? emitidaEm;
  final double valorTotal;

  const EntradaNfe({
    required this.chaveAcesso,
    required this.numero,
    required this.serie,
    required this.emitenteNome,
    required this.emitenteDocumento,
    required this.emitidaEm,
    required this.valorTotal,
  });

  factory EntradaNfe.fromJson(Map<String, dynamic> j) => EntradaNfe(
        chaveAcesso: j['chaveAcesso'] as String? ?? '',
        numero: '${j['numero'] ?? ''}',
        serie: '${j['serie'] ?? ''}',
        emitenteNome: j['emitenteNome'] as String? ?? '',
        emitenteDocumento: '${j['emitenteDocumento'] ?? ''}',
        emitidaEm: DateTime.tryParse('${j['emitidaEm'] ?? ''}'),
        valorTotal: _num(j['valorTotal']),
      );

  @override
  List<Object?> get props => [chaveAcesso, numero, serie, valorTotal];
}

/// Uma linha da NF-e: quantidade do fornecedor × contagem física.
class EntradaLinha extends Equatable {
  final int id;
  final int sequencia;
  final String? codigoFornecedor;
  final String descricao;
  final String? ncm;
  final String? unidade;
  final double quantidadeNfe;
  final double valorUnitario;
  final double valorTotal;
  final StatusLinhaEntrada status;
  final int? produtoId;
  final int? referenciaId;
  final double? quantidadeContada;
  final double? diferenca;
  final bool divergente;
  final bool divergenciaResolvida;

  const EntradaLinha({
    required this.id,
    required this.sequencia,
    required this.codigoFornecedor,
    required this.descricao,
    required this.ncm,
    required this.unidade,
    required this.quantidadeNfe,
    required this.valorUnitario,
    required this.valorTotal,
    required this.status,
    required this.produtoId,
    required this.referenciaId,
    required this.quantidadeContada,
    required this.diferenca,
    required this.divergente,
    required this.divergenciaResolvida,
  });

  factory EntradaLinha.fromJson(Map<String, dynamic> j) => EntradaLinha(
        id: _int(j['id']) ?? 0,
        sequencia: _int(j['sequencia']) ?? 0,
        codigoFornecedor: j['codigoFornecedor'] as String?,
        descricao: j['descricao'] as String? ?? '',
        ncm: j['ncm'] as String?,
        unidade: j['unidade'] as String?,
        quantidadeNfe: _num(j['quantidadeNfe']),
        valorUnitario: _num(j['valorUnitario']),
        valorTotal: _num(j['valorTotal']),
        status: StatusLinhaEntrada.deValor(j['status'] as String?),
        produtoId: _int(j['produtoId']),
        referenciaId: _int(j['referenciaId']),
        quantidadeContada: j['quantidadeContada'] == null
            ? null
            : _num(j['quantidadeContada']),
        diferenca: j['diferenca'] == null ? null : _num(j['diferenca']),
        divergente: j['divergente'] == true,
        divergenciaResolvida: j['divergenciaResolvidaEm'] != null,
      );

  @override
  List<Object?> get props => [
        id,
        status,
        produtoId,
        referenciaId,
        quantidadeContada,
        divergenciaResolvida,
      ];
}

class EntradaContagem extends Equatable {
  final int produtoId;
  final int? linhaId;
  final double quantidade;
  final int? referenciaId;
  final String? referenciaNome;
  final int? corId;
  final String? corNome;
  final int? tamanhoId;
  final String? tamanhoNome;

  const EntradaContagem({
    required this.produtoId,
    required this.linhaId,
    required this.quantidade,
    this.referenciaId,
    this.referenciaNome,
    this.corId,
    this.corNome,
    this.tamanhoId,
    this.tamanhoNome,
  });

  factory EntradaContagem.fromJson(Map<String, dynamic> j) => EntradaContagem(
        produtoId: _int(j['produtoId']) ?? 0,
        linhaId: _int(j['linhaId']),
        quantidade: _num(j['quantidade']),
        referenciaId: _int(j['referenciaId']),
        referenciaNome: j['referenciaNome'] as String?,
        corId: _int(j['corId']),
        corNome: j['corNome'] as String?,
        tamanhoId: _int(j['tamanhoId']),
        tamanhoNome: j['tamanhoNome'] as String?,
      );

  @override
  List<Object?> get props => [produtoId, linhaId, quantidade];
}

/// Dados do Pedido de Entrada além do pedido em si: origem, NF-e, linhas e contagem.
class EntradaResumo extends Equatable {
  final int pedidoId;
  final String? origemEntrada;
  final EntradaNfe? nfe;
  final List<EntradaLinha> linhas;
  final List<EntradaContagem> contagens;
  final double totalNfe;
  final double totalContado;
  final List<String> pendencias;

  const EntradaResumo({
    required this.pedidoId,
    required this.origemEntrada,
    required this.nfe,
    required this.linhas,
    required this.contagens,
    required this.totalNfe,
    required this.totalContado,
    required this.pendencias,
  });

  factory EntradaResumo.fromJson(Map<String, dynamic> j) {
    final totais = (j['totais'] as Map<String, dynamic>?) ?? const {};
    return EntradaResumo(
      pedidoId: _int(j['pedidoId']) ?? 0,
      origemEntrada: j['origemEntrada'] as String?,
      nfe: j['nfe'] == null
          ? null
          : EntradaNfe.fromJson(j['nfe'] as Map<String, dynamic>),
      linhas: ((j['linhas'] as List<dynamic>?) ?? const [])
          .map((l) => EntradaLinha.fromJson(l as Map<String, dynamic>))
          .toList(),
      contagens: ((j['contagens'] as List<dynamic>?) ?? const [])
          .map((c) => EntradaContagem.fromJson(c as Map<String, dynamic>))
          .toList(),
      totalNfe: _num(totais['nfe']),
      totalContado: _num(totais['contado']),
      pendencias:
          ((j['pendencias'] as List<dynamic>?) ?? const []).cast<String>(),
    );
  }

  List<EntradaContagem> contagensDaLinha(int linhaId) =>
      contagens.where((c) => c.linhaId == linhaId).toList();

  @override
  List<Object?> get props => [pedidoId, linhas, contagens, pendencias];
}

/// Item enviado na contagem (SKU existente ou referência + cor + tamanho).
class ItemContagem {
  final int? linhaId;
  final int? produtoId;
  final int? referenciaId;
  final int? corId;
  final int? tamanhoId;
  final double quantidade;

  const ItemContagem({
    this.linhaId,
    this.produtoId,
    this.referenciaId,
    this.corId,
    this.tamanhoId,
    required this.quantidade,
  });

  Map<String, dynamic> toJson() => {
        if (linhaId != null) 'linhaId': linhaId,
        if (produtoId != null) 'produtoId': produtoId,
        if (referenciaId != null) 'referenciaId': referenciaId,
        if (corId != null) 'corId': corId,
        if (tamanhoId != null) 'tamanhoId': tamanhoId,
        'quantidade': quantidade,
      };
}
