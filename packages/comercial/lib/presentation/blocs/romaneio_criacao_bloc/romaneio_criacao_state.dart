part of 'romaneio_criacao_bloc.dart';

enum RomaneioCriacaoStep { inicial, processando, sucesso, falha }

class RomaneioCriacaoState extends Equatable {
  final RomaneioCriacaoStep step;
  final Map<String, dynamic>? parametros;
  final Romaneio? romaneio;
  final String? erro;
  final int totalItensProcessados;

  const RomaneioCriacaoState({
    required this.step,
    this.parametros,
    this.romaneio,
    this.erro,
    this.totalItensProcessados = 0,
  });

  const RomaneioCriacaoState.initial()
      : step = RomaneioCriacaoStep.inicial,
        parametros = null,
        romaneio = null,
        erro = null,
        totalItensProcessados = 0;

  RomaneioCriacaoState copyWith({
    RomaneioCriacaoStep? step,
    Object? parametros = _sentinelaRomaneioCriacao,
    Object? romaneio = _sentinelaRomaneioCriacao,
    Object? erro = _sentinelaRomaneioCriacao,
    int? totalItensProcessados,
  }) {
    return RomaneioCriacaoState(
      step: step ?? this.step,
      parametros: identical(parametros, _sentinelaRomaneioCriacao)
          ? this.parametros
          : parametros as Map<String, dynamic>?,
      romaneio: identical(romaneio, _sentinelaRomaneioCriacao)
          ? this.romaneio
          : romaneio as Romaneio?,
      erro: identical(erro, _sentinelaRomaneioCriacao)
          ? this.erro
          : erro as String?,
      totalItensProcessados:
          totalItensProcessados ?? this.totalItensProcessados,
    );
  }

  @override
  List<Object?> get props => [
        step,
        parametros,
        romaneio,
        erro,
        totalItensProcessados,
      ];
}

const Object _sentinelaRomaneioCriacao = Object();
