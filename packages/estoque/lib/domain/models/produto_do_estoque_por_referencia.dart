import 'package:core/equals.dart';

class ProdutoDoEstoquePorReferencia extends Equatable {
  final int referenciaId;
  final String? referenciaIdExterno;
  final String nome;
  final double saldoTotal;
  final int quantidadeVariacoes;
  final DateTime? atualizadoEm;

  const ProdutoDoEstoquePorReferencia({
    required this.referenciaId,
    required this.referenciaIdExterno,
    required this.nome,
    required this.saldoTotal,
    required this.quantidadeVariacoes,
    required this.atualizadoEm,
  });

  @override
  List<Object?> get props => [
    referenciaId,
    referenciaIdExterno,
    nome,
    saldoTotal,
    quantidadeVariacoes,
    atualizadoEm,
  ];

  @override
  bool? get stringify => true;
}
