import 'package:financeiro/domain/models/caixa.dart';
import 'package:financeiro/domain/models/caixa_do_historico.dart';
import 'package:financeiro/domain/models/pagina_historico_de_caixas.dart';

class CaixaDoHistoricoDto implements CaixaDoHistorico {
  @override
  final int id;
  @override
  final int empresaId;
  @override
  final DateTime data;
  @override
  final int terminalId;
  @override
  final DateTime abertura;
  @override
  final double valorAbertura;
  @override
  final int operadorAberturaId;
  @override
  final String operadorAberturaNome;
  @override
  final DateTime? fechamento;
  @override
  final double? valorFechamento;
  @override
  final int? operadorFechamentoId;
  @override
  final String? operadorFechamentoNome;
  @override
  final SituacaoCaixa situacao;

  CaixaDoHistoricoDto({
    required this.id,
    required this.empresaId,
    required this.data,
    required this.terminalId,
    required this.abertura,
    required this.valorAbertura,
    required this.operadorAberturaId,
    required this.operadorAberturaNome,
    this.fechamento,
    this.valorFechamento,
    this.operadorFechamentoId,
    this.operadorFechamentoNome,
    required this.situacao,
  });

  factory CaixaDoHistoricoDto.fromJson(Map<String, dynamic> json) {
    final situacaoValue =
        (json['situacao']?.toString().toLowerCase() ?? 'aberto').trim();

    return CaixaDoHistoricoDto(
      id: (int.parse(json['id'].toString())).toInt(),
      empresaId: (json['empresaId'] as num?)?.toInt() ?? 0,
      data: DateTime.tryParse(json['data']?.toString() ?? '') ?? DateTime.now(),
      terminalId: (json['terminalId'] as num?)?.toInt() ?? 0,
      abertura: DateTime.tryParse(json['abertura']?.toString() ?? '') ??
          DateTime.now(),
      valorAbertura: (double.parse(json['valorAbertura'].toString()) as num?)
              ?.toDouble() ??
          0,
      operadorAberturaId: (json['operadorAberturaId'] as num?)?.toInt() ?? 0,
      operadorAberturaNome: json['operadorAberturaNome'] as String? ?? '',
      fechamento: json['fechamento'] == null
          ? null
          : DateTime.tryParse(json['fechamento'].toString()),
      valorFechamento:
          (double.parse(json['valorFechamento']?.toString() ?? '0') as num?)
              ?.toDouble(),
      operadorFechamentoId: (json['operadorFechamentoId'] as num?)?.toInt(),
      operadorFechamentoNome: json['operadorFechamentoNome'] as String?,
      situacao: switch (situacaoValue) {
        'fechado' => SituacaoCaixa.fechado,
        'contagem' => SituacaoCaixa.contagem,
        _ => SituacaoCaixa.aberto,
      },
    );
  }

  @override
  List<Object?> get props => [
        id,
        empresaId,
        data,
        terminalId,
        abertura,
        valorAbertura,
        operadorAberturaId,
        operadorAberturaNome,
        fechamento,
        valorFechamento,
        operadorFechamentoId,
        operadorFechamentoNome,
        situacao,
      ];

  @override
  bool? get stringify => true;
}

class MetaHistoricoDeCaixasDto implements MetaHistoricoDeCaixas {
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

  MetaHistoricoDeCaixasDto({
    required this.totalItems,
    required this.itemCount,
    required this.itemsPerPage,
    required this.totalPages,
    required this.currentPage,
  });

  factory MetaHistoricoDeCaixasDto.fromJson(Map<String, dynamic> json) {
    return MetaHistoricoDeCaixasDto(
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

class PaginaHistoricoDeCaixasDto {
  static PaginaHistoricoDeCaixas fromJson(Map<String, dynamic> json) {
    final itemsJson = (json['items'] as List? ?? const []);
    return PaginaHistoricoDeCaixas(
      meta: MetaHistoricoDeCaixasDto.fromJson(
        json['meta'] as Map<String, dynamic>? ?? const {},
      ),
      items: itemsJson
          .map(
            (e) => CaixaDoHistoricoDto.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
    );
  }
}
