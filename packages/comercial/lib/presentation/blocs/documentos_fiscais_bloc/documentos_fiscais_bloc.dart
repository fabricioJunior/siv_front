import 'dart:async';

import 'package:comercial/domain/models/documento_fiscal.dart';
import 'package:comercial/use_cases.dart';
import 'package:core/bloc.dart';
import 'package:core/equals.dart';

part 'documentos_fiscais_event.dart';
part 'documentos_fiscais_state.dart';

class DocumentosFiscaisBloc
    extends Bloc<DocumentosFiscaisEvent, DocumentosFiscaisState> {
  final ListarDocumentosFiscais _listar;
  final ReprocessarDocumentoFiscal _reprocessar;

  DocumentosFiscaisBloc(
    this._listar,
    this._reprocessar,
  ) : super(const DocumentosFiscaisState.initial()) {
    on<DocumentosFiscaisCarregar>(_onCarregar);
    on<DocumentosFiscaisReprocessar>(_onReprocessar);
  }

  FutureOr<void> _onCarregar(
    DocumentosFiscaisCarregar event,
    Emitter<DocumentosFiscaisState> emit,
  ) async {
    try {
      emit(state.copyWith(step: DocumentosFiscaisStep.carregando));
      final result = await _listar.call(
        romaneioId: event.romaneioId,
        pedidoId: event.pedidoId,
        cliente: event.cliente,
        status: event.status,
        formaPagamento: event.formaPagamento,
        dataInicio: event.dataInicio,
        dataFim: event.dataFim,
        page: event.page,
      );
      emit(state.copyWith(
        items: result['items'] as List<DocumentoFiscal>,
        total: result['total'] as int,
        page: event.page,
        step: DocumentosFiscaisStep.sucesso,
      ));
    } catch (e, s) {
      emit(state.copyWith(
        step: DocumentosFiscaisStep.falha,
        erro: 'Falha ao carregar documentos fiscais.',
      ));
      addError(e, s);
    }
  }

  FutureOr<void> _onReprocessar(
    DocumentosFiscaisReprocessar event,
    Emitter<DocumentosFiscaisState> emit,
  ) async {
    try {
      emit(state.copyWith(
        reprocessando: {...state.reprocessando, event.id},
      ));
      final updated = await _reprocessar.call(event.id);
      final items = state.items
          .map((d) => d.id == updated.id ? updated : d)
          .toList();
      final novoReprocessando = {...state.reprocessando}..remove(event.id);
      emit(state.copyWith(items: items, reprocessando: novoReprocessando));
    } catch (e, s) {
      final novoReprocessando = {...state.reprocessando}..remove(event.id);
      emit(state.copyWith(
        reprocessando: novoReprocessando,
        erro: 'Falha ao reprocessar documento.',
      ));
      addError(e, s);
    }
  }
}
