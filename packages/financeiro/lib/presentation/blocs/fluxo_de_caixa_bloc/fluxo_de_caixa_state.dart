part of 'fluxo_de_caixa_bloc.dart';

abstract class FluxoDeCaixaState extends Equatable {
  final Caixa? caixa;
  final int? caixaId;
  final List<ExtratoCaixa> extratos;
  final double totalEntradas;
  final double totalSaidas;
  final double saldo;

  const FluxoDeCaixaState({
    required this.caixa,
    required this.caixaId,
    required this.extratos,
    required this.totalEntradas,
    required this.totalSaidas,
    required this.saldo,
  });

  @override
  List<Object?> get props => [
        caixa,
        caixaId,
        extratos,
        totalEntradas,
        totalSaidas,
        saldo,
      ];
}

class FluxoDeCaixaInitial extends FluxoDeCaixaState {
  const FluxoDeCaixaInitial()
      : super(
          caixa: null,
          caixaId: null,
          extratos: const [],
          totalEntradas: 0,
          totalSaidas: 0,
          saldo: 0,
        );
}

class FluxoDeCaixaCarregarEmProgresso extends FluxoDeCaixaState {
  const FluxoDeCaixaCarregarEmProgresso({
    required super.caixa,
    required super.caixaId,
    required super.extratos,
    required super.totalEntradas,
    required super.totalSaidas,
    required super.saldo,
  });
}

class FluxoDeCaixaCarregarSucesso extends FluxoDeCaixaState {
  const FluxoDeCaixaCarregarSucesso({
    required super.caixa,
    required super.caixaId,
    required super.extratos,
    required super.totalEntradas,
    required super.totalSaidas,
    required super.saldo,
  });
}

class FluxoDeCaixaCarregarFalha extends FluxoDeCaixaState {
  const FluxoDeCaixaCarregarFalha({
    required super.caixa,
    required super.caixaId,
    required super.extratos,
    required super.totalEntradas,
    required super.totalSaidas,
    required super.saldo,
  });
}

class FluxoDeCaixaAbrirEmProgresso extends FluxoDeCaixaState {
  const FluxoDeCaixaAbrirEmProgresso({
    required super.caixa,
    required super.caixaId,
    required super.extratos,
    required super.totalEntradas,
    required super.totalSaidas,
    required super.saldo,
  });
}

class FluxoDeCaixaAbrirSucesso extends FluxoDeCaixaState {
  const FluxoDeCaixaAbrirSucesso({
    required super.caixa,
    required super.caixaId,
    required super.extratos,
    required super.totalEntradas,
    required super.totalSaidas,
    required super.saldo,
  });
}

class FluxoDeCaixaAbrirFalha extends FluxoDeCaixaState {
  const FluxoDeCaixaAbrirFalha({
    required super.caixa,
    required super.caixaId,
    required super.extratos,
    required super.totalEntradas,
    required super.totalSaidas,
    required super.saldo,
  });
}

class FluxoDeCaixaFecharEmProgresso extends FluxoDeCaixaState {
  const FluxoDeCaixaFecharEmProgresso({
    required super.caixa,
    required super.caixaId,
    required super.extratos,
    required super.totalEntradas,
    required super.totalSaidas,
    required super.saldo,
  });
}

class FluxoDeCaixaFecharSucesso extends FluxoDeCaixaState {
  const FluxoDeCaixaFecharSucesso({
    required super.caixa,
    required super.caixaId,
    required super.extratos,
    required super.totalEntradas,
    required super.totalSaidas,
    required super.saldo,
  });
}

class FluxoDeCaixaFecharFalha extends FluxoDeCaixaState {
  const FluxoDeCaixaFecharFalha({
    required super.caixa,
    required super.caixaId,
    required super.extratos,
    required super.totalEntradas,
    required super.totalSaidas,
    required super.saldo,
  });
}
