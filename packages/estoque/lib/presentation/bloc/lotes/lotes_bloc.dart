import 'package:core/bloc.dart';
import 'package:core/equals.dart';
import 'package:estoque/domain/models/balanco.dart';
import 'package:estoque/domain/usecases/balanco_usecases.dart';

part 'lotes_event.dart';
part 'lotes_state.dart';

class LotesBloc extends Bloc<LotesEvent, LotesState> {
  final ListarLotesBalancoUseCase listarLotes;
  final CancelarLoteBalancoUseCase cancelarLote;

  LotesBloc({required this.listarLotes, required this.cancelarLote})
    : super(const LotesInitial()) {
    on<CarregarLotesEvent>(_onCarregarLotes);
    on<CancelarLoteDaListaEvent>(_onCancelarLoteDaLista);
  }

  Future<void> _onCarregarLotes(
    CarregarLotesEvent event,
    Emitter<LotesState> emit,
  ) async {
    emit(const LotesLoading());
    try {
      final lotes = await listarLotes(balancoId: event.balancoId);
      emit(LotesLoaded(lotes: lotes));
    } catch (e, s) {
      addError(e, s);
      emit(LotesError(message: 'Erro ao listar lotes do balanço'));
    }
  }

  Future<void> _onCancelarLoteDaLista(
    CancelarLoteDaListaEvent event,
    Emitter<LotesState> emit,
  ) async {
    emit(const LotesLoading());
    try {
      await cancelarLote(
        balancoId: event.balancoId,
        loteId: event.loteId,
        motivo: event.motivo,
      );

      final lotes = await listarLotes(balancoId: event.balancoId);
      emit(LotesLoaded(lotes: lotes));
    } catch (e, s) {
      addError(e, s);
      emit(LotesError(message: 'Erro ao cancelar lote'));
    }
  }
}
