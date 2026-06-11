import 'package:core/bloc.dart';
import 'package:core/equals.dart';
import 'package:estoque/domain/models/balanco.dart';
import 'package:estoque/domain/usecases/balanco_usecases.dart';

part 'balanco_lotes_event.dart';
part 'balanco_lotes_state.dart';

class BalancoLotesBloc extends Bloc<BalancoLotesEvent, BalancoLotesState> {
  final ListarLotesBalancoUseCase listarLotes;

  BalancoLotesBloc({required this.listarLotes})
    : super(const BalancoLotesInitial()) {
    on<CarregarLotesDoBalancoEvent>(_onCarregarLotesDoBalanco);
  }

  Future<void> _onCarregarLotesDoBalanco(
    CarregarLotesDoBalancoEvent event,
    Emitter<BalancoLotesState> emit,
  ) async {
    emit(const BalancoLotesLoading());
    try {
      final lotes = await listarLotes(balancoId: event.balancoId);
      emit(BalancoLotesCarregados(lotes: lotes));
    } catch (e, s) {
      addError(e, s);
      emit(BalancoLotesError(message: 'Erro ao listar lotes do balanço'));
    }
  }
}
