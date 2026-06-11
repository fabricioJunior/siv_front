import 'package:core/bloc.dart';
import 'package:core/equals.dart';
import 'package:estoque/domain/models/balanco.dart';
import 'package:estoque/domain/usecases/balanco_usecases.dart';

part 'lote_event.dart';
part 'lote_state.dart';

class LoteBloc extends Bloc<LoteEvent, LoteState> {
  final CriarLoteBalancoUseCase criarLote;
  final AtualizarLoteBalancoUseCase atualizarLote;
  final CancelarLoteBalancoUseCase cancelarLote;
  final ListarLotesBalancoUseCase listarLotes;
  final AdicionarMultiplosItensAoLoteBalancoUseCase adicionarMultiplosItens;
  final ListarItensDoLoteBalancoUseCase listarItens;
  final RemoverItemDoLoteBalancoUseCase removerItem;

  LoteBloc({
    required this.criarLote,
    required this.atualizarLote,
    required this.cancelarLote,
    required this.listarLotes,
    required this.adicionarMultiplosItens,
    required this.listarItens,
    required this.removerItem,
  }) : super(const LoteState()) {
    on<CriarLoteEvent>(_onCriarLote);
    on<AtualizarLoteEvent>(_onAtualizarLote);
    on<CancelarLoteEvent>(_onCancelarLote);
    on<CarregarItensDoLoteEvent>(_onCarregarItensDoLote);
    on<AdicionarProdutoPendenteEvent>(_onAdicionarProdutoPendente);
    on<RemoverProdutoPendenteEvent>(_onRemoverProdutoPendente);
    on<LimparProdutosPendentesEvent>(_onLimparProdutosPendentes);
    on<SalvarProdutosPendentesEvent>(_onSalvarProdutosPendentes);
    on<RemoverItemDoLoteEvent>(_onRemoverItemDoLote);
    on<SalvarLeituraDoLoteEvent>(_onSalvarLeituraDoLote);
  }

  Future<void> _onCriarLote(
    CriarLoteEvent event,
    Emitter<LoteState> emit,
  ) async {
    emit(state.copyWith(status: LoteStatus.loading, clearMessage: true));
    try {
      final lote = await criarLote(
        balancoId: event.balancoId,
        lote: event.lote,
        observacao: event.observacao,
      );
      emit(
        state.copyWith(
          status: LoteStatus.success,
          lote: lote,
          message: 'Lote criado com sucesso',
        ),
      );
    } catch (e, s) {
      addError(e, s);
      emit(
        state.copyWith(
          status: LoteStatus.error,
          message: 'Erro ao criar lote',
          clearMessage: false,
        ),
      );
    }
  }

  Future<void> _onAtualizarLote(
    AtualizarLoteEvent event,
    Emitter<LoteState> emit,
  ) async {
    emit(state.copyWith(status: LoteStatus.loading, clearMessage: true));
    try {
      final lote = await atualizarLote(
        balancoId: event.balancoId,
        loteId: event.loteId,
        lote: event.lote,
        observacao: event.observacao,
      );
      emit(
        state.copyWith(
          status: LoteStatus.success,
          lote: lote,
          message: 'Lote atualizado com sucesso',
        ),
      );
    } catch (e, s) {
      addError(e, s);
      emit(
        state.copyWith(
          status: LoteStatus.error,
          message: 'Erro ao atualizar lote',
          clearMessage: false,
        ),
      );
    }
  }

  Future<void> _onCancelarLote(
    CancelarLoteEvent event,
    Emitter<LoteState> emit,
  ) async {
    emit(state.copyWith(status: LoteStatus.loading, clearMessage: true));
    try {
      final lote = await cancelarLote(
        balancoId: event.balancoId,
        loteId: event.loteId,
        motivo: event.motivo,
      );
      emit(
        state.copyWith(
          status: LoteStatus.success,
          lote: lote,
          message: 'Lote cancelado com sucesso',
        ),
      );
    } catch (e, s) {
      addError(e, s);
      emit(
        state.copyWith(
          status: LoteStatus.error,
          message: 'Erro ao cancelar lote',
          clearMessage: false,
        ),
      );
    }
  }

  Future<void> _onCarregarItensDoLote(
    CarregarItensDoLoteEvent event,
    Emitter<LoteState> emit,
  ) async {
    emit(state.copyWith(status: LoteStatus.loading, clearMessage: true));
    try {
      final lote = await _carregarLote(
        balancoId: event.balancoId,
        loteId: event.loteId,
      );
      final itens = await listarItens(
        balancoId: event.balancoId,
        loteId: event.loteId,
      );
      emit(
        state.copyWith(
          status: LoteStatus.ready,
          lote: lote,
          itens: itens,
          clearMessage: true,
        ),
      );
    } catch (e, s) {
      addError(e, s);
      emit(
        state.copyWith(
          status: LoteStatus.error,
          message: 'Erro ao listar itens do lote',
          clearMessage: false,
        ),
      );
    }
  }

  void _onAdicionarProdutoPendente(
    AdicionarProdutoPendenteEvent event,
    Emitter<LoteState> emit,
  ) {
    final pendentes = List<LoteProdutoPendente>.from(state.produtosPendentes);
    final index = pendentes.indexWhere((p) => p.produtoId == event.produtoId);

    if (index >= 0) {
      final atual = pendentes[index];
      pendentes[index] = atual.copyWith(
        quantidadeContada: atual.quantidadeContada + event.quantidadeContada,
        descricao: event.descricao ?? atual.descricao,
      );
    } else {
      pendentes.add(
        LoteProdutoPendente(
          produtoId: event.produtoId,
          quantidadeContada: event.quantidadeContada,
          descricao: event.descricao,
        ),
      );
    }

    emit(
      state.copyWith(
        status: LoteStatus.ready,
        produtosPendentes: pendentes,
        clearMessage: true,
      ),
    );
  }

  void _onRemoverProdutoPendente(
    RemoverProdutoPendenteEvent event,
    Emitter<LoteState> emit,
  ) {
    final pendentes = state.produtosPendentes
        .where((p) => p.produtoId != event.produtoId)
        .toList(growable: false);

    emit(
      state.copyWith(
        status: LoteStatus.ready,
        produtosPendentes: pendentes,
        clearMessage: true,
      ),
    );
  }

  void _onLimparProdutosPendentes(
    LimparProdutosPendentesEvent event,
    Emitter<LoteState> emit,
  ) {
    emit(
      state.copyWith(
        status: LoteStatus.ready,
        produtosPendentes: const [],
        clearMessage: true,
      ),
    );
  }

  Future<void> _onSalvarProdutosPendentes(
    SalvarProdutosPendentesEvent event,
    Emitter<LoteState> emit,
  ) async {
    if (state.produtosPendentes.isEmpty) {
      emit(
        state.copyWith(
          status: LoteStatus.error,
          message: 'Nao ha produtos pendentes para salvar',
          clearMessage: false,
        ),
      );
      return;
    }

    emit(state.copyWith(status: LoteStatus.loading, clearMessage: true));
    try {
      await adicionarMultiplosItens(
        balancoId: event.balancoId,
        loteId: event.loteId,
        itens: state.produtosPendentes
            .map(
              (p) => {
                'produtoId': p.produtoId,
                'quantidadeContada': p.quantidadeContada,
              },
            )
            .toList(growable: false),
      );

      final itensAtualizados = await listarItens(
        balancoId: event.balancoId,
        loteId: event.loteId,
      );

      emit(
        state.copyWith(
          status: LoteStatus.success,
          lote: state.lote,
          itens: itensAtualizados,
          produtosPendentes: const [],
          message: 'Itens salvos no lote com sucesso',
        ),
      );
    } catch (e, s) {
      addError(e, s);
      emit(
        state.copyWith(
          status: LoteStatus.error,
          message: 'Erro ao salvar itens do lote',
          clearMessage: false,
        ),
      );
    }
  }

  Future<void> _onRemoverItemDoLote(
    RemoverItemDoLoteEvent event,
    Emitter<LoteState> emit,
  ) async {
    emit(state.copyWith(status: LoteStatus.loading, clearMessage: true));
    try {
      await removerItem(
        balancoId: event.balancoId,
        loteId: event.loteId,
        produtoId: event.produtoId,
      );

      final itensAtualizados = await listarItens(
        balancoId: event.balancoId,
        loteId: event.loteId,
      );

      emit(
        state.copyWith(
          status: LoteStatus.success,
          lote: state.lote,
          itens: itensAtualizados,
          message: 'Item removido com sucesso',
        ),
      );
    } catch (e, s) {
      addError(e, s);
      emit(
        state.copyWith(
          status: LoteStatus.error,
          message: 'Erro ao remover item do lote',
          clearMessage: false,
        ),
      );
    }
  }

  Future<void> _onSalvarLeituraDoLote(
    SalvarLeituraDoLoteEvent event,
    Emitter<LoteState> emit,
  ) async {
    if (state.status == LoteStatus.loading) {
      return;
    }

    emit(state.copyWith(status: LoteStatus.loading, clearMessage: true));
    final quantidadeInicialPorProduto = <int, double>{
      for (final item in state.itens) item.produtoId: item.quantidadeContada,
    };
    final quantidadeFinalPorProduto = <int, double>{
      for (final item in event.itensLidos)
        if (item.quantidadeContada > 0) item.produtoId: item.quantidadeContada,
    };

    final produtosRemovidos = quantidadeInicialPorProduto.keys
        .where((produtoId) => !quantidadeFinalPorProduto.containsKey(produtoId))
        .toList(growable: false);

    final itensParaAdicionar = <Map<String, dynamic>>[];
    quantidadeFinalPorProduto.forEach((produtoId, quantidadeFinal) {
      final quantidadeInicial = quantidadeInicialPorProduto[produtoId] ?? 0;
      final deltaParaAdicionar = quantidadeFinal - quantidadeInicial;
      if (deltaParaAdicionar > 0) {
        itensParaAdicionar.add({
          'produtoId': produtoId,
          'quantidadeContada': deltaParaAdicionar,
        });
      }
    });

    if (produtosRemovidos.isEmpty && itensParaAdicionar.isEmpty) {
      emit(
        state.copyWith(
          status: LoteStatus.ready,
          message: 'Nenhuma alteracao para salvar',
          clearMessage: false,
        ),
      );
      return;
    }

    try {
      for (final produtoId in produtosRemovidos) {
        await removerItem(
          balancoId: event.balancoId,
          loteId: event.loteId,
          produtoId: produtoId,
        );
      }

      if (itensParaAdicionar.isNotEmpty) {
        await adicionarMultiplosItens(
          balancoId: event.balancoId,
          loteId: event.loteId,
          itens: itensParaAdicionar,
        );
      }

      final itensAtualizados = await listarItens(
        balancoId: event.balancoId,
        loteId: event.loteId,
      );

      emit(
        state.copyWith(
          status: LoteStatus.success,
          lote: state.lote,
          itens: itensAtualizados,
          produtosPendentes: const [],
          message: 'Itens do leitor salvos no lote com sucesso',
        ),
      );
    } catch (e, s) {
      addError(e, s);
      emit(
        state.copyWith(
          status: LoteStatus.error,
          message: 'Erro ao salvar itens do leitor no lote',
          clearMessage: false,
        ),
      );
    }
  }

  Future<BalancoLote?> _carregarLote({
    required int balancoId,
    required int loteId,
  }) async {
    final lotes = await listarLotes(balancoId: balancoId);
    for (final lote in lotes) {
      if (lote.id == loteId) {
        return lote;
      }
    }
    return null;
  }
}
