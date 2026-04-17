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
  final SalvarItemDaContagemDoCaixa _salvarItem;

  ContagemDoCaixaBloc(this._recuperarContagem, this._salvarItem)
      : super(const ContagemDoCaixaState.initial()) {
    on<ContagemDoCaixaIniciou>(_onIniciou);
    on<ContagemDoCaixaItemValorAlterado>(_onItemValorAlterado);
    on<ContagemDoCaixaItemSalvou>(_onItemSalvou);
    on<ContagemDoCaixaSalvarTodosSolicitado>(_onSalvarTodosSolicitado);
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

      final valoresIniciais = <TipoContagemDoCaixaItem, String>{};
      if (contagem != null) {
        for (final item in contagem.itens) {
          valoresIniciais[item.tipo] = item.valor.toStringAsFixed(2);
        }
      }

      emit(
        state.copyWith(
          contagem: contagem,
          valoresEditados: valoresIniciais,
          step: ContagemDoCaixaStep.editando,
          erro: null,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          step: ContagemDoCaixaStep.falha,
          erro: 'Falha ao carregar a contagem do caixa. Tente novamente.',
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
        tipo: event.tipo,
        valor: valor,
      );

      final indiceExistente = itensAtualizados.indexWhere(
        (i) => i.tipo == event.tipo,
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

      await _salvarItem(
        caixaId: caixaId,
        contagemDoCaixa: contagemAtualizada,
      );

      emit(
        state.copyWith(
          contagem: contagemAtualizada,
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

    for (final tipo in TipoContagemDoCaixaItem.values) {
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
          tipo: tipo,
          valor: valor,
        ),
      );
    }

    if (itensPreenchidos.isEmpty) {
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
      await _salvarItem(
        caixaId: caixaId,
        contagemDoCaixa: contagemAtualizada,
      );

      emit(
        state.copyWith(
          contagem: contagemAtualizada,
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
      if (item.tipo == tipo) {
        return item;
      }
    }
    return null;
  }
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
  final TipoContagemDoCaixaItem tipo;

  const _ContagemDoCaixaItemInterno({
    this.id,
    required this.valor,
    required this.tipo,
  });

  @override
  List<Object?> get props => [id, valor, tipo];

  @override
  bool? get stringify => true;
}
