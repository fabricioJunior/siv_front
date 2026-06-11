import 'package:core/equals.dart';

class BalancoItem extends Equatable {
  final int empresaId;
  final int balancoId;
  final int sequencia;
  final int produtoId;
  final double quantidadeOriginal;
  final double quantidadeContada;
  final int operadorId;
  final String? produtoNome;
  final String? tamanho;
  final String? cor;
  final String? referencia;
  final DateTime criadoEm;
  final DateTime atualizadoEm;

  const BalancoItem({
    required this.empresaId,
    required this.balancoId,
    required this.sequencia,
    required this.produtoId,
    required this.quantidadeOriginal,
    required this.quantidadeContada,
    required this.operadorId,
    this.produtoNome,
    this.tamanho,
    this.cor,
    this.referencia,
    required this.criadoEm,
    required this.atualizadoEm,
  });

  double get diferenca => quantidadeContada - quantidadeOriginal;

  BalancoItem copyWith({
    int? empresaId,
    int? balancoId,
    int? sequencia,
    int? produtoId,
    double? quantidadeOriginal,
    double? quantidadeContada,
    int? operadorId,
    String? produtoNome,
    String? tamanho,
    String? cor,
    String? referencia,
    DateTime? criadoEm,
    DateTime? atualizadoEm,
  }) {
    return BalancoItem(
      empresaId: empresaId ?? this.empresaId,
      balancoId: balancoId ?? this.balancoId,
      sequencia: sequencia ?? this.sequencia,
      produtoId: produtoId ?? this.produtoId,
      quantidadeOriginal: quantidadeOriginal ?? this.quantidadeOriginal,
      quantidadeContada: quantidadeContada ?? this.quantidadeContada,
      operadorId: operadorId ?? this.operadorId,
      produtoNome: produtoNome ?? this.produtoNome,
      tamanho: tamanho ?? this.tamanho,
      cor: cor ?? this.cor,
      referencia: referencia ?? this.referencia,
      criadoEm: criadoEm ?? this.criadoEm,
      atualizadoEm: atualizadoEm ?? this.atualizadoEm,
    );
  }

  @override
  List<Object?> get props => [
    empresaId,
    balancoId,
    sequencia,
    produtoId,
    quantidadeOriginal,
    quantidadeContada,
    operadorId,
    produtoNome,
    tamanho,
    cor,
    referencia,
    criadoEm,
    atualizadoEm,
  ];
}
