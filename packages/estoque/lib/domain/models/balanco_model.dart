import 'package:core/equals.dart';

class Balanco extends Equatable {
  final int id;
  final int empresaId;
  final DateTime data;
  final String? observacao;
  final String situacao; // em_andamento, encerrado, cancelado
  final String? motivoCancelamento;
  final int operadorId;
  final DateTime criadoEm;
  final DateTime atualizadoEm;

  const Balanco({
    required this.id,
    required this.empresaId,
    required this.data,
    this.observacao,
    required this.situacao,
    this.motivoCancelamento,
    required this.operadorId,
    required this.criadoEm,
    required this.atualizadoEm,
  });

  bool get emAndamento => situacao == 'em_andamento';
  bool get encerrado => situacao == 'encerrado';
  bool get cancelado => situacao == 'cancelado';

  Balanco copyWith({
    int? id,
    int? empresaId,
    DateTime? data,
    String? observacao,
    String? situacao,
    String? motivoCancelamento,
    int? operadorId,
    DateTime? criadoEm,
    DateTime? atualizadoEm,
  }) {
    return Balanco(
      id: id ?? this.id,
      empresaId: empresaId ?? this.empresaId,
      data: data ?? this.data,
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
    data,
    observacao,
    situacao,
    motivoCancelamento,
    operadorId,
    criadoEm,
    atualizadoEm,
  ];
}
