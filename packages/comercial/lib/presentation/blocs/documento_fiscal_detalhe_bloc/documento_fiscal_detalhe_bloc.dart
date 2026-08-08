import 'dart:async';

import 'package:comercial/domain/models/documento_fiscal.dart';
import 'package:comercial/domain/models/romaneio.dart';
import 'package:comercial/domain/models/romaneio_item.dart';
import 'package:comercial/domain/models/romaneio_item_devolvido.dart';
import 'package:comercial/domain/use_cases/get_documento_fiscal_detalhe.dart';
import 'package:comercial/domain/use_cases/recuperar_itens_devolvidos_romaneio.dart';
import 'package:comercial/domain/use_cases/recuperar_itens_romaneio.dart';
import 'package:comercial/domain/use_cases/recuperar_romaneio.dart';
import 'package:comercial/domain/use_cases/reprocessar_documento_fiscal.dart';
import 'package:core/bloc.dart';

part 'documento_fiscal_detalhe_event.dart';
part 'documento_fiscal_detalhe_state.dart';

class DocumentoFiscalDetalheBloc
    extends Bloc<DocumentoFiscalDetalheEvent, DocumentoFiscalDetalheState> {
  final GetDocumentoFiscalDetalhe _getDetalhe;
  final RecuperarRomaneio _recuperarRomaneio;
  final RecuperarItensRomaneio _recuperarItensRomaneio;
  final RecuperarItensDevolvidosRomaneio _recuperarItensDevolvidosRomaneio;
  final ReprocessarDocumentoFiscal _reprocessar;

  DocumentoFiscalDetalheBloc(
    this._getDetalhe,
    this._recuperarRomaneio,
    this._recuperarItensRomaneio,
    this._recuperarItensDevolvidosRomaneio,
    this._reprocessar,
  ) : super(const DocumentoFiscalDetalheState()) {
    on<DocumentoFiscalDetalheCarregar>(_onCarregar);
    on<DocumentoFiscalDetalheReprocessar>(_onReprocessar);
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
        itens =
            await _recuperarItensRomaneio.call(detalhe.documento.romaneioId);
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

  FutureOr<void> _onReprocessar(
    DocumentoFiscalDetalheReprocessar event,
    Emitter<DocumentoFiscalDetalheState> emit,
  ) async {
    try {
      // Backend sempre reprocessa com forcar=true (ReprocessarDocumentoFiscal), sem checar
      // tentativas/maxTentativas -- de propósito, não replicar esse controle aqui no client.
      emit(state.copyWith(reprocessando: true));
      await _reprocessar.call(event.id);
      final detalhe = await _getDetalhe.call(event.id);
      emit(state.copyWith(reprocessando: false, detalhe: detalhe));
    } catch (e, s) {
      emit(state.copyWith(
        reprocessando: false,
        erro: 'Falha ao reprocessar documento fiscal.',
      ));
      addError(e, s);
    }
  }
}
