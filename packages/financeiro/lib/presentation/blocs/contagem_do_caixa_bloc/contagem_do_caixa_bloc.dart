import 'dart:async';

import 'package:core/bloc.dart';
import 'package:core/equals.dart';
import 'package:financeiro/models.dart';
import 'package:financeiro/use_cases.dart';

part 'contagem_do_caixa_event.dart';
part 'contagem_do_caixa_state.dart';

class ContagemDoCaixaBloc
    extends Bloc<ContagemDoCaixaEvent, ContagemDoCaixaState> {
  final RecuperarContagemDoCaixa _recuperarContagem;
  final RecuperarItensPendentesParaContagemDoCaixaUseCase
      _recuperarItensPendentes;
  final SalvarItemDaContagemDoCaixa _salvarItem;
  final CancelarContagemDoCaixa _cancelarContagem;

  ContagemDoCaixaBloc(
    this._recuperarContagem,
    this._recuperarItensPendentes,
    this._salvarItem,
    this._cancelarContagem,
  ) : super(const ContagemDoCaixaState.initial()) {
    on<ContagemDoCaixaIniciou>(_onIniciou);
    on<ContagemDoCaixaItemValorAlterado>(_onItemValorAlterado);
    on<ContagemDoCaixaItemSalvou>(_onItemSalvou);
    on<ContagemDoCaixaSalvarTodosSolicitado>(_onSalvarTodosSolicitado);
    on<ContagemDoCaixaCancelamentoSolicitado>(_onCancelamentoSolicitado);
  }

  FutureOr<void> _onCancelamentoSolicitado(
    ContagemDoCaixaCancelamentoSolicitado event,
    Emitter<ContagemDoCaixaState> emit,
  ) async {
    final caixaId = state.caixaId;
    if (caixaId == null) return;

    emit(state.copyWith(step: ContagemDoCaixaStep.cancelando, erro: null));

    try {
      await _cancelarContagem(caixaId: caixaId);
      emit(state.copyWith(step: ContagemDoCaixaStep.cancelada, erro: null));
    } catch (_) {
      emit(
        state.copyWith(
          step: ContagemDoCaixaStep.falha,
          erro: 'Falha ao cancelar a contagem. Tente novamente.',
        ),
      );
    }
  }

  FutureOr<void> _onIniciou(
    ContagemDoCaixaIniciou event,
    Emitter<ContagemDoCaixaState> emit,
  ) async {
    emit(
      state.copyWith(
        caixaId: event.caixaId,
        step: ContagemDoCaixaStep.carregando,
        erro: null,
      ),
    );

    try {
      final contagem = await _recuperarContagem(caixaId: event.caixaId);
      final itensPendentes = await _recuperarItensPendentes(
        caixaId: event.caixaId,
      );
      final tiposPendentes =
          itensPendentes.map((item) => item.tipoDocumento).toSet();

      final valoresIniciais = <TipoContagemDoCaixaItem, String>{};
      if (contagem != null) {
        for (final item in contagem.itens) {
          if (tiposPendentes.contains(item.tipoDocumento)) {
            valoresIniciais[item.tipoDocumento] = item.valor.toStringAsFixed(2);
          }
        }
      }

      emit(
        state.copyWith(
          contagem: contagem,
          tiposPendentes: tiposPendentes.toList(),
          valoresEditados: valoresIniciais,
          step: ContagemDoCaixaStep.editando,
          erro: null,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          step: ContagemDoCaixaStep.falha,
          erro: _mensagemFalhaCarregamento(error),
        ),
      );
    }
  }

  FutureOr<void> _onItemValorAlterado(
    ContagemDoCaixaItemValorAlterado event,
    Emitter<ContagemDoCaixaState> emit,
  ) {
    final novosValores =
        Map<TipoContagemDoCaixaItem, String>.from(state.valoresEditados);
    novosValores[event.tipo] = event.valor;

    emit(state.copyWith(valoresEditados: novosValores));
  }

  FutureOr<void> _onItemSalvou(
    ContagemDoCaixaItemSalvou event,
    Emitter<ContagemDoCaixaState> emit,
  ) async {
    final caixaId = state.caixaId;
    if (caixaId == null) return;

    final valorStr = state.valoresEditados[event.tipo] ?? '';
    final valor = double.tryParse(valorStr.replaceAll(',', '.'));

    if (valor == null) {
      emit(
        state.copyWith(
          step: ContagemDoCaixaStep.validacaoInvalida,
          erro: 'Informe um valor válido.',
          tipoComErro: event.tipo,
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        step: ContagemDoCaixaStep.salvandoItem,
        itemSendoSalvo: event.tipo,
        clearTipoComErro: true,
        erro: null,
      ),
    );

    try {
      final itensAtualizados = List<ContagemDoCaixaItem>.from(
        state.contagem?.itens ?? [],
      );
      final itemExistente = _buscarItemPorTipo(itensAtualizados, event.tipo);
      final itemAtualizado = _ContagemDoCaixaItemInterno(
        id: itemExistente?.id,
        tipoDocumento: event.tipo,
        valor: valor,
      );

      final indiceExistente = itensAtualizados.indexWhere(
        (i) => i.tipoDocumento == event.tipo,
      );
      if (indiceExistente >= 0) {
        itensAtualizados[indiceExistente] = itemAtualizado;
      } else {
        itensAtualizados.add(itemAtualizado);
      }

      final contagemAtualizada = _atualizarContagemComItens(
        caixaId: caixaId,
        itens: itensAtualizados,
      );

      final contagemPersistida = await _salvarItem(
        caixaId: caixaId,
        contagemDoCaixa: contagemAtualizada,
      );

      emit(
        state.copyWith(
          contagem: contagemPersistida,
          step: ContagemDoCaixaStep.editando,
          clearItemSendoSalvo: true,
          clearTipoComErro: true,
          erro: null,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          step: ContagemDoCaixaStep.falha,
          clearItemSendoSalvo: true,
          erro: 'Falha ao salvar o item. Tente novamente.',
          tipoComErro: event.tipo,
        ),
      );
    }
  }

  FutureOr<void> _onSalvarTodosSolicitado(
    ContagemDoCaixaSalvarTodosSolicitado event,
    Emitter<ContagemDoCaixaState> emit,
  ) async {
    final caixaId = state.caixaId;
    if (caixaId == null) return;

    final itensPreenchidos = <ContagemDoCaixaItem>[];
    final itensExistentes =
        state.contagem?.itens ?? const <ContagemDoCaixaItem>[];

    for (final tipo in state.tiposPendentes) {
      final valorDigitado = (state.valoresEditados[tipo] ?? '').trim();
      if (valorDigitado.isEmpty) {
        continue;
      }

      final valor = double.tryParse(valorDigitado.replaceAll(',', '.'));
      if (valor == null) {
        emit(
          state.copyWith(
            step: ContagemDoCaixaStep.validacaoInvalida,
            erro: 'Informe um valor válido.',
            tipoComErro: tipo,
            clearItemSendoSalvo: true,
          ),
        );
        return;
      }

      final itemExistente = _buscarItemPorTipo(itensExistentes, tipo);
      itensPreenchidos.add(
        _ContagemDoCaixaItemInterno(
          id: itemExistente?.id,
          tipoDocumento: tipo,
          valor: valor,
        ),
      );
    }

    // Caixa sem nenhuma movimentação não tem tipo pendente pra preencher —
    // nesse caso a contagem "zerada" (zero itens) é um estado válido, e não
    // deve ser bloqueada pela falta de preenchimento.
    if (itensPreenchidos.isEmpty && state.tiposPendentes.isNotEmpty) {
      emit(
        state.copyWith(
          step: ContagemDoCaixaStep.validacaoInvalida,
          erro: 'Preencha ao menos um valor para salvar.',
          clearTipoComErro: true,
          clearItemSendoSalvo: true,
        ),
      );
      return;
    }

    final contagemAtualizada = _atualizarContagemComItens(
      caixaId: caixaId,
      itens: itensPreenchidos,
    );

    emit(
      state.copyWith(
        step: ContagemDoCaixaStep.salvandoItem,
        clearItemSendoSalvo: true,
        clearTipoComErro: true,
        erro: null,
      ),
    );

    try {
      final contagemPersistida = await _salvarItem(
        caixaId: caixaId,
        contagemDoCaixa: contagemAtualizada,
      );

      emit(
        state.copyWith(
          contagem: contagemPersistida,
          step: ContagemDoCaixaStep.editando,
          clearItemSendoSalvo: true,
          clearTipoComErro: true,
          erro: null,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          step: ContagemDoCaixaStep.falha,
          clearItemSendoSalvo: true,
          erro: 'Falha ao salvar os itens. Tente novamente.',
          clearTipoComErro: true,
        ),
      );
    }
  }

  ContagemDoCaixa _atualizarContagemComItens({
    required int caixaId,
    required List<ContagemDoCaixaItem> itens,
  }) {
    final contagemExistente = state.contagem;
    return _ContagemDoCaixaInterna(
      id: contagemExistente?.id,
      caixaId: caixaId,
      observacao: contagemExistente?.observacao ?? '',
      itens: itens,
    );
  }

  ContagemDoCaixaItem? _buscarItemPorTipo(
    List<ContagemDoCaixaItem> itens,
    TipoContagemDoCaixaItem tipo,
  ) {
    for (final item in itens) {
      if (item.tipoDocumento == tipo) {
        return item;
      }
    }
    return null;
  }
}

String _mensagemFalhaCarregamento(Object error) {
  if (error is FormatException) {
    return 'Falha ao processar os dados do caixa. Verifique o retorno da API e tente novamente.';
  }

  return 'Falha ao carregar a contagem do caixa. Tente novamente.';
}

class _ContagemDoCaixaInterna implements ContagemDoCaixa {
  @override
  final int? id;

  @override
  final int caixaId;

  @override
  final String observacao;

  @override
  final List<ContagemDoCaixaItem> itens;

  const _ContagemDoCaixaInterna({
    this.id,
    required this.caixaId,
    required this.observacao,
    required this.itens,
  });

  @override
  List<Object?> get props => [id, caixaId, observacao, itens];

  @override
  bool? get stringify => true;
}

class _ContagemDoCaixaItemInterno implements ContagemDoCaixaItem {
  @override
  final int? id;

  @override
  final double valor;

  @override
  final TipoContagemDoCaixaItem tipoDocumento;

  const _ContagemDoCaixaItemInterno({
    this.id,
    required this.valor,
    required this.tipoDocumento,
  });

  @override
  List<Object?> get props => [id, valor, tipoDocumento];

  @override
  bool? get stringify => true;
}
