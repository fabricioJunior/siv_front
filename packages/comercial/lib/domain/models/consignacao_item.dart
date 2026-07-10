import 'package:core/equals.dart';

abstract class ConsignacaoItem implements Equatable {
  int? get empresaId;
  int? get consignacaoId;
  int? get pessoaId;
  int? get romaneioId;
  int? get sequencia;
  int? get produtoId;
  double? get solicitado;
  double? get valorSolicitado;
  double? get devolvido;
  double? get valorDevolvido;
  double? get acertado;
  double? get valorAcertado;
  double? get pendente;
  double? get valorPendente;
  int? get operadorId;

  factory ConsignacaoItem.create({
    int? empresaId,
    int? consignacaoId,
    int? pessoaId,
    int? romaneioId,
    int? sequencia,
    int? produtoId,
    double? solicitado,
    double? valorSolicitado,
    double? devolvido,
    double? valorDevolvido,
    double? acertado,
    double? valorAcertado,
    double? pendente,
    double? valorPendente,
    int? operadorId,
  }) = _ConsignacaoItemImpl;

  @override
  List<Object?> get props => [
        empresaId,
        consignacaoId,
        pessoaId,
        romaneioId,
        sequencia,
        produtoId,
        solicitado,
        valorSolicitado,
        devolvido,
        valorDevolvido,
        acertado,
        valorAcertado,
        pendente,
        valorPendente,
        operadorId,
      ];

  @override
  bool? get stringify => true;
}

class _ConsignacaoItemImpl implements ConsignacaoItem {
  @override
  final int? empresaId;
  @override
  final int? consignacaoId;
  @override
  final int? pessoaId;
  @override
  final int? romaneioId;
  @override
  final int? sequencia;
  @override
  final int? produtoId;
  @override
  final double? solicitado;
  @override
  final double? valorSolicitado;
  @override
  final double? devolvido;
  @override
  final double? valorDevolvido;
  @override
  final double? acertado;
  @override
  final double? valorAcertado;
  @override
  final double? pendente;
  @override
  final double? valorPendente;
  @override
  final int? operadorId;

  const _ConsignacaoItemImpl({
    this.empresaId,
    this.consignacaoId,
    this.pessoaId,
    this.romaneioId,
    this.sequencia,
    this.produtoId,
    this.solicitado,
    this.valorSolicitado,
    this.devolvido,
    this.valorDevolvido,
    this.acertado,
    this.valorAcertado,
    this.pendente,
    this.valorPendente,
    this.operadorId,
  });

  @override
  List<Object?> get props => [
        empresaId,
        consignacaoId,
        pessoaId,
        romaneioId,
        sequencia,
        produtoId,
        solicitado,
        valorSolicitado,
        devolvido,
        valorDevolvido,
        acertado,
        valorAcertado,
        pendente,
        valorPendente,
        operadorId,
      ];

  @override
  bool? get stringify => true;
}
