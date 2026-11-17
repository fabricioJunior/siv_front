import 'dart:async';

import 'package:core/bloc.dart';
import 'package:core/equals.dart';
import 'package:core/remote_data_sourcers.dart';
import 'package:financeiro/models.dart';
import 'package:financeiro/use_cases.dart';

part 'despesa_do_caixa_event.dart';
part 'despesa_do_caixa_state.dart';

class DespesaDoCaixaBloc
    extends Bloc<DespesaDoCaixaEvent, DespesaDoCaixaState> {
  final CriarDespesaDoCaixa _criarDespesa;
  final RecuperarCategoriasDespesaDoCaixa _recuperarCategorias;

  DespesaDoCaixaBloc(this._criarDespesa, this._recuperarCategorias)
      : super(const DespesaDoCaixaState()) {
    on<DespesaDoCaixaIniciou>(_onIniciou);
    on<DespesaDoCaixaCampoAlterado>(_onCampoAlterado);
    on<DespesaDoCaixaSalvou>(_onSalvou);
  }

  FutureOr<void> _onIniciou(
    DespesaDoCaixaIniciou event,
    Emitter<DespesaDoCaixaState> emit,
  ) async {
    emit(
      state.copyWith(
        caixaId: event.caixaId,
        step: DespesaDoCaixaStep.editando,
        erro: null,
      ),
    );

    try {
      final categorias = await _recuperarCategorias.call(
        caixaId: event.caixaId,
      );
      emit(state.copyWith(categorias: categorias, erro: null));
    } catch (e, s) {
      emit(
        state.copyWith(
          step: DespesaDoCaixaStep.falha,
          erro: mensagemDeErroApi(e, 'Falha ao carregar as categorias.'),
        ),
      );
      addError(e, s);
    }
  }

  FutureOr<void> _onCampoAlterado(
    DespesaDoCaixaCampoAlterado event,
    Emitter<DespesaDoCaixaState> emit,
  ) {
    emit(
      state.copyWith(
        valor: event.valor ?? state.valor,
        descricao: event.descricao ?? state.descricao,
        categoriaId: event.categoriaId ?? state.categoriaId,
        step: DespesaDoCaixaStep.editando,
        erro: null,
      ),
    );
  }

  FutureOr<void> _onSalvou(
    DespesaDoCaixaSalvou event,
    Emitter<DespesaDoCaixaState> emit,
  ) async {
    final caixaId = state.caixaId;
    final valor = _parseValor(state.valor);
    final descricao = state.descricao.trim();
    final categoriaId = state.categoriaId;

    String? invalido;
    if (caixaId == null) {
      invalido = 'Não foi possível identificar o caixa da despesa.';
    } else if (valor == null || valor <= 0) {
      invalido = 'Informe um valor válido para a despesa.';
    } else if (descricao.isEmpty) {
      invalido = 'A descrição da despesa é obrigatória.';
    } else if (categoriaId == null) {
      invalido = 'Selecione a categoria da despesa.';
    }

    if (invalido != null) {
      emit(
        state.copyWith(
          step: DespesaDoCaixaStep.validacaoInvalida,
          erro: invalido,
        ),
      );
      return;
    }

    try {
      emit(state.copyWith(step: DespesaDoCaixaStep.salvando, erro: null));

      await _criarDespesa.call(
        caixaId: caixaId!,
        valor: valor!,
        descricao: descricao,
        categoriaId: categoriaId!,
      );

      emit(state.copyWith(step: DespesaDoCaixaStep.criado, erro: null));
    } catch (e, s) {
      emit(
        state.copyWith(
          step: DespesaDoCaixaStep.falha,
          erro: mensagemDeErroApi(
            e,
            'Falha ao lançar a despesa. Tente novamente.',
          ),
        ),
      );
      addError(e, s);
    }
  }

  double? _parseValor(String texto) {
    final valor = texto.trim();
    if (valor.isEmpty) {
      return null;
    }

    final normalizado = valor.contains(',') && valor.contains('.')
        ? valor.replaceAll('.', '').replaceAll(',', '.')
        : valor.replaceAll(',', '.');

    return double.tryParse(normalizado);
  }
}
