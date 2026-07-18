import 'dart:async';

import 'package:comercial/domain/models/documento_fiscal.dart';
import 'package:comercial/domain/models/romaneio.dart';
import 'package:comercial/domain/models/romaneio_item.dart';
import 'package:comercial/domain/models/romaneio_item_devolvido.dart';
import 'package:comercial/domain/use_cases/get_documento_fiscal_detalhe.dart';
import 'package:comercial/domain/use_cases/recuperar_itens_devolvidos_romaneio.dart';
import 'package:comercial/domain/use_cases/recuperar_itens_romaneio.dart';
import 'package:comercial/domain/use_cases/recuperar_romaneio.dart';
import 'package:core/bloc.dart';

part 'documento_fiscal_detalhe_event.dart';
part 'documento_fiscal_detalhe_state.dart';

class DocumentoFiscalDetalheBloc
    extends Bloc<DocumentoFiscalDetalheEvent, DocumentoFiscalDetalheState> {
  final GetDocumentoFiscalDetalhe _getDetalhe;
  final RecuperarRomaneio _recuperarRomaneio;
  final RecuperarItensRomaneio _recuperarItensRomaneio;
  final RecuperarItensDevolvidosRomaneio _recuperarItensDevolvidosRomaneio;

  DocumentoFiscalDetalheBloc(
    this._getDetalhe,
    this._recuperarRomaneio,
    this._recuperarItensRomaneio,
    this._recuperarItensDevolvidosRomaneio,
  ) : super(const DocumentoFiscalDetalheState()) {
    on<DocumentoFiscalDetalheCarregar>(_onCarregar);
  }

  FutureOr<void> _onCarregar(
    DocumentoFiscalDetalheCarregar event,
    Emitter<DocumentoFiscalDetalheState> emit,
  ) async {
    try {
      emit(state.copyWith(step: DocumentoFiscalDetalheStep.carregando));
      final detalhe = await _getDetalhe.call(event.id);

      // Dados do romaneio sao usados tanto para reimprimir o romaneio (quando
      // a emissao falhou e nao ha DANFE) quanto para preencher o cabecalho
      // (empresa) do layout local de DANFE -- por isso carrega sempre, nao
      // so no caso de falha.
      Romaneio? romaneio;
      List<RomaneioItem> itens = const [];
      List<RomaneioItemDevolvido> itensDevolvidos = const [];
      try {
        romaneio = await _recuperarRomaneio.call(detalhe.documento.romaneioId);
        itens = await _recuperarItensRomaneio.call(detalhe.documento.romaneioId);
        itensDevolvidos = await _recuperarItensDevolvidosRomaneio.call(
          detalhe.documento.romaneioId,
        );
      } catch (_) {
        // Falha ao carregar dados do romaneio nao deve impedir a
        // visualizacao do documento fiscal -- so oculta o botao de
        // imprimir romaneio e faz o header do DANFE local usar fallback.
      }

      emit(state.copyWith(
        step: DocumentoFiscalDetalheStep.sucesso,
        detalhe: detalhe,
        romaneioParaImpressao: romaneio,
        itensParaImpressao: itens,
        itensDevolvidosParaImpressao: itensDevolvidos,
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
