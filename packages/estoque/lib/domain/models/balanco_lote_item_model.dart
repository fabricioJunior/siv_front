import 'package:core/equals.dart';

class BalancoLoteItem extends Equatable {
  final int empresaId;
  final int balancoId;
  final int loteId;
  final int sequencia;
  final int produtoId;
  final double quantidadeContada;
  final int operadorId;
  final DateTime criadoEm;
  final DateTime atualizadoEm;

  const BalancoLoteItem({
    required this.empresaId,
    required this.balancoId,
    required this.loteId,
    required this.sequencia,
    required this.produtoId,
    required this.quantidadeContada,
    required this.operadorId,
    required this.criadoEm,
    required this.atualizadoEm,
  });

  BalancoLoteItem copyWith({
    int? empresaId,
    int? balancoId,
    int? loteId,
    int? sequencia,
    int? produtoId,
    double? quantidadeContada,
    int? operadorId,
    DateTime? criadoEm,
    DateTime? atualizadoEm,
  }) {
    return BalancoLoteItem(
      empresaId: empresaId ?? this.empresaId,
      balancoId: balancoId ?? this.balancoId,
      loteId: loteId ?? this.loteId,
      sequencia: sequencia ?? this.sequencia,
      produtoId: produtoId ?? this.produtoId,
      quantidadeContada: quantidadeContada ?? this.quantidadeContada,
      operadorId: operadorId ?? this.operadorId,
      criadoEm: criadoEm ?? this.criadoEm,
      atualizadoEm: atualizadoEm ?? this.atualizadoEm,
    );
  }

  @override
  List<Object?> get props => [
    empresaId,
    balancoId,
    loteId,
    sequencia,
    produtoId,
    quantidadeContada,
    operadorId,
    criadoEm,
    atualizadoEm,
  ];
}
