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

/// Contagem de produto sem referência (descrição livre + cor + tamanho).
class ContagemLivre extends Equatable {
  final int id;
  final String descricao;
  final int corId;
  final int tamanhoId;
  final double quantidade;

  const ContagemLivre({
    required this.id,
    required this.descricao,
    required this.corId,
    required this.tamanhoId,
    required this.quantidade,
  });

  factory ContagemLivre.fromJson(Map<String, dynamic> j) => ContagemLivre(
        id: _int(j['id']) ?? 0,
        descricao: j['descricao'] as String? ?? '',
        corId: _int(j['corId']) ?? 0,
        tamanhoId: _int(j['tamanhoId']) ?? 0,
        quantidade: _num(j['quantidade']),
      );

  @override
  List<Object?> get props => [id, descricao, corId, tamanhoId, quantidade];
}

/// Situação de um item na conferência (lido × contado).
enum SituacaoConferencia {
  pendente,
  parcial,
  conferido,
  excedente;

  static SituacaoConferencia deContagem(double contado, double lido) {
    if (lido <= 0) return pendente;
    if (lido < contado) return parcial;
    if (lido == contado) return conferido;
    return excedente;
  }

  static SituacaoConferencia deValor(String? v, double contado, double lido) =>
      SituacaoConferencia.values.firstWhere(
        (s) => s.name == v,
        orElse: () => deContagem(contado, lido),
      );
}

/// Registro de impressão de etiquetas (por produto) e se o passo foi pulado.
class EntradaEtiquetas extends Equatable {
  final DateTime? impressasEm;
  final bool puladas;
  final Map<int, double> impressasPorProduto;

  const EntradaEtiquetas({
    this.impressasEm,
    this.puladas = false,
    this.impressasPorProduto = const {},
  });

  factory EntradaEtiquetas.fromJson(Map<String, dynamic>? j) {
    if (j == null) return const EntradaEtiquetas();
    final porProduto = (j['impressasPorProduto'] as Map<String, dynamic>?) ?? {};
    return EntradaEtiquetas(
      impressasEm: DateTime.tryParse('${j['impressasEm'] ?? ''}'),
      puladas: j['puladas'] == true,
      impressasPorProduto: {
        for (final e in porProduto.entries)
          if (int.tryParse(e.key) != null) int.parse(e.key): _num(e.value),
      },
    );
  }

  bool get concluidas => impressasEm != null || puladas;

  @override
  List<Object?> get props => [impressasEm, puladas, impressasPorProduto];
}

/// Linha da conferência: contado × lido de um produto da entrada.
class EntradaConferenciaItem extends Equatable {
  final int produtoId;
  final String codigoDeBarras;
  final String descricao;
  final int idReferencia;
  final String cor;
  final String tamanho;
  final double contado;
  final double lido;
  final SituacaoConferencia situacao;

  const EntradaConferenciaItem({
    required this.produtoId,
    required this.codigoDeBarras,
    required this.descricao,
    required this.idReferencia,
    required this.cor,
    required this.tamanho,
    required this.contado,
    required this.lido,
    required this.situacao,
  });

  factory EntradaConferenciaItem.fromJson(Map<String, dynamic> j) {
    final contado = _num(j['contado']);
    final lido = _num(j['lido']);
    return EntradaConferenciaItem(
      produtoId: _int(j['produtoId']) ?? 0,
      codigoDeBarras: '${j['codigoDeBarras'] ?? ''}',
      descricao: j['descricao'] as String? ?? '',
      idReferencia: _int(j['idReferencia']) ?? 0,
      cor: j['cor'] as String? ?? '',
      tamanho: j['tamanho'] as String? ?? '',
      contado: contado,
      lido: lido,
      situacao: SituacaoConferencia.deValor(
        j['situacao'] as String?,
        contado,
        lido,
      ),
    );
  }

  String get grade => [cor, tamanho].where((e) => e.isNotEmpty).join(' · ');

  @override
  List<Object?> get props => [produtoId, contado, lido, situacao];
}

class EntradaConferencia extends Equatable {
  final double totalContado;
  final double totalLido;
  final int linhasConferidas;
  final int linhasPendentes;
  final int linhasExcedentes;
  final List<EntradaConferenciaItem> itens;

  const EntradaConferencia({
    this.totalContado = 0,
    this.totalLido = 0,
    this.linhasConferidas = 0,
    this.linhasPendentes = 0,
    this.linhasExcedentes = 0,
    this.itens = const [],
  });

  factory EntradaConferencia.fromJson(Map<String, dynamic>? j) {
    if (j == null) return const EntradaConferencia();
    return EntradaConferencia(
      totalContado: _num(j['totalContado']),
      totalLido: _num(j['totalLido']),
      linhasConferidas: _int(j['linhasConferidas']) ?? 0,
      linhasPendentes: _int(j['linhasPendentes']) ?? 0,
      linhasExcedentes: _int(j['linhasExcedentes']) ?? 0,
      itens: ((j['itens'] as List<dynamic>?) ?? const [])
          .map((i) => EntradaConferenciaItem.fromJson(i as Map<String, dynamic>))
          .toList(),
    );
  }

  @override
  List<Object?> get props => [totalContado, totalLido, itens];
}

enum TipoDivergencia {
  falta,
  excede,
  foraDaContagem;

  static TipoDivergencia deValor(String? v) => TipoDivergencia.values
      .firstWhere((t) => t.name == v, orElse: () => falta);
}

/// Decisão sobre uma divergência (valores da API em `PUT .../divergencias/{produtoId}`).
enum AcaoDivergencia {
  corrigir,
  manter,
  removerLeitura,
  adicionarNaContagem,
  descartarLeitura;

  static AcaoDivergencia? deValor(String? v) =>
      AcaoDivergencia.values.where((a) => a.name == v).firstOrNull;
}

class EntradaDivergencia extends Equatable {
  final int produtoId;
  final String descricao;
  final String grade;
  final double contado;
  final double lido;
  final TipoDivergencia tipo;
  final AcaoDivergencia? decisao;
  final String? observacao;

  const EntradaDivergencia({
    required this.produtoId,
    required this.descricao,
    required this.grade,
    required this.contado,
    required this.lido,
    required this.tipo,
    this.decisao,
    this.observacao,
  });

  factory EntradaDivergencia.fromJson(Map<String, dynamic> j) =>
      EntradaDivergencia(
        produtoId: _int(j['produtoId']) ?? 0,
        descricao: j['descricao'] as String? ?? '',
        grade: j['grade'] as String? ?? '',
        contado: _num(j['contado']),
        lido: _num(j['lido']),
        tipo: TipoDivergencia.deValor(j['tipo'] as String?),
        decisao: AcaoDivergencia.deValor(j['decisao'] as String?),
        observacao: j['observacao'] as String?,
      );

  bool get decidida => decisao != null;

  @override
  List<Object?> get props => [produtoId, contado, lido, tipo, decisao];
}

class EntradaRevisao extends Equatable {
  final double contado;
  final double conferido;
  final double entraNoEstoque;
  final bool? podeFaturar;

  const EntradaRevisao({
    this.contado = 0,
    this.conferido = 0,
    this.entraNoEstoque = 0,
    this.podeFaturar,
  });

  factory EntradaRevisao.fromJson(Map<String, dynamic>? j) {
    if (j == null) return const EntradaRevisao();
    final t = (j['totais'] as Map<String, dynamic>?) ?? const {};
    return EntradaRevisao(
      contado: _num(t['contado']),
      conferido: _num(t['conferido']),
      entraNoEstoque: _num(t['entraNoEstoque']),
      podeFaturar: j['podeFaturar'] as bool?,
    );
  }

  @override
  List<Object?> get props => [contado, conferido, entraNoEstoque, podeFaturar];
}

/// Auditoria de correção de contagem / decisão de divergência.
class EntradaCorrecao extends Equatable {
  final int id;
  final int? produtoId;
  final String tipo;
  final double? de;
  final double? para;
  final String? acao;
  final String? motivo;
  final String origem;
  final String? operadorNome;
  final DateTime? criadoEm;

  const EntradaCorrecao({
    required this.id,
    required this.produtoId,
    required this.tipo,
    required this.de,
    required this.para,
    required this.acao,
    required this.motivo,
    required this.origem,
    required this.operadorNome,
    required this.criadoEm,
  });

  factory EntradaCorrecao.fromJson(Map<String, dynamic> j) => EntradaCorrecao(
        id: _int(j['id']) ?? 0,
        produtoId: _int(j['produtoId']),
        tipo: j['tipo'] as String? ?? 'contagem',
        de: j['de'] == null ? null : _num(j['de']),
        para: j['para'] == null ? null : _num(j['para']),
        acao: j['acao'] as String?,
        motivo: j['motivo'] as String?,
        origem: j['origem'] as String? ?? 'contagem',
        operadorNome: j['operadorNome'] as String?,
        criadoEm: DateTime.tryParse('${j['criadoEm'] ?? ''}'),
      );

  @override
  List<Object?> get props => [id];
}

/// Dados do Pedido de Entrada além do pedido em si: origem, NF-e, linhas e contagem.
class EntradaResumo extends Equatable {
  final int pedidoId;
  final String? origemEntrada;
  final EntradaNfe? nfe;
  final List<EntradaLinha> linhas;
  final List<EntradaContagem> contagens;
  final List<ContagemLivre> contagensLivres;
  final double totalNfe;
  final double totalContado;
  final List<String> pendencias;

  /// Campos do redesenho (backend antigo não envia): todos com default seguro.
  final String? etapa;
  final EntradaEtiquetas etiquetas;
  final EntradaConferencia conferencia;
  final List<EntradaDivergencia> divergencias;
  final EntradaRevisao revisao;
  final List<EntradaCorrecao> correcoes;

  const EntradaResumo({
    required this.pedidoId,
    required this.origemEntrada,
    required this.nfe,
    required this.linhas,
    required this.contagens,
    this.contagensLivres = const [],
    required this.totalNfe,
    required this.totalContado,
    required this.pendencias,
    this.etapa,
    this.etiquetas = const EntradaEtiquetas(),
    this.conferencia = const EntradaConferencia(),
    this.divergencias = const [],
    this.revisao = const EntradaRevisao(),
    this.correcoes = const [],
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
      contagensLivres: ((j['contagensLivres'] as List<dynamic>?) ?? const [])
          .map((c) => ContagemLivre.fromJson(c as Map<String, dynamic>))
          .toList(),
      totalNfe: _num(totais['nfe']),
      totalContado: _num(totais['contado']),
      pendencias:
          ((j['pendencias'] as List<dynamic>?) ?? const []).cast<String>(),
      etapa: j['etapa'] as String?,
      etiquetas: EntradaEtiquetas.fromJson(
        j['etiquetas'] as Map<String, dynamic>?,
      ),
      conferencia: EntradaConferencia.fromJson(
        j['conferencia'] as Map<String, dynamic>?,
      ),
      divergencias: ((j['divergencias'] as List<dynamic>?) ?? const [])
          .map((d) => EntradaDivergencia.fromJson(d as Map<String, dynamic>))
          .toList(),
      revisao: EntradaRevisao.fromJson(j['revisao'] as Map<String, dynamic>?),
      correcoes: ((j['correcoes'] as List<dynamic>?) ?? const [])
          .map((c) => EntradaCorrecao.fromJson(c as Map<String, dynamic>))
          .toList(),
    );
  }

  List<EntradaContagem> contagensDaLinha(int linhaId) =>
      contagens.where((c) => c.linhaId == linhaId).toList();

  @override
  List<Object?> get props => [
        pedidoId,
        linhas,
        contagens,
        contagensLivres,
        pendencias,
        etapa,
        etiquetas,
        conferencia,
        divergencias,
        revisao,
        correcoes,
      ];
}

/// Item enviado na contagem (SKU existente ou referência + cor + tamanho).
/// Na contagem sem referência vai só [descricao] + cor + tamanho.
class ItemContagem {
  final int? linhaId;
  final int? produtoId;
  final int? referenciaId;
  final int? corId;
  final int? tamanhoId;
  final double quantidade;
  final String? descricao;

  const ItemContagem({
    this.linhaId,
    this.produtoId,
    this.referenciaId,
    this.corId,
    this.tamanhoId,
    required this.quantidade,
    this.descricao,
  });

  Map<String, dynamic> toJson() => {
        if (descricao != null) 'descricao': descricao,
        if (linhaId != null) 'linhaId': linhaId,
        if (produtoId != null) 'produtoId': produtoId,
        if (referenciaId != null) 'referenciaId': referenciaId,
        if (corId != null) 'corId': corId,
        if (tamanhoId != null) 'tamanhoId': tamanhoId,
        'quantidade': quantidade,
      };
}
