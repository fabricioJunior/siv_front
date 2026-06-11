import 'package:core/equals.dart';

class BalancoLote extends Equatable {
  final int id;
  final int empresaId;
  final int balancoId;
  final String lote;
  final String? observacao;
  final String situacao; // ativo, cancelado
  final String? motivoCancelamento;
  final int operadorId;
  final DateTime criadoEm;
  final DateTime atualizadoEm;

  const BalancoLote({
    required this.id,
    required this.empresaId,
    required this.balancoId,
    required this.lote,
    this.observacao,
    required this.situacao,
    this.motivoCancelamento,
    required this.operadorId,
    required this.criadoEm,
    required this.atualizadoEm,
  });

  bool get ativo => situacao == 'ativo';
  bool get cancelado => situacao == 'cancelado';

  BalancoLote copyWith({
    int? id,
    int? empresaId,
    int? balancoId,
    String? lote,
    String? observacao,
    String? situacao,
    String? motivoCancelamento,
    int? operadorId,
    DateTime? criadoEm,
    DateTime? atualizadoEm,
  }) {
    return BalancoLote(
      id: id ?? this.id,
      empresaId: empresaId ?? this.empresaId,
      balancoId: balancoId ?? this.balancoId,
      lote: lote ?? this.lote,
      observacao: observacao ?? this.observacao,
      situacao: situacao ?? this.situacao,
      motivoCancelamento: motivoCancelamento ?? this.motivoCancelamento,
      operadorId: operadorId ?? this.operadorId,
      criadoEm: criadoEm ?? this.criadoEm,
      atualizadoEm: atualizadoEm ?? this.atualizadoEm,
    );
  }

  @override
  List<Object?> get props => [
    id,
    empresaId,
    balancoId,
    lote,
    observacao,
    situacao,
    motivoCancelamento,
    operadorId,
    criadoEm,
    atualizadoEm,
  ];
}
