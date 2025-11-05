import 'dart:async';

import 'package:core/bloc.dart';
import 'package:pessoas/domain/models/pessoa.dart';
import 'package:core/equals.dart';
import 'package:pessoas/uses_cases.dart';
part 'pessoas_event.dart';
part 'pessoas_state.dart';

class PessoasBloc extends Bloc<PessoasEvent, PessoasState> {
  final RecuperarPessoas _recuperarPessoas;
  PessoasBloc(
    this._recuperarPessoas,
  ) : super(PessoasInitial()) {
    on<PessoasIniciou>(_onPessoasIniciou);
  }

  FutureOr<void> _onPessoasIniciou(
    PessoasIniciou event,
    Emitter<PessoasState> emit,
  ) async {
    try {
      emit(PessoasCarregarEmProgresso());
      var pessoas = await _recuperarPessoas.call();
      emit(
        PessoasCarregarSucesso(
          pessoas: pessoas.toList(),
          pagina: state.pagina + 1,
        ),
      );
    } catch (e, s) {
      emit(PessoasCarregarFalha());
      addError(e, s);
    }
  }
}
