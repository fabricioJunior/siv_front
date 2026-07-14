import 'package:estoque/domain/models/historico_estoque.dart';
import 'package:estoque/domain/models/pagina_historico_estoque.dart';
import 'package:estoque/domain/models/paginacao_do_estoque.dart';

class HistoricoEstoqueDto implements HistoricoEstoque {
  @override
  final int romaneioId;
  @override
  final DateTime dataHora;
  @override
  final String operacao;
  @override
  final String modalidade;
  @override
  final int referenciaId;
  @override
  final String referenciaNome;
  @override
  final int produtoId;
  @override
  final String? produtoIdExterno;
  @override
  final String? corNome;
  @override
  final String? tamanhoNome;
  @override
  final double quantidade;
  @override
  final double saldoApos;
  @override
  final int? funcionarioId;
  @override
  final String? funcionarioNome;
  @override
  final int? operadorId;
  @override
  final String? operadorNome;
  @override
  final int? pessoaId;
  @override
  final String? pessoaNome;
  @override
  final int? caixaId;
  @override
  final String? caixaTerminalNome;

  HistoricoEstoqueDto({
    required this.romaneioId,
    required this.dataHora,
    required this.operacao,
    required this.modalidade,
    required this.referenciaId,
    required this.referenciaNome,
    required this.produtoId,
    this.produtoIdExterno,
    this.corNome,
    this.tamanhoNome,
    required this.quantidade,
    required this.saldoApos,
    this.funcionarioId,
    this.funcionarioNome,
    this.operadorId,
    this.operadorNome,
    this.pessoaId,
    this.pessoaNome,
    this.caixaId,
    this.caixaTerminalNome,
  });

  factory HistoricoEstoqueDto.fromJson(Map<String, dynamic> json) {
    return HistoricoEstoqueDto(
      romaneioId: json['romaneioId'] as int,
      dataHora: DateTime.parse(json['dataHora'] as String),
      operacao: json['operacao'] as String,
      modalidade: json['modalidade'] as String,
      referenciaId: json['referenciaId'] as int,
      referenciaNome: json['referenciaNome'] as String? ?? '',
      produtoId: json['produtoId'] as int,
      produtoIdExterno: json['produtoIdExterno'] as String?,
      corNome: json['corNome'] as String?,
      tamanhoNome: json['tamanhoNome'] as String?,
      quantidade: (json['quantidade'] as num).toDouble(),
      saldoApos: (json['saldoApos'] as num).toDouble(),
      funcionarioId: json['funcionarioId'] as int?,
      funcionarioNome: json['funcionarioNome'] as String?,
      operadorId: json['operadorId'] as int?,
      operadorNome: json['operadorNome'] as String?,
      pessoaId: json['pessoaId'] as int?,
      pessoaNome: json['pessoaNome'] as String?,
      caixaId: json['caixaId'] as int?,
      caixaTerminalNome: json['caixaTerminalNome'] as String?,
    );
  }

  @override
  bool get ehEntrada => modalidade == 'entrada';

  @override
  List<Object?> get props => [
    romaneioId,
    dataHora,
    operacao,
    modalidade,
    referenciaId,
    referenciaNome,
    produtoId,
    produtoIdExterno,
    corNome,
    tamanhoNome,
    quantidade,
    saldoApos,
    funcionarioId,
    funcionarioNome,
    operadorId,
    operadorNome,
    pessoaId,
    pessoaNome,
    caixaId,
    caixaTerminalNome,
  ];

  @override
  bool? get stringify => true;
}

class MetaHistoricoEstoqueDto implements PaginacaoDoEstoque {
  @override
  final int totalItems;
  @override
  final int itemCount;
  @override
  final int itemsPerPage;
  @override
  final int totalPages;
  @override
  final int currentPage;

  MetaHistoricoEstoqueDto({
    required this.totalItems,
    required this.itemCount,
    required this.itemsPerPage,
    required this.totalPages,
    required this.currentPage,
  });

  factory MetaHistoricoEstoqueDto.fromJson(Map<String, dynamic> json) {
    return MetaHistoricoEstoqueDto(
      totalItems: json['totalItems'] as int? ?? 0,
      itemCount: json['itemCount'] as int? ?? 0,
      itemsPerPage: json['itemsPerPage'] as int? ?? 0,
      totalPages: json['totalPages'] as int? ?? 0,
      currentPage: json['currentPage'] as int? ?? 1,
    );
  }

  @override
  List<Object?> get props => [
    totalItems,
    itemCount,
    itemsPerPage,
    totalPages,
    currentPage,
  ];

  @override
  bool? get stringify => true;
}

class PaginaHistoricoEstoqueDto {
  static PaginaHistoricoEstoque fromJson(Map<String, dynamic> json) {
    final itemsJson = (json['items'] as List? ?? const []);
    return PaginaHistoricoEstoque(
      meta: MetaHistoricoEstoqueDto.fromJson(
        json['meta'] as Map<String, dynamic>? ?? const {},
      ),
      items: itemsJson
          .map((e) => HistoricoEstoqueDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
