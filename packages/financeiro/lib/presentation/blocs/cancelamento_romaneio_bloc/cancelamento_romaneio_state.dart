part of 'cancelamento_romaneio_bloc.dart';

class CancelamentoRomaneioState extends Equatable {
  final int? idRomaneio;
  final String motivo;
  final String? erro;
  final CancelamentoRomaneioStep step;

  const CancelamentoRomaneioState({
    this.idRomaneio,
    this.motivo = '',
    this.erro,
    required this.step,
  });

  const CancelamentoRomaneioState.initial()
      : idRomaneio = null,
        motivo = '',
        erro = null,
        step = CancelamentoRomaneioStep.inicial;

  CancelamentoRomaneioState copyWith({
    int? idRomaneio,
    String? motivo,
    String? erro,
    CancelamentoRomaneioStep? step,
  }) {
    return CancelamentoRomaneioState(
      idRomaneio: idRomaneio ?? this.idRomaneio,
      motivo: motivo ?? this.motivo,
      erro: erro,
      step: step ?? this.step,
    );
  }

  @override
  List<Object?> get props => [idRomaneio, motivo, erro, step];
}

enum CancelamentoRomaneioStep {
  inicial,
  editando,
  cancelando,
  cancelado,
  validacaoInvalida,
  falha,
}