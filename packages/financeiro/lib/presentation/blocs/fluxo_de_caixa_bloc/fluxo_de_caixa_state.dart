part of 'fluxo_de_caixa_bloc.dart';

abstract class FluxoDeCaixaState extends Equatable {
  final Caixa? caixa;
  final int? caixaId;
  final List<ExtratoCaixa> extratos;

  const FluxoDeCaixaState({
    required this.caixa,
    required this.caixaId,
    required this.extratos,
  });

  @override
  List<Object?> get props => [caixa, caixaId, extratos];
}

class FluxoDeCaixaInitial extends FluxoDeCaixaState {
  const FluxoDeCaixaInitial()
      : super(
          caixa: null,
          caixaId: null,
          extratos: const [],
        );
}

class FluxoDeCaixaCarregarEmProgresso extends FluxoDeCaixaState {
  const FluxoDeCaixaCarregarEmProgresso({
    required super.caixa,
    required super.caixaId,
    required super.extratos,
  });
}

class FluxoDeCaixaCarregarSucesso extends FluxoDeCaixaState {
  const FluxoDeCaixaCarregarSucesso({
    required super.caixa,
    required super.caixaId,
    required super.extratos,
  });
}

class FluxoDeCaixaCarregarFalha extends FluxoDeCaixaState {
  const FluxoDeCaixaCarregarFalha({
    required super.caixa,
    required super.caixaId,
    required super.extratos,
  });
}

class FluxoDeCaixaAbrirEmProgresso extends FluxoDeCaixaState {
  const FluxoDeCaixaAbrirEmProgresso({
    required super.caixa,
    required super.caixaId,
    required super.extratos,
  });
}

class FluxoDeCaixaAbrirSucesso extends FluxoDeCaixaState {
  const FluxoDeCaixaAbrirSucesso({
    required super.caixa,
    required super.caixaId,
    required super.extratos,
  });
}

class FluxoDeCaixaAbrirFalha extends FluxoDeCaixaState {
  const FluxoDeCaixaAbrirFalha({
    required super.caixa,
    required super.caixaId,
    required super.extratos,
  });
}

class FluxoDeCaixaFecharEmProgresso extends FluxoDeCaixaState {
  const FluxoDeCaixaFecharEmProgresso({
    required super.caixa,
    required super.caixaId,
    required super.extratos,
  });
}

class FluxoDeCaixaFecharSucesso extends FluxoDeCaixaState {
  const FluxoDeCaixaFecharSucesso({
    required super.caixa,
    required super.caixaId,
    required super.extratos,
  });
}

class FluxoDeCaixaFecharFalha extends FluxoDeCaixaState {
  const FluxoDeCaixaFecharFalha({
    required super.caixa,
    required super.caixaId,
    required super.extratos,
  });
}
