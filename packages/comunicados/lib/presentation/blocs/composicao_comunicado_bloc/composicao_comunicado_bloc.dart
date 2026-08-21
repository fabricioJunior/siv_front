import 'dart:async';
import 'dart:io';

import 'package:comunicados/domain/models/models.dart';
import 'package:comunicados/domain/usecases/contar_destinatarios_comunicado.dart';
import 'package:comunicados/domain/usecases/criar_comunicado.dart';
import 'package:comunicados/domain/usecases/enviar_imagem_comunicado.dart';
import 'package:core/bloc.dart';
import 'package:core/equals.dart';
import 'package:core/presentation.dart';

part 'composicao_comunicado_event.dart';
part 'composicao_comunicado_state.dart';

class ComposicaoComunicadoBloc
    extends Bloc<ComposicaoComunicadoEvent, ComposicaoComunicadoState> {
  final ContarDestinatariosComunicado _contarDestinatarios;
  final CriarComunicado _criarComunicado;
  final EnviarImagemComunicado _enviarImagem;
  final _debouncer = Debouncer(milliseconds: 500);

  ComposicaoComunicadoBloc(
    this._contarDestinatarios,
    this._criarComunicado,
    this._enviarImagem, {
    required FiltroDestinatarioComunicado filtroInicial,
  }) : super(ComposicaoComunicadoState.initial(filtro: filtroInicial)) {
    on<ComposicaoAssuntoAlterado>(
      (event, emit) => emit(state.copyWith(assunto: event.assunto)),
    );
    on<ComposicaoCorpoAlterado>(
      (event, emit) => emit(state.copyWith(corpoHtml: event.corpoHtml)),
    );
    on<ComposicaoModoHtmlAvancadoAlterado>(
      (event, emit) =>
          emit(state.copyWith(modoHtmlAvancado: event.modoHtmlAvancado)),
    );
    on<ComposicaoFiltroAlterado>(_onFiltroAlterado);
    on<ComposicaoContarDestinatarios>(_onContarDestinatarios);
    on<ComposicaoImagemSolicitada>(_onImagemSolicitada);
    on<ComposicaoImagemConsumida>(
      (event, emit) => emit(state.copyWith(limparImagemUrl: true)),
    );
    on<ComposicaoEnviar>(_onEnviar);
  }

  @override
  Future<void> close() {
    _debouncer.cancel();
    return super.close();
  }

  FutureOr<void> _onFiltroAlterado(
    ComposicaoFiltroAlterado event,
    Emitter<ComposicaoComunicadoState> emit,
  ) {
    emit(state.copyWith(filtro: event.filtro));
    _debouncer.run(() => add(ComposicaoContarDestinatarios()));
  }

  FutureOr<void> _onContarDestinatarios(
    ComposicaoContarDestinatarios event,
    Emitter<ComposicaoComunicadoState> emit,
  ) async {
    try {
      emit(state.copyWith(contandoDestinatarios: true));
      final total = await _contarDestinatarios.call(state.filtro);
      emit(
        state.copyWith(
          totalDestinatarios: total,
          contandoDestinatarios: false,
        ),
      );
    } catch (e, s) {
      emit(state.copyWith(contandoDestinatarios: false));
      addError(e, s);
    }
  }

  FutureOr<void> _onImagemSolicitada(
    ComposicaoImagemSolicitada event,
    Emitter<ComposicaoComunicadoState> emit,
  ) async {
    try {
      emit(state.copyWith(enviandoImagem: true, limparImagemUrl: true));
      final url = await _enviarImagem.call(File(event.filePath));
      emit(state.copyWith(enviandoImagem: false, imagemUrl: url));
    } catch (e, s) {
      emit(
        state.copyWith(
          enviandoImagem: false,
          erro: 'Falha ao enviar imagem.',
        ),
      );
      addError(e, s);
    }
  }

  FutureOr<void> _onEnviar(
    ComposicaoEnviar event,
    Emitter<ComposicaoComunicadoState> emit,
  ) async {
    try {
      emit(state.copyWith(enviando: true, corpoHtml: event.corpoHtml));
      final comunicado = await _criarComunicado.call(
        assunto: state.assunto,
        corpoHtml: event.corpoHtml,
        modoHtmlAvancado: state.modoHtmlAvancado,
        filtro: state.filtro,
      );
      emit(state.copyWith(enviando: false, comunicadoCriado: comunicado));
    } catch (e, s) {
      emit(
        state.copyWith(enviando: false, erro: 'Falha ao enviar comunicado.'),
      );
      addError(e, s);
    }
  }
}
