import 'package:core/equals.dart';

/// Faixa de desconto resgatável com pontos de fidelidade. tipo: 'valor' | 'percentual'.
class DescontoFidelidade extends Equatable {
  final int? id;
  final int pontos;
  final String tipo;
  final double valor;
  final bool cumulativo;
  final bool ativo;

  const DescontoFidelidade({
    this.id,
    required this.pontos,
    required this.tipo,
    required this.valor,
    required this.cumulativo,
    this.ativo = true,
  });

  @override
  List<Object?> get props => [id, pontos, tipo, valor, cumulativo, ativo];
}
