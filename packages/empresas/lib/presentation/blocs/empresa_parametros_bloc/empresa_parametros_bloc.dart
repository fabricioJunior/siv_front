import 'dart:async';

import 'package:core/bloc.dart';
import 'package:core/equals.dart';
import 'package:empresas/domain/entities/empresa_parametro.dart';
import 'package:empresas/use_cases.dart';

part 'empresa_parametros_event.dart';
part 'empresa_parametros_state.dart';

class EmpresaParametrosBloc
    extends Bloc<EmpresaParametrosEvent, EmpresaParametrosState> {
  final RecuperarParametrosEmpresa recuperarParametrosEmpresa;
  final AtualizarParametrosEmpresa atualizarParametrosEmpresa;

  EmpresaParametrosBloc(
    this.recuperarParametrosEmpresa,
    this.atualizarParametrosEmpresa,
  ) : super(const EmpresaParametrosState(step: EmpresaParametrosStep.inicial)) {
    on<EmpresaParametrosIniciou>(_onIniciou);
    on<EmpresaParametroTextoAlterado>(_onTextoAlterado);
    on<EmpresaParametroCheckboxAlterado>(_onCheckboxAlterado);
    on<EmpresaParametrosSalvou>(_onSalvou);
  }

  FutureOr<void> _onIniciou(
    EmpresaParametrosIniciou event,
    Emitter<EmpresaParametrosState> emit,
  ) async {
    emit(state.copyWith(step: EmpresaParametrosStep.carregando));
    try {
      final parametros = await recuperarParametrosEmpresa.call(event.empresaId);
      emit(
        state.copyWith(
          empresaId: event.empresaId,
          parametros: parametros,
          parametrosOriginais: List<EmpresaParametro>.from(parametros),
          step: EmpresaParametrosStep.carregado,
        ),
      );
    } catch (e, s) {
      addError(e, s);
      emit(state.copyWith(step: EmpresaParametrosStep.falha));
    }
  }

  FutureOr<void> _onTextoAlterado(
    EmpresaParametroTextoAlterado event,
    Emitter<EmpresaParametrosState> emit,
  ) {
    final parametrosAtualizados = state.parametros
        .map(
          (parametro) => parametro.id == event.parametroId
              ? parametro.copyWith(valorTexto: event.valor)
              : parametro,
        )
        .toList();

    emit(
      state.copyWith(
        parametros: parametrosAtualizados,
        step: EmpresaParametrosStep.editando,
      ),
    );
  }

  FutureOr<void> _onCheckboxAlterado(
    EmpresaParametroCheckboxAlterado event,
    Emitter<EmpresaParametrosState> emit,
  ) {
    final parametrosAtualizados = state.parametros
        .map(
          (parametro) => parametro.id == event.parametroId
              ? parametro.copyWith(valorBooleano: event.valor)
              : parametro,
        )
        .toList();

    emit(
      state.copyWith(
        parametros: parametrosAtualizados,
        step: EmpresaParametrosStep.editando,
      ),
    );
  }

  FutureOr<void> _onSalvou(
    EmpresaParametrosSalvou event,
    Emitter<EmpresaParametrosState> emit,
  ) async {
    if (state.empresaId == null) {
      return;
    }

    try {
      final originaisPorChave = {
        for (final parametro in state.parametrosOriginais)
          parametro.chave: parametro,
      };

      final parametrosAlterados = state.parametros.where((atual) {
        final original = originaisPorChave[atual.chave];
        if (original == null) {
          return true;
        }

        if (atual.ehCheckbox) {
          return (atual.valorBooleano ?? false) !=
              (original.valorBooleano ?? false);
        }

        return (atual.valorTexto ?? '').trim() !=
            (original.valorTexto ?? '').trim();
      }).toList();

      if (parametrosAlterados.isEmpty) {
        emit(state.copyWith(step: EmpresaParametrosStep.salvo));
        return;
      }

      final parametroTextoEsvaziado =
          parametrosAlterados.cast<EmpresaParametro?>().firstWhere(
        (atual) {
          if (atual == null || atual.ehCheckbox) {
            return false;
          }

          final original = originaisPorChave[atual.chave];
          if (original == null) {
            return false;
          }

          final originalTinhaValor =
              (original.valorTexto ?? '').trim().isNotEmpty;
          final atualEstaVazio = (atual.valorTexto ?? '').trim().isEmpty;

          return originalTinhaValor && atualEstaVazio;
        },
        orElse: () => null,
      );

      if (parametroTextoEsvaziado != null) {
        emit(
          state.copyWith(
            step: EmpresaParametrosStep.validacaoInvalida,
            descricaoParametroInvalido: parametroTextoEsvaziado.descricao,
          ),
        );
        return;
      }

      emit(state.copyWith(step: EmpresaParametrosStep.salvando));

      final atualizados = await atualizarParametrosEmpresa.call(
        empresaId: state.empresaId!,
        parametros: parametrosAlterados,
      );

      emit(
        state.copyWith(
          parametros: atualizados,
          parametrosOriginais: List<EmpresaParametro>.from(atualizados),
          step: EmpresaParametrosStep.salvo,
        ),
      );
    } catch (e, s) {
      addError(e, s);
      emit(state.copyWith(step: EmpresaParametrosStep.falha));
    }
  }
}
