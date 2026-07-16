import 'package:financeiro/domain/models/caixa.dart';
import 'package:financeiro/domain/models/contagem_do_caixa_item.dart';
import 'package:financeiro/domain/models/recibo_fechamento_caixa.dart';

class ReciboFechamentoCaixaDto implements ReciboFechamentoCaixa {
  @override
  final int caixaId;

  @override
  final int empresaId;

  @override
  final int terminalId;

  @override
  final DateTime data;

  @override
  final DateTime? abertura;

  @override
  final DateTime? fechamento;

  @override
  final double valorAbertura;

  @override
  final double? valorFechamento;

  @override
  final SituacaoCaixa situacao;

  @override
  final int operadorAberturaId;

  @override
  final String? operadorAberturaNome;

  @override
  final int? operadorFechamentoId;

  @override
  final String? operadorFechamentoNome;

  @override
  final FaturamentoResumoRecibo faturamentoCaixa;

  @override
  final FaturamentoResumoRecibo faturamentoDia;

  @override
  final FaturamentoMesRecibo faturamentoMes;

  @override
  final List<ValorContadoRecibo> valoresContados;

  @override
  final List<MovimentacaoRecibo> sangrias;

  @override
  final List<MovimentacaoRecibo> suprimentos;

  const ReciboFechamentoCaixaDto({
    required this.caixaId,
    required this.empresaId,
    required this.terminalId,
    required this.data,
    required this.abertura,
    required this.fechamento,
    required this.valorAbertura,
    required this.valorFechamento,
    required this.situacao,
    required this.operadorAberturaId,
    required this.operadorAberturaNome,
    required this.operadorFechamentoId,
    required this.operadorFechamentoNome,
    required this.faturamentoCaixa,
    required this.faturamentoDia,
    required this.faturamentoMes,
    required this.valoresContados,
    required this.sangrias,
    required this.suprimentos,
  });

  factory ReciboFechamentoCaixaDto.fromJson(Map<String, dynamic> json) {
    final situacaoValue =
        (json['situacao']?.toString().toLowerCase() ?? 'fechado').trim();

    return ReciboFechamentoCaixaDto(
      caixaId: int.tryParse(json['caixaId']?.toString() ?? '') ?? 0,
      empresaId: int.tryParse(json['empresaId']?.toString() ?? '') ?? 0,
      terminalId: (json['terminalId'] as num?)?.toInt() ?? 0,
      data: DateTime.tryParse(json['data']?.toString() ?? '') ?? DateTime.now(),
      abertura: DateTime.tryParse(json['abertura']?.toString() ?? ''),
      fechamento: DateTime.tryParse(json['fechamento']?.toString() ?? ''),
      valorAbertura: _parseDouble(json['valorAbertura']) ?? 0,
      valorFechamento: _parseDouble(json['valorFechamento']),
      situacao: switch (situacaoValue) {
        'aberto' => SituacaoCaixa.aberto,
        'contagem' => SituacaoCaixa.contagem,
        _ => SituacaoCaixa.fechado,
      },
      operadorAberturaId:
          int.tryParse(json['operadorAberturaId']?.toString() ?? '') ?? 0,
      operadorAberturaNome: json['operadorAberturaNome']?.toString(),
      operadorFechamentoId:
          int.tryParse(json['operadorFechamentoId']?.toString() ?? ''),
      operadorFechamentoNome: json['operadorFechamentoNome']?.toString(),
      faturamentoCaixa: _FaturamentoResumoReciboDto.fromJson(
        json['faturamentoCaixa'] as Map<String, dynamic>? ?? const {},
      ),
      faturamentoDia: _FaturamentoResumoReciboDto.fromJson(
        json['faturamentoDia'] as Map<String, dynamic>? ?? const {},
      ),
      faturamentoMes: _FaturamentoMesReciboDto.fromJson(
        json['faturamentoMes'] as Map<String, dynamic>? ?? const {},
      ),
      valoresContados: ((json['valoresContados'] as List?) ?? const [])
          .map(
            (item) => _ValorContadoReciboDto.fromJson(
              item as Map<String, dynamic>,
            ),
          )
          .toList(),
      sangrias: ((json['sangrias'] as List?) ?? const [])
          .map(
            (item) =>
                _MovimentacaoReciboDto.fromJson(item as Map<String, dynamic>),
          )
          .toList(),
      suprimentos: ((json['suprimentos'] as List?) ?? const [])
          .map(
            (item) =>
                _MovimentacaoReciboDto.fromJson(item as Map<String, dynamic>),
          )
          .toList(),
    );
  }

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
  }

  @override
  List<Object?> get props => [
        caixaId,
        empresaId,
        terminalId,
        data,
        abertura,
        fechamento,
        valorAbertura,
        valorFechamento,
        situacao,
        operadorAberturaId,
        operadorAberturaNome,
        operadorFechamentoId,
        operadorFechamentoNome,
        faturamentoCaixa,
        faturamentoDia,
        faturamentoMes,
        valoresContados,
        sangrias,
        suprimentos,
      ];

  @override
  bool? get stringify => true;
}

class _FaturamentoResumoReciboDto implements FaturamentoResumoRecibo {
  @override
  final double total;

  @override
  final int quantidadeVendas;

  @override
  final int quantidadeProdutosVendidos;

  @override
  final double ticketMedio;

  const _FaturamentoResumoReciboDto({
    required this.total,
    required this.quantidadeVendas,
    required this.quantidadeProdutosVendidos,
    required this.ticketMedio,
  });

  factory _FaturamentoResumoReciboDto.fromJson(Map<String, dynamic> json) {
    return _FaturamentoResumoReciboDto(
      total: ReciboFechamentoCaixaDto._parseDouble(json['total']) ?? 0,
      quantidadeVendas:
          int.tryParse(json['quantidadeVendas']?.toString() ?? '') ?? 0,
      quantidadeProdutosVendidos: int.tryParse(
            json['quantidadeProdutosVendidos']?.toString() ?? '',
          ) ??
          0,
      ticketMedio: ReciboFechamentoCaixaDto._parseDouble(
            json['ticketMedio'],
          ) ??
          0,
    );
  }

  @override
  List<Object?> get props =>
      [total, quantidadeVendas, quantidadeProdutosVendidos, ticketMedio];

  @override
  bool? get stringify => true;
}

class _FaturamentoMesReciboDto implements FaturamentoMesRecibo {
  @override
  final double total;

  const _FaturamentoMesReciboDto({required this.total});

  factory _FaturamentoMesReciboDto.fromJson(Map<String, dynamic> json) {
    return _FaturamentoMesReciboDto(
      total: ReciboFechamentoCaixaDto._parseDouble(json['total']) ?? 0,
    );
  }

  @override
  List<Object?> get props => [total];

  @override
  bool? get stringify => true;
}

class _ValorContadoReciboDto implements ValorContadoRecibo {
  @override
  final TipoContagemDoCaixaItem tipoDocumento;

  @override
  final double valor;

  const _ValorContadoReciboDto({
    required this.tipoDocumento,
    required this.valor,
  });

  factory _ValorContadoReciboDto.fromJson(Map<String, dynamic> json) {
    return _ValorContadoReciboDto(
      tipoDocumento: _parseTipo(json['tipoDocumento']),
      valor: ReciboFechamentoCaixaDto._parseDouble(json['valor']) ?? 0,
    );
  }

  static TipoContagemDoCaixaItem _parseTipo(dynamic value) {
    final str = value?.toString() ?? '';
    final normalizado = _normalizarTexto(str);
    return TipoContagemDoCaixaItem.values.firstWhere(
      (e) => e.name == str || _normalizarTexto(e.name) == normalizado,
      orElse: () => TipoContagemDoCaixaItem.dinheiro,
    );
  }

  static String _normalizarTexto(String value) {
    return value
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]'), '');
  }

  @override
  List<Object?> get props => [tipoDocumento, valor];

  @override
  bool? get stringify => true;
}

class _MovimentacaoReciboDto implements MovimentacaoRecibo {
  @override
  final int id;

  @override
  final double valor;

  @override
  final String origem;

  @override
  final String? descricao;

  @override
  final DateTime dataHora;

  @override
  final int operadorId;

  @override
  final String? operadorNome;

  @override
  final bool cancelado;

  @override
  final String? motivoCancelamento;

  const _MovimentacaoReciboDto({
    required this.id,
    required this.valor,
    required this.origem,
    required this.descricao,
    required this.dataHora,
    required this.operadorId,
    required this.operadorNome,
    required this.cancelado,
    required this.motivoCancelamento,
  });

  factory _MovimentacaoReciboDto.fromJson(Map<String, dynamic> json) {
    return _MovimentacaoReciboDto(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      valor: ReciboFechamentoCaixaDto._parseDouble(json['valor']) ?? 0,
      origem: json['origem']?.toString() ?? '',
      descricao: json['descricao']?.toString(),
      dataHora: DateTime.tryParse(json['dataHora']?.toString() ?? '') ??
          DateTime.now(),
      operadorId: int.tryParse(json['operadorId']?.toString() ?? '') ?? 0,
      operadorNome: json['operadorNome']?.toString(),
      cancelado: json['cancelado'] == true,
      motivoCancelamento: json['motivoCancelamento']?.toString(),
    );
  }

  @override
  List<Object?> get props => [
        id,
        valor,
        origem,
        descricao,
        dataHora,
        operadorId,
        operadorNome,
        cancelado,
        motivoCancelamento,
      ];

  @override
  bool? get stringify => true;
}
