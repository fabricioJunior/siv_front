import 'package:core/equals.dart';

class FaixaResgate extends Equatable {
  final int id;
  final int pontos;
  final String tipo; // 'valor' | 'percentual'
  final double valor;
  final bool cumulativo;
  final bool disponivel;

  const FaixaResgate({
    required this.id,
    required this.pontos,
    required this.tipo,
    required this.valor,
    required this.cumulativo,
    required this.disponivel,
  });

  bool get ehPercentual => tipo == 'percentual';

  @override
  List<Object?> get props => [id, pontos, tipo, valor, cumulativo, disponivel];
}

class OpcoesResgatePontos extends Equatable {
  final int saldo;
  final double? valorPorPonto;
  final bool cumulativoValorPorPonto;
  final List<FaixaResgate> faixas;

  const OpcoesResgatePontos({
    required this.saldo,
    this.valorPorPonto,
    this.cumulativoValorPorPonto = false,
    this.faixas = const [],
  });

  bool get possuiOpcoes => saldo > 0 && (valorPorPonto != null || faixas.isNotEmpty);

  @override
  List<Object?> get props =>
      [saldo, valorPorPonto, cumulativoValorPorPonto, faixas];
}
