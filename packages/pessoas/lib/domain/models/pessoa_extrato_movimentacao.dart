import 'package:core/equals.dart';

abstract class PessoaExtratoMovimentacao implements Equatable {
  int get empresaId;
  int get pessoaId;
  DateTime get data;
  String get tipoDocumento;
  String get tipoMovimento;
  double get valor;
  int? get romaneioId;
  int? get faturaId;
  int? get liquidacao;
  String? get descricao;
  String? get observacao;

  factory PessoaExtratoMovimentacao.create({
    required int empresaId,
    required int pessoaId,
    required DateTime data,
    required String tipoDocumento,
    required String tipoMovimento,
    required double valor,
    int? romaneioId,
    int? faturaId,
    int? liquidacao,
    String? descricao,
    String? observacao,
  }) = _PessoaExtratoMovimentacaoImpl;

  double get valorAssinado {
    final movimentoNormalizado = tipoMovimento.trim().toLowerCase();

    if (movimentoNormalizado.contains('debito') ||
        movimentoNormalizado.contains('débito') ||
        movimentoNormalizado.contains('saida') ||
        movimentoNormalizado.contains('saída')) {
      return -valor.abs();
    }

    return valor.abs();
  }

  @override
  List<Object?> get props => [
        empresaId,
        pessoaId,
        data,
        tipoDocumento,
        tipoMovimento,
        valor,
        romaneioId,
        faturaId,
        liquidacao,
        descricao,
        observacao,
      ];

  @override
  bool? get stringify => true;
}

class _PessoaExtratoMovimentacaoImpl implements PessoaExtratoMovimentacao {
  @override
  final int empresaId;
  @override
  final int pessoaId;
  @override
  final DateTime data;
  @override
  final String tipoDocumento;
  @override
  final String tipoMovimento;
  @override
  final double valor;
  @override
  final int? romaneioId;
  @override
  final int? faturaId;
  @override
  final int? liquidacao;
  @override
  final String? descricao;
  @override
  final String? observacao;

  const _PessoaExtratoMovimentacaoImpl({
    required this.empresaId,
    required this.pessoaId,
    required this.data,
    required this.tipoDocumento,
    required this.tipoMovimento,
    required this.valor,
    this.romaneioId,
    this.faturaId,
    this.liquidacao,
    this.descricao,
    this.observacao,
  });

  @override
  double get valorAssinado {
    final movimentoNormalizado = tipoMovimento.trim().toLowerCase();

    if (movimentoNormalizado.contains('debito') ||
        movimentoNormalizado.contains('débito') ||
        movimentoNormalizado.contains('saida') ||
        movimentoNormalizado.contains('saída')) {
      return -valor.abs();
    }

    return valor.abs();
  }

  @override
  List<Object?> get props => [
        empresaId,
        pessoaId,
        data,
        tipoDocumento,
        tipoMovimento,
        valor,
        romaneioId,
        faturaId,
        liquidacao,
        descricao,
        observacao,
      ];

  @override
  bool? get stringify => true;
}
