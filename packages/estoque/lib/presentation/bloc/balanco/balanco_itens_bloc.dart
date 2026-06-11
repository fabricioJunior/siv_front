import 'package:core/bloc.dart';
import 'package:core/equals.dart';
import 'package:estoque/domain/models/balanco.dart';
import 'package:estoque/domain/usecases/balanco_usecases.dart';

part 'balanco_itens_event.dart';
part 'balanco_itens_state.dart';

class BalancoItensBloc extends Bloc<BalancoItensEvent, BalancoItensState> {
  final ListarItensDoBalancoUseCase listarItensDoBalanco;
  final RemoverItemDoBalancoUseCase removerItemDoBalanco;

  BalancoItensBloc({
    required this.listarItensDoBalanco,
    required this.removerItemDoBalanco,
  }) : super(const BalancoItensInitial()) {
    on<CarregarItensDoBalancoEvent>(_onCarregarItensDoBalanco);
    on<RemoverItemDoBalancoItensEvent>(_onRemoverItemDoBalanco);
  }

  Future<void> _onCarregarItensDoBalanco(
    CarregarItensDoBalancoEvent event,
    Emitter<BalancoItensState> emit,
  ) async {
    emit(const BalancoItensLoading());
    try {
      final itens = await listarItensDoBalanco(balancoId: event.balancoId);
      emit(BalancoItensLoaded(itens: itens));
    } catch (e, s) {
      addError(e, s);
      emit(BalancoItensError(message: 'Erro ao listar itens do balanço'));
    }
  }

  Future<void> _onRemoverItemDoBalanco(
    RemoverItemDoBalancoItensEvent event,
    Emitter<BalancoItensState> emit,
  ) async {
    emit(const BalancoItensLoading());
    try {
      await removerItemDoBalanco(
        balancoId: event.balancoId,
        produtoId: event.produtoId,
      );
      final itens = await listarItensDoBalanco(balancoId: event.balancoId);
      emit(BalancoItensLoaded(itens: itens));
    } catch (e, s) {
      addError(e, s);
      emit(BalancoItensError(message: 'Erro ao remover item do balanço'));
    }
  }
}
