import 'package:core/bloc.dart';
import 'package:core/equals.dart';
import 'package:estoque/domain/models/balanco.dart';
import 'package:estoque/domain/usecases/balanco_usecases.dart';

part 'balanco_itens_event.dart';
part 'balanco_itens_state.dart';

class BalancoItensBloc extends Bloc<BalancoItensEvent, BalancoItensState> {
  final ListarItensDoBalancoUseCase listarItensDoBalanco;
  final RemoverItemDoBalancoUseCase removerItemDoBalanco;
  final CalcularItensDoBalancoUseCase calcularItensDoBalanco;

  BalancoItensBloc({
    required this.listarItensDoBalanco,
    required this.removerItemDoBalanco,
    required this.calcularItensDoBalanco,
  }) : super(const BalancoItensInitial()) {
    on<CarregarItensDoBalancoEvent>(_onCarregarItensDoBalanco);
    on<RemoverItemDoBalancoItensEvent>(_onRemoverItemDoBalanco);
    on<CalcularItensDoBalancoEvent>(_onCalcularItensDoBalanco);
  }

  Future<void> _onCarregarItensDoBalanco(
    CarregarItensDoBalancoEvent event,
    Emitter<BalancoItensState> emit,
  ) async {
    emit(const BalancoItensLoading());
    try {
      final itens = await listarItensDoBalanco(
        balancoId: event.balancoId,
        page: event.page,
        limit: event.limit,
        comDivergencia: event.comDivergencia,
        referencias: event.referencias,
        ordenacao: event.ordenacao,
      );
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

  Future<void> _onCalcularItensDoBalanco(
    CalcularItensDoBalancoEvent event,
    Emitter<BalancoItensState> emit,
  ) async {
    emit(const BalancoItensLoading());
    try {
      await calcularItensDoBalanco(balancoId: event.balancoId);
      final itens = await listarItensDoBalanco(balancoId: event.balancoId);
      emit(BalancoItensLoaded(itens: itens));
    } catch (e, s) {
      addError(e, s);
      emit(BalancoItensError(message: 'Erro ao calcular itens do balanço'));
    }
  }
}
