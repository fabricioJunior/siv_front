part of 'tabelas_de_preco_bloc.dart';

abstract class TabelasDePrecoState extends Equatable {
  List<TabelaDePreco> get tabelas => [];

  TabelaDePreco? get tabelaDePreco => null;

  const TabelasDePrecoState();

  @override
  List<Object?> get props => [tabelas];
}

class TabelasDePrecoInitial extends TabelasDePrecoState {
  const TabelasDePrecoInitial();
}

class TabelasDePrecoCarregarEmProgresso extends TabelasDePrecoState {
  const TabelasDePrecoCarregarEmProgresso();
}

class TabelasDePrecoCarregarSucesso extends TabelasDePrecoState {
  @override
  final List<TabelaDePreco> tabelas;

  @override
  final TabelaDePreco? tabelaDePreco;

  const TabelasDePrecoCarregarSucesso({
    required this.tabelas,
    required this.tabelaDePreco,
  });
}

class TabelasDePrecoCarregarFalha extends TabelasDePrecoState {
  const TabelasDePrecoCarregarFalha();
}

class TabelasDePrecoDesativarEmProgresso extends TabelasDePrecoState {
  @override
  final List<TabelaDePreco> tabelas;

  const TabelasDePrecoDesativarEmProgresso({required this.tabelas});
}

class TabelasDePrecoDesativarSucesso extends TabelasDePrecoState {
  @override
  final List<TabelaDePreco> tabelas;

  const TabelasDePrecoDesativarSucesso({required this.tabelas});
}

class TabelasDePrecoDesativarFalha extends TabelasDePrecoState {
  @override
  final List<TabelaDePreco> tabelas;

  const TabelasDePrecoDesativarFalha({required this.tabelas});
}
