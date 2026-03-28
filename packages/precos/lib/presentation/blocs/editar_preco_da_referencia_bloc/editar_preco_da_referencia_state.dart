part of 'editar_preco_da_referencia_bloc.dart';

enum EditarPrecoDaReferenciaStep { inicial, salvando, sucesso, falha }

class EditarPrecoDaReferenciaState extends Equatable {
  final EditarPrecoDaReferenciaStep step;
  final String? erro;

  const EditarPrecoDaReferenciaState({required this.step, this.erro});

  EditarPrecoDaReferenciaState copyWith({
    EditarPrecoDaReferenciaStep? step,
    String? erro,
    bool clearErro = false,
  }) {
    return EditarPrecoDaReferenciaState(
      step: step ?? this.step,
      erro: clearErro ? null : (erro ?? this.erro),
    );
  }

  @override
  List<Object?> get props => [step, erro];
}
