import 'dart:async';

import 'package:core/bloc.dart';
import 'package:core/equals.dart';
import 'package:produtos/models.dart';
import 'package:produtos/use_cases.dart';

part 'marcas_event.dart';
part 'marcas_state.dart';

class MarcasBloc extends Bloc<MarcasEvent, MarcasState> {
  final RecuperarMarcas _recuperarMarcas;
  final DesativarMarca _desativarMarca;

  MarcasBloc(this._recuperarMarcas, this._desativarMarca)
    : super(const MarcasInitial()) {
    on<MarcasIniciou>(_onMarcasIniciou);
    on<MarcasDesativar>(_onMarcasDesativar);
  }

  FutureOr<void> _onMarcasIniciou(
    MarcasIniciou event,
    Emitter<MarcasState> emit,
  ) async {
    try {
      emit(const MarcasCarregarEmProgresso());
      var marcas = await _recuperarMarcas.call(
        nome: event.busca,
        inativa: event.inativa,
      );
      emit(MarcasCarregarSucesso(marcas: marcas.toList()));
    } catch (e, s) {
      emit(const MarcasCarregarFalha());
      addError(e, s);
    }
  }

  FutureOr<void> _onMarcasDesativar(
    MarcasDesativar event,
    Emitter<MarcasState> emit,
  ) async {
    try {
      emit(MarcasDesativarEmProgresso(marcas: state.marcas));
      await _desativarMarca.call(event.id);
      final marcasFiltradas = state.marcas
          .where((marca) => marca.id != event.id)
          .toList();
      emit(MarcasDesativarSucesso(marcas: marcasFiltradas));
    } catch (e, s) {
      emit(MarcasDesativarFalha(marcas: state.marcas));
      addError(e, s);
    }
  }
}
