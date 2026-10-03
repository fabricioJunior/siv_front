import 'dart:async';

import 'package:core/arquivos.dart';
import 'package:core/bloc.dart';
import 'package:core/equals.dart';
import 'package:core/remote_data_sourcers.dart';
import 'package:core/sync.dart' show ImportacaoProgressoEvent;
import 'package:importacao/domain/data/remote/i_importacao_remote_data_source.dart';
import 'package:importacao/domain/models/importacao_guiada.dart';

part 'importacao_guiada_event.dart';
part 'importacao_guiada_state.dart';

class ImportacaoGuiadaBloc
    extends Bloc<ImportacaoGuiadaEvent, ImportacaoGuiadaState> {
  final IImportacaoRemoteDataSource _remoto;
  final ArquivoService _arquivos;
  final Duration _intervaloConsulta;

  StreamSubscription<ImportacaoProgressoEvent>? _progressoSubscription;
  Timer? _timerConsulta;

  // Os bytes do CSV escolhido não vão para o estado (pode ser grande); o
  // estado só guarda o nome.
  final _arquivosEscolhidos = <ImportacaoEtapa, ArquivoSelecionado>{};

  ImportacaoGuiadaBloc(
    this._remoto,
    this._arquivos,
    Stream<ImportacaoProgressoEvent> progressos, {
    Duration intervaloConsulta = const Duration(seconds: 5),
  }) : _intervaloConsulta = intervaloConsulta,
       super(ImportacaoGuiadaState()) {
    on<ImportacaoGuiadaIniciou>(_onIniciou);
    on<ImportacaoGuiadaEtapaSelecionada>((event, emit) {
      emit(state.copyWith(etapaAtual: event.etapa));
      add(ImportacaoGuiadaPreviaCarregou(event.etapa));
    });
    on<ImportacaoGuiadaPreviaCarregou>(_onPreviaCarregou);
    on<ImportacaoGuiadaModeloBaixado>(_onModeloBaixado);
    on<ImportacaoGuiadaArquivoSelecionado>(_onArquivoSelecionado);
    on<ImportacaoGuiadaTabelaDePrecoAlterada>((event, emit) {
      emit(
        state.comEtapa(
          event.etapa,
          state[event.etapa].copyWith(tabelaDePrecoId: event.tabelaDePrecoId),
        ),
      );
      // Preços: a amostra depende da tabela escolhida.
      if (event.etapa.modeloPrecisaTabela) {
        add(ImportacaoGuiadaPreviaCarregou(event.etapa));
      }
    });
    on<ImportacaoGuiadaFuncionarioAlterado>(
      (event, emit) => emit(
        state.comEtapa(
          ImportacaoEtapa.vendas,
          state[ImportacaoEtapa.vendas].copyWith(
            funcionarioId: event.funcionarioId,
          ),
        ),
      ),
    );
    on<ImportacaoGuiadaEnviou>(_onEnviou);
    on<ImportacaoGuiadaProgressoRecebido>(_onProgresso);
    on<ImportacaoGuiadaDetalhou>(_onDetalhou);
    on<ImportacaoGuiadaConsultou>(_onConsultou);

    _progressoSubscription = progressos.listen(
      (progresso) => add(ImportacaoGuiadaProgressoRecebido(progresso)),
    );
  }

  Future<void> _onIniciou(
    ImportacaoGuiadaIniciou event,
    Emitter<ImportacaoGuiadaState> emit,
  ) async {
    emit(state.copyWith(carregando: true));
    try {
      final etapas = {...state.etapas};
      for (final importacao in await _remoto.listarUltimas()) {
        final etapa = ImportacaoEtapa.deTipo(importacao.tipo);
        if (etapa == null) continue;
        etapas[etapa] = etapas[etapa]!.copyWith(importacao: importacao);
      }
      var carregado = state.copyWith(etapas: etapas, carregando: false);
      carregado = carregado.copyWith(etapaAtual: _etapaParaAbrir(carregado));
      emit(carregado);

      // O resumo da listagem não traz as rejeições: busca só onde há.
      for (final etapa in ImportacaoEtapa.values) {
        final importacao = carregado[etapa].importacao;
        if (importacao != null &&
            importacao.situacao.finalizada &&
            importacao.rejeitados > 0) {
          add(ImportacaoGuiadaDetalhou(etapa));
        }
      }
      add(ImportacaoGuiadaPreviaCarregou(state.etapaAtual));
      _ajustarConsulta();
    } catch (e, s) {
      emit(
        state.copyWith(
          carregando: false,
          erro: mensagemDeErroApi(e, 'Falha ao carregar as importações.'),
        ),
      );
      addError(e, s);
    }
  }

  // Abre na primeira etapa ainda não concluída (ou na última, se todas já
  // foram).
  ImportacaoEtapa _etapaParaAbrir(ImportacaoGuiadaState estado) {
    for (final etapa in ImportacaoEtapa.values) {
      if (!estado[etapa].concluida) return etapa;
    }
    return ImportacaoEtapa.values.last;
  }

  Future<void> _onPreviaCarregou(
    ImportacaoGuiadaPreviaCarregou event,
    Emitter<ImportacaoGuiadaState> emit,
  ) async {
    final etapa = event.etapa;
    final tabelaId = state[etapa].tabelaDePrecoId;
    if (etapa.modeloPrecisaTabela && tabelaId == null) {
      emit(
        state.comEtapa(
          etapa,
          state[etapa].copyWith(previa: null, erroPrevia: null),
        ),
      );
      return;
    }
    emit(
      state.comEtapa(
        etapa,
        state[etapa].copyWith(carregandoPrevia: true, erroPrevia: null),
      ),
    );
    try {
      final previa = await _remoto.previa(etapa, tabelaDePrecoId: tabelaId);
      emit(
        state.comEtapa(
          etapa,
          state[etapa].copyWith(previa: previa, carregandoPrevia: false),
        ),
      );
    } catch (e, s) {
      emit(
        state.comEtapa(
          etapa,
          state[etapa].copyWith(
            carregandoPrevia: false,
            erroPrevia: mensagemDeErroApi(
              e,
              'Não foi possível carregar a pré-visualização.',
            ),
          ),
        ),
      );
      addError(e, s);
    }
  }

  Future<void> _onModeloBaixado(
    ImportacaoGuiadaModeloBaixado event,
    Emitter<ImportacaoGuiadaState> emit,
  ) async {
    final tabelaId = state[event.etapa].tabelaDePrecoId;
    if (event.etapa.modeloPrecisaTabela && tabelaId == null) {
      emit(state.copyWith(erro: 'Selecione a tabela de preço do modelo.'));
      return;
    }
    try {
      final bytes = await _remoto.baixarModelo(
        event.etapa,
        query: event.etapa.modeloPrecisaTabela
            ? {...event.etapa.queryModelo, 'tabelaDePrecoId': '$tabelaId'}
            : event.etapa.queryModelo,
      );
      final destino = await _arquivos.salvarBytes(
        bytes: bytes,
        nomeSugerido: event.etapa.nomeModelo,
      );
      if (destino != null) {
        emit(state.copyWith(mensagem: 'Modelo salvo em $destino'));
      }
    } catch (e, s) {
      emit(
        state.copyWith(erro: mensagemDeErroApi(e, 'Falha ao baixar o modelo.')),
      );
      addError(e, s);
    }
  }

  Future<void> _onArquivoSelecionado(
    ImportacaoGuiadaArquivoSelecionado event,
    Emitter<ImportacaoGuiadaState> emit,
  ) async {
    final arquivo = await _arquivos.selecionarArquivoComBytes(
      extensoes: ['csv'],
    );
    if (arquivo == null) return;
    _arquivosEscolhidos[event.etapa] = arquivo;
    emit(
      state.comEtapa(
        event.etapa,
        state[event.etapa].copyWith(arquivoNome: arquivo.nome),
      ),
    );
  }

  Future<void> _onEnviou(
    ImportacaoGuiadaEnviou event,
    Emitter<ImportacaoGuiadaState> emit,
  ) async {
    final etapa = event.etapa;
    final atual = state[etapa];
    final arquivo = _arquivosEscolhidos[etapa];
    if (arquivo == null) {
      emit(state.copyWith(erro: 'Selecione o arquivo CSV preenchido.'));
      return;
    }
    if (etapa == ImportacaoEtapa.vendas &&
        (atual.tabelaDePrecoId == null || atual.funcionarioId == null)) {
      emit(
        state.copyWith(
          erro: 'Selecione a tabela de preço e o funcionário das vendas.',
        ),
      );
      return;
    }

    emit(state.comEtapa(etapa, atual.copyWith(enviando: true)));
    try {
      final criada = await _remoto.enviar(
        etapa,
        bytes: arquivo.bytes,
        nomeArquivo: arquivo.nome,
        parametros: etapa == ImportacaoEtapa.vendas
            ? {
                'tabelaDePrecoId': '${atual.tabelaDePrecoId}',
                'funcionarioId': '${atual.funcionarioId}',
              }
            : const {},
      );
      _arquivosEscolhidos.remove(etapa);
      // O servidor pode ter avisado o andamento pelo socket antes de a
      // resposta do POST chegar: nesse caso o estado já está mais novo.
      final jaAtualizada = state[etapa].importacao?.id == criada.id;
      emit(
        state.comEtapa(
          etapa,
          state[etapa].copyWith(
            importacao: jaAtualizada ? state[etapa].importacao : criada,
            arquivoNome: null,
            enviando: false,
          ),
        ),
      );
      _ajustarConsulta();
    } catch (e, s) {
      emit(
        state.comEtapa(
          etapa,
          state[etapa].copyWith(enviando: false),
          erro: mensagemDeErroApi(e, 'Falha ao enviar o arquivo.'),
        ),
      );
      addError(e, s);
    }
  }

  void _onProgresso(
    ImportacaoGuiadaProgressoRecebido event,
    Emitter<ImportacaoGuiadaState> emit,
  ) {
    final progresso = event.progresso;
    final etapa = ImportacaoEtapa.deTipo(progresso.tipo);
    if (etapa == null) return;

    final atual = state[etapa].importacao;
    // Evento atrasado de uma importação mais antiga que a exibida.
    if (atual != null && progresso.id < atual.id) return;

    final nova = atual != null && atual.id == progresso.id
        ? atual.comProgresso(progresso)
        : ImportacaoGuiada.deEvento(progresso);
    emit(state.comEtapa(etapa, state[etapa].copyWith(importacao: nova)));

    final terminouAgora =
        nova.situacao.finalizada &&
        !(atual?.id == nova.id && atual!.situacao.finalizada);
    if (terminouAgora) {
      add(ImportacaoGuiadaDetalhou(etapa));
      add(ImportacaoGuiadaPreviaCarregou(etapa)); // o que entrou agora
    }
    _ajustarConsulta();
  }

  Future<void> _onDetalhou(
    ImportacaoGuiadaDetalhou event,
    Emitter<ImportacaoGuiadaState> emit,
  ) async {
    final importacao = state[event.etapa].importacao;
    if (importacao == null) return;
    try {
      final detalhada = await _remoto.consultar(importacao.id);
      // Se uma importação mais nova já assumiu a etapa, descarta.
      if (state[event.etapa].importacao?.id != detalhada.id) return;
      emit(
        state.comEtapa(
          event.etapa,
          state[event.etapa].copyWith(importacao: detalhada),
        ),
      );
    } catch (e, s) {
      // O resumo já está na tela; só faltam os detalhes.
      addError(e, s);
    }
  }

  Future<void> _onConsultou(
    ImportacaoGuiadaConsultou event,
    Emitter<ImportacaoGuiadaState> emit,
  ) async {
    for (final etapa in ImportacaoEtapa.values) {
      final importacao = state[etapa].importacao;
      if (importacao == null || !importacao.situacao.emAndamento) continue;
      try {
        final consultada = await _remoto.consultar(importacao.id);
        if (state[etapa].importacao?.id != consultada.id) continue;
        emit(
          state.comEtapa(etapa, state[etapa].copyWith(importacao: consultada)),
        );
      } catch (e, s) {
        addError(e, s);
      }
    }
    _ajustarConsulta();
  }

  // Liga a consulta periódica enquanto houver importação em andamento e
  // desliga quando todas terminarem.
  void _ajustarConsulta() {
    final haAndamento = state.etapas.values.any((etapa) => etapa.emAndamento);
    if (!haAndamento) {
      _timerConsulta?.cancel();
      _timerConsulta = null;
      return;
    }
    _timerConsulta ??= Timer.periodic(
      _intervaloConsulta,
      (_) => add(const ImportacaoGuiadaConsultou()),
    );
  }

  @override
  Future<void> close() {
    _progressoSubscription?.cancel();
    _timerConsulta?.cancel();
    return super.close();
  }
}
