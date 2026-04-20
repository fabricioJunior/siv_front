part of 'dispositivo_bloc.dart';

const Object _sentinelaDispositivo = Object();

class DispositivoState extends Equatable {
  final DispositivoStep step;
  final InfoDispositivo? info;

  const DispositivoState({
    required this.step,
    this.info,
  });

  DispositivoState copyWith({
    DispositivoStep? step,
    Object? info = _sentinelaDispositivo,
  }) {
    return DispositivoState(
      step: step ?? this.step,
      info: identical(info, _sentinelaDispositivo)
          ? this.info
          : info as InfoDispositivo?,
    );
  }

  @override
  List<Object?> get props => [step, info];
}

enum DispositivoStep {
  inicial,
  carregando,
  carregado,
  apagando,
  apagado,
  falha,
}
