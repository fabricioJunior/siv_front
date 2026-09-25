import 'dart:async';

import 'package:core/bloc.dart';
import 'package:core/equals.dart';
import 'package:core/precos_portas.dart';
import 'package:produtos/use_cases.dart';

part 'precos_da_referencia_event.dart';
part 'precos_da_referencia_state.dart';

/// Mesma validação de valor de `preco_da_referencia_page` (packages/precos):
/// durante a digitação aceita até 2 casas, ao salvar exige o formato
/// completo com pelo menos 1 casa.
final regexValorDigitando = RegExp(r'^\d+([.,]\d{0,2})?$');
final regexValorValido = RegExp(r'^\d+([.,]\d{1,2})?$');

double? parseValor(String texto) {
  return double.tryParse(texto.trim().replaceAll(',', '.'));
}

String? validarValor(String texto) {
  final valor = texto.trim();
  if (valor.isEmpty) return 'Informe o valor';
  if (!regexValorValido.hasMatch(valor)) {
    return 'Use no máximo 2 casas decimais';
  }
  return null;
}

/// O backend SEMPRE substitui as casas decimais digitadas pelo terminador
/// da tabela ao salvar (`floor(valor) + (terminador % 1)`) -- não é um
/// aviso que "não bloqueia", é o valor final. Calculado aqui só pra
/// mostrar a prévia antes de confirmar.
double calcularValorComTerminador(double valor, double? terminador) {
  if (terminador == null) return valor;
  return valor.floorToDouble() + (terminador % 1);
}

class PrecosDaReferenciaBloc
    extends Bloc<PrecosDaReferenciaEvent, PrecosDaReferenciaState> {
  final ListarPrecosDaReferenciaPorTabela _listarPrecos;
  final SalvarPrecoDaReferencia _salvarPreco;

  PrecosDaReferenciaBloc(this._listarPrecos, this._salvarPreco)
    : super(const PrecosDaReferenciaState()) {
    on<PrecosDaReferenciaIniciou>(_onIniciou);
    on<PrecosDaReferenciaEditouLinha>(_onEditouLinha);
    on<PrecosDaReferenciaValorAlterou>(_onValorAlterou);
    on<PrecosDaReferenciaCancelouEdicao>(_onCancelouEdicao);
    on<PrecosDaReferenciaSalvou>(_onSalvou);
  }

  FutureOr<void> _onIniciou(
    PrecosDaReferenciaIniciou event,
    Emitter<PrecosDaReferenciaState> emit,
  ) async {
    emit(
      state.copyWith(
        step: PrecosDaReferenciaStep.carregando,
        referenciaId: event.referenciaId,
      ),
    );
    try {
      final tabelas = await _listarPrecos.call(referenciaId: event.referenciaId);
      emit(
        state.copyWith(step: PrecosDaReferenciaStep.sucesso, tabelas: tabelas),
      );
    } catch (e, s) {
      emit(state.copyWith(step: PrecosDaReferenciaStep.falha));
      addError(e, s);
    }
  }

  FutureOr<void> _onEditouLinha(
    PrecosDaReferenciaEditouLinha event,
    Emitter<PrecosDaReferenciaState> emit,
  ) {
    final tabela = state.tabelas.firstWhere(
      (t) => t.tabelaDePrecoId == event.tabelaDePrecoId,
    );
    if (tabela.tabelaInativa) return null;

    emit(
      state.copyWith(
        tabelaEmEdicaoId: event.tabelaDePrecoId,
        valorDigitado: tabela.valor?.toStringAsFixed(2) ?? '',
        erroValidacao: null,
        clearErro: true,
      ),
    );
    return null;
  }

  FutureOr<void> _onValorAlterou(
    PrecosDaReferenciaValorAlterou event,
    Emitter<PrecosDaReferenciaState> emit,
  ) {
    if (event.texto.isNotEmpty && !regexValorDigitando.hasMatch(event.texto)) {
      return null;
    }
    emit(state.copyWith(valorDigitado: event.texto, clearErro: true));
    return null;
  }

  FutureOr<void> _onCancelouEdicao(
    PrecosDaReferenciaCancelouEdicao event,
    Emitter<PrecosDaReferenciaState> emit,
  ) {
    emit(
      state.copyWith(
        clearTabelaEmEdicao: true,
        valorDigitado: '',
        clearErro: true,
      ),
    );
  }

  FutureOr<void> _onSalvou(
    PrecosDaReferenciaSalvou event,
    Emitter<PrecosDaReferenciaState> emit,
  ) async {
    final tabelaId = state.tabelaEmEdicaoId;
    if (tabelaId == null || state.referenciaId == null) return;

    final erro = validarValor(state.valorDigitado);
    if (erro != null) {
      emit(state.copyWith(erroValidacao: erro));
      return;
    }

    final valor = parseValor(state.valorDigitado)!;
    final linhaAtual = state.tabelas.firstWhere(
      (t) => t.tabelaDePrecoId == tabelaId,
    );
    emit(state.copyWith(step: PrecosDaReferenciaStep.salvando));
    try {
      final atualizado = await _salvarPreco.call(
        tabelaDePrecoId: tabelaId,
        referenciaId: state.referenciaId!,
        valor: valor,
        precoJaExiste: linhaAtual.temPreco,
      );

      final tabelas = state.tabelas.map((t) {
        if (t.tabelaDePrecoId != tabelaId) return t;
        return PrecoDaReferenciaPorTabela(
          tabelaDePrecoId: t.tabelaDePrecoId,
          tabelaNome: t.tabelaNome,
          tabelaInativa: t.tabelaInativa,
          tabelaPadrao: t.tabelaPadrao,
          terminador: t.terminador,
          valor: atualizado.valor,
          atualizadoEm: atualizado.atualizadoEm,
          operadorId: atualizado.operadorId,
        );
      }).toList();

      emit(
        state.copyWith(
          step: PrecosDaReferenciaStep.sucesso,
          tabelas: tabelas,
          clearTabelaEmEdicao: true,
          valorDigitado: '',
          clearErro: true,
        ),
      );
    } catch (e, s) {
      emit(
        state.copyWith(
          step: PrecosDaReferenciaStep.sucesso,
          erroValidacao: 'Falha ao salvar preço.',
        ),
      );
      addError(e, s);
    }
  }
}
