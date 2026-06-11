import 'package:core/bloc.dart';
import 'package:core/equals.dart';
import 'package:estoque/domain/models/balanco.dart';
import 'package:estoque/domain/usecases/balanco_usecases.dart';

part 'balanco_event.dart';
part 'balanco_state.dart';

class BalancoBloc extends Bloc<BalancoEvent, BalancoState> {
  final CriarBalancoUseCase criarBalanco;
  final ListarBalancosUseCase listarBalancos;
  final ObterBalancoUseCase obterBalanco;
  final AtualizarBalancoUseCase atualizarBalanco;
  final EncerrarBalancoUseCase encerrarBalanco;
  final CancelarBalancoUseCase cancelarBalanco;
  final ObterResumoBalancoUseCase obterResumo;
  final AdicionarItemAoBalancoUseCase adicionarItem;
  final AdicionarMultiplosItensAoBalancoUseCase adicionarMultiplosItens;
  final ListarItensDoBalancoUseCase listarItensDoBalanco;
  final RemoverItemDoBalancoUseCase removerItemDoBalanco;

  BalancoBloc({
    required this.criarBalanco,
    required this.listarBalancos,
    required this.obterBalanco,
    required this.atualizarBalanco,
    required this.encerrarBalanco,
    required this.cancelarBalanco,
    required this.obterResumo,
    required this.adicionarItem,
    required this.adicionarMultiplosItens,
    required this.listarItensDoBalanco,
    required this.removerItemDoBalanco,
  }) : super(const BalancoInitial()) {
    on<CriarBalancoEvent>(_onCriarBalanco);
    on<ListarBalancosEvent>(_onListarBalancos);
    on<ObterBalancoEvent>(_onObterBalanco);
    on<AtualizarBalancoEvent>(_onAtualizarBalanco);
    on<EncerrarBalancoEvent>(_onEncerrarBalanco);
    on<CancelarBalancoEvent>(_onCancelarBalanco);
    on<ObterResumoBalancoEvent>(_onObterResumo);
    on<AdicionarItemAoBalancoEvent>(_onAdicionarItem);
    on<AdicionarMultiplosItensAoBalancoEvent>(_onAdicionarMultiplosItens);
    on<ListarItensDoBalancoEvent>(_onListarItensDoBalanco);
    on<RemoverItemDoBalancoEvent>(_onRemoverItemDoBalanco);
  }

  Future<void> _onCriarBalanco(
    CriarBalancoEvent event,
    Emitter<BalancoState> emit,
  ) async {
    emit(const BalancoLoading());
    try {
      final balanco = await criarBalanco(observacao: event.observacao);
      emit(BalancoCreated(balanco: balanco));
    } catch (e, s) {
      addError(e, s);
      emit(BalancoError(message: 'Erro ao criar balanço', error: e));
    }
  }

  Future<void> _onListarBalancos(
    ListarBalancosEvent event,
    Emitter<BalancoState> emit,
  ) async {
    emit(const BalancoLoading());
    try {
      final balancos = await listarBalancos(
        situacao: event.situacao,
        page: event.page,
        limit: event.limit,
      );
      emit(
        BalancoListLoaded(
          balancos: balancos,
          page: event.page,
          limit: event.limit,
        ),
      );
    } catch (e, s) {
      addError(e, s);
      emit(BalancoError(message: 'Erro ao listar balanços', error: e));
    }
  }

  Future<void> _onObterBalanco(
    ObterBalancoEvent event,
    Emitter<BalancoState> emit,
  ) async {
    emit(const BalancoLoading());
    try {
      final balanco = await obterBalanco(balancoId: event.balancoId);
      emit(BalancoLoaded(balanco: balanco));
    } catch (e, s) {
      addError(e, s);
      emit(BalancoError(message: 'Erro ao obter balanço', error: e));
    }
  }

  Future<void> _onAtualizarBalanco(
    AtualizarBalancoEvent event,
    Emitter<BalancoState> emit,
  ) async {
    emit(const BalancoLoading());
    try {
      final balanco = await atualizarBalanco(
        balancoId: event.balancoId,
        observacao: event.observacao,
      );
      emit(BalancoUpdated(balanco: balanco));
    } catch (e, s) {
      addError(e, s);
      emit(BalancoError(message: 'Erro ao atualizar balanço', error: e));
    }
  }

  Future<void> _onEncerrarBalanco(
    EncerrarBalancoEvent event,
    Emitter<BalancoState> emit,
  ) async {
    emit(const BalancoLoading());
    try {
      final balanco = await encerrarBalanco(
        balancoId: event.balancoId,
        observacao: event.observacao,
      );
      emit(BalancoFinalized(balanco: balanco));
    } catch (e, s) {
      addError(e, s);
      emit(BalancoError(message: 'Erro ao encerrar balanço', error: e));
    }
  }

  Future<void> _onCancelarBalanco(
    CancelarBalancoEvent event,
    Emitter<BalancoState> emit,
  ) async {
    emit(const BalancoLoading());
    try {
      final balanco = await cancelarBalanco(
        balancoId: event.balancoId,
        motivo: event.motivo,
      );
      emit(BalancoCanceled(balanco: balanco));
    } catch (e, s) {
      addError(e, s);
      emit(BalancoError(message: 'Erro ao cancelar balanço', error: e));
    }
  }

  Future<void> _onObterResumo(
    ObterResumoBalancoEvent event,
    Emitter<BalancoState> emit,
  ) async {
    emit(const BalancoLoading());
    try {
      final resumo = await obterResumo(balancoId: event.balancoId);
      emit(BalancoResumoLoaded(resumo: resumo));
    } catch (e, s) {
      addError(e, s);
      emit(BalancoError(message: 'Erro ao obter resumo', error: e));
    }
  }

  Future<void> _onAdicionarItem(
    AdicionarItemAoBalancoEvent event,
    Emitter<BalancoState> emit,
  ) async {
    emit(const BalancoLoading());
    try {
      final item = await adicionarItem(
        balancoId: event.balancoId,
        produtoId: event.produtoId,
      );
      emit(BalancoItemAdded(item: item));
    } catch (e, s) {
      addError(e, s);
      emit(BalancoError(message: 'Erro ao adicionar item', error: e));
    }
  }

  Future<void> _onAdicionarMultiplosItens(
    AdicionarMultiplosItensAoBalancoEvent event,
    Emitter<BalancoState> emit,
  ) async {
    emit(const BalancoLoading());
    try {
      await adicionarMultiplosItens(
        balancoId: event.balancoId,
        referenciaIds: event.referenciaIds,
      );
      emit(const BalancoItemsAdded());
    } catch (e, s) {
      addError(e, s);
      emit(BalancoError(message: 'Erro ao adicionar itens', error: e));
    }
  }

  Future<void> _onListarItensDoBalanco(
    ListarItensDoBalancoEvent event,
    Emitter<BalancoState> emit,
  ) async {
    emit(const BalancoLoading());
    try {
      final items = await listarItensDoBalanco(balancoId: event.balancoId);
      emit(BalancoItemsLoaded(items: items));
    } catch (e, s) {
      addError(e, s);
      emit(BalancoError(message: 'Erro ao listar itens', error: e));
    }
  }

  Future<void> _onRemoverItemDoBalanco(
    RemoverItemDoBalancoEvent event,
    Emitter<BalancoState> emit,
  ) async {
    emit(const BalancoLoading());
    try {
      await removerItemDoBalanco(
        balancoId: event.balancoId,
        produtoId: event.produtoId,
      );
      emit(BalancoItemRemoved(produtoId: event.produtoId));
    } catch (e, s) {
      addError(e, s);
      emit(BalancoError(message: 'Erro ao remover item', error: e));
    }
  }
}
