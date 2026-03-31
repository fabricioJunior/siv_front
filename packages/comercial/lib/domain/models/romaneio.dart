import 'package:core/equals.dart';

abstract class Romaneio implements Equatable {
  int? get id;
  int? get pessoaId;
  String? get pessoaNome;
  int? get funcionarioId;
  String? get funcionarioNome;
  int? get tabelaPrecoId;
  String? get modalidade;
  String? get operacao;
  String? get situacao;
  double? get quantidade;
  double? get valorBruto;
  double? get valorDesconto;
  double? get valorLiquido;
  String? get observacao;
  DateTime? get data;
  DateTime? get criadoEm;
  DateTime? get atualizadoEm;

  factory Romaneio.create({
    int? id,
    int? pessoaId,
    String? pessoaNome,
    int? funcionarioId,
    String? funcionarioNome,
    int? tabelaPrecoId,
    String? modalidade,
    String? operacao,
    String? situacao,
    double? quantidade,
    double? valorBruto,
    double? valorDesconto,
    double? valorLiquido,
    String? observacao,
    DateTime? data,
    DateTime? criadoEm,
    DateTime? atualizadoEm,
  }) = _RomaneioImpl;

  @override
  List<Object?> get props => [
        id,
        pessoaId,
        pessoaNome,
        funcionarioId,
        funcionarioNome,
        tabelaPrecoId,
        modalidade,
        operacao,
        situacao,
        quantidade,
        valorBruto,
        valorDesconto,
        valorLiquido,
        observacao,
        data,
        criadoEm,
        atualizadoEm,
      ];

  @override
  bool? get stringify => true;
}

class _RomaneioImpl implements Romaneio {
  @override
  final int? id;
  @override
  final int? pessoaId;
  @override
  final String? pessoaNome;
  @override
  final int? funcionarioId;
  @override
  final String? funcionarioNome;
  @override
  final int? tabelaPrecoId;
  @override
  final String? modalidade;
  @override
  final String? operacao;
  @override
  final String? situacao;
  @override
  final double? quantidade;
  @override
  final double? valorBruto;
  @override
  final double? valorDesconto;
  @override
  final double? valorLiquido;
  @override
  final String? observacao;
  @override
  final DateTime? data;
  @override
  final DateTime? criadoEm;
  @override
  final DateTime? atualizadoEm;

  const _RomaneioImpl({
    this.id,
    this.pessoaId,
    this.pessoaNome,
    this.funcionarioId,
    this.funcionarioNome,
    this.tabelaPrecoId,
    this.modalidade,
    this.operacao,
    this.situacao,
    this.quantidade,
    this.valorBruto,
    this.valorDesconto,
    this.valorLiquido,
    this.observacao,
    this.data,
    this.criadoEm,
    this.atualizadoEm,
  });

  @override
  List<Object?> get props => [
        id,
        pessoaId,
        pessoaNome,
        funcionarioId,
        funcionarioNome,
        tabelaPrecoId,
        modalidade,
        operacao,
        situacao,
        quantidade,
        valorBruto,
        valorDesconto,
        valorLiquido,
        observacao,
        data,
        criadoEm,
        atualizadoEm,
      ];

  @override
  bool? get stringify => true;
}
