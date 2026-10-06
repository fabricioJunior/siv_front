import 'package:comercial/models.dart';
import 'package:comercial/use_cases.dart';
import 'package:core/bloc.dart';
import 'package:core/equals.dart';
import 'package:core/remote_data_sourcers.dart';

part 'transferir_credito_event.dart';
part 'transferir_credito_state.dart';

class TransferirCreditoBloc
    extends Bloc<TransferirCreditoEvent, TransferirCreditoState> {
  final GetCreditosTransferiveis _getCreditos;
  final TransferirCreditosDevolucao _transferir;

  TransferirCreditoBloc(this._getCreditos, this._transferir)
      : super(const TransferirCreditoState()) {
    on<TransferirCreditoCarregou>(_onCarregou);
    on<TransferirCreditoAlternou>(_onAlternou);
    on<TransferirCreditoConfirmou>(_onConfirmou);
  }

  Future<void> _onCarregou(
    TransferirCreditoCarregou event,
    Emitter<TransferirCreditoState> emit,
  ) async {
    emit(TransferirCreditoState(
      pessoaId: event.pessoaId,
      status: TransferirCreditoStatus.carregando,
    ));
    try {
      final creditos = await _getCreditos(pessoaId: event.pessoaId);
      emit(state.copyWith(
        status: TransferirCreditoStatus.pronto,
        creditos: creditos,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: TransferirCreditoStatus.erroCarga,
        erro: mensagemDeErroApi(e, 'Falha ao carregar os créditos.'),
      ));
    }
  }

  void _onAlternou(
    TransferirCreditoAlternou event,
    Emitter<TransferirCreditoState> emit,
  ) {
    final sel = {...state.selecionados};
    if (!sel.remove(event.romaneioId)) sel.add(event.romaneioId);
    emit(state.copyWith(selecionados: sel, limparErro: true));
  }

  Future<void> _onConfirmou(
    TransferirCreditoConfirmou event,
    Emitter<TransferirCreditoState> emit,
  ) async {
    if (state.selecionados.isEmpty ||
        state.status == TransferirCreditoStatus.transferindo) {
      return;
    }
    emit(state.copyWith(
      status: TransferirCreditoStatus.transferindo,
      limparErro: true,
    ));
    try {
      final r = await _transferir(
        pessoaId: state.pessoaId,
        romaneioIds: state.selecionados.toList(),
      );
      emit(state.copyWith(
        status: TransferirCreditoStatus.sucesso,
        resultado: r,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: TransferirCreditoStatus.pronto,
        erro: mensagemDeErroApi(e, 'Falha ao transferir o crédito.'),
      ));
    }
  }
}
