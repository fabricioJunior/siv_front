part of 'editar_preco_da_referencia_bloc.dart';

enum EditarPrecoDaReferenciaStep { inicial, carregando, salvando, sucesso, falha }

class EditarPrecoDaReferenciaState extends Equatable {
  final EditarPrecoDaReferenciaStep step;
  final String? erro;
  final double? valorCarregado;

  const EditarPrecoDaReferenciaState({
    required this.step,
    this.erro,
    this.valorCarregado,
  });

  EditarPrecoDaReferenciaState copyWith({
    EditarPrecoDaReferenciaStep? step,
    String? erro,
    bool clearErro = false,
    double? valorCarregado,
  }) {
    return EditarPrecoDaReferenciaState(
      step: step ?? this.step,
      erro: clearErro ? null : (erro ?? this.erro),
      valorCarregado: valorCarregado ?? this.valorCarregado,
    );
  }

  @override
  List<Object?> get props => [step, erro, valorCarregado];
}
