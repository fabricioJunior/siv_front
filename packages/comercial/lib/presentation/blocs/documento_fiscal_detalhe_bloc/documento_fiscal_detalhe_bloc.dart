import 'dart:async';

import 'package:comercial/domain/models/documento_fiscal.dart';
import 'package:comercial/domain/use_cases/get_documento_fiscal_detalhe.dart';
import 'package:core/bloc.dart';

part 'documento_fiscal_detalhe_event.dart';
part 'documento_fiscal_detalhe_state.dart';

class DocumentoFiscalDetalheBloc
    extends Bloc<DocumentoFiscalDetalheEvent, DocumentoFiscalDetalheState> {
  final GetDocumentoFiscalDetalhe _getDetalhe;

  DocumentoFiscalDetalheBloc(this._getDetalhe)
      : super(const DocumentoFiscalDetalheState()) {
    on<DocumentoFiscalDetalheCarregar>(_onCarregar);
  }

  FutureOr<void> _onCarregar(
    DocumentoFiscalDetalheCarregar event,
    Emitter<DocumentoFiscalDetalheState> emit,
  ) async {
    try {
      emit(state.copyWith(step: DocumentoFiscalDetalheStep.carregando));
      final detalhe = await _getDetalhe.call(event.id);
      emit(state.copyWith(
        step: DocumentoFiscalDetalheStep.sucesso,
        detalhe: detalhe,
      ));
    } catch (e, s) {
      emit(state.copyWith(
        step: DocumentoFiscalDetalheStep.falha,
        erro: 'Falha ao carregar documento fiscal.',
      ));
      addError(e, s);
    }
  }
}
