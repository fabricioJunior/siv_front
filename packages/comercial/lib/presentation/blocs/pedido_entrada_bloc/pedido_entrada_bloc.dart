import 'dart:async';

import 'package:comercial/domain/models/pedido_entrada.dart';
import 'package:comercial/domain/models/trilha_entrada.dart';
import 'package:comercial/domain/use_cases/pedido_entrada/pedido_entrada_use_cases.dart';
import 'package:core/bloc.dart';
import 'package:core/equals.dart';
import 'package:core/remote_data_sourcers.dart';
import 'package:core/sessao.dart';

part 'pedido_entrada_event.dart';
part 'pedido_entrada_state.dart';

/// Pedido de Entrada (NF-e / contagem): importar a NF-e, mapear as linhas,
/// pré-cadastrar, contar e resolver divergências. Não mexe em estoque.
class PedidoEntradaBloc extends Bloc<PedidoEntradaEvent, PedidoEntradaState> {
  final ImportarNfeEntrada _importarNfe;
  final CriarEntradaPorContagem _criarPorContagem;
  final ObterPedidoEntrada _obter;
  final VincularLinhaEntrada _vincular;
  final PreCadastrarLinhaEntrada _preCadastrar;
  final IgnorarLinhaEntrada _ignorar;
  final ResolverDivergenciaEntrada _resolverDivergencia;
  final RegistrarContagemEntrada _registrarContagem;
  final RegistrarContagemLivreEntrada _registrarContagemLivre;
  final AssociarContagemLivreEntrada _associarContagemLivre;
  final CorrigirContagemEntrada _corrigirContagem;
  final DecidirDivergenciaEntrada _decidirDivergencia;
  final RegistrarEtiquetasEntrada _registrarEtiquetas;
  final FaturarEntrada _faturar;
  final IAcessoGlobalSessao _sessao;

  int? _pedidoId;

  PedidoEntradaBloc(
    this._importarNfe,
    this._criarPorContagem,
    this._obter,
    this._vincular,
    this._preCadastrar,
    this._ignorar,
    this._resolverDivergencia,
    this._registrarContagem,
    this._registrarContagemLivre,
    this._associarContagemLivre,
    this._corrigirContagem,
    this._decidirDivergencia,
    this._registrarEtiquetas,
    this._faturar,
    this._sessao,
  ) : super(const PedidoEntradaState()) {
    on<PedidoEntradaCarregou>(_onCarregou);
    on<PedidoEntradaImportouNfe>(_onImportou);
    on<PedidoEntradaCriouPorContagem>(_onCriouPorContagem);
    on<PedidoEntradaVinculouLinha>(
      (e, emit) => _salvar(
        emit,
        () => _vincular(_pedidoId!, e.linhaId, e.referenciaId),
        'Item vinculado',
      ),
    );
    on<PedidoEntradaPreCadastrouLinha>(_onPreCadastrou);
    on<PedidoEntradaIgnorouLinha>(
      (e, emit) => _salvar(
        emit,
        () => _ignorar(_pedidoId!, e.linhaId, e.ignorar),
        e.ignorar ? 'Item ignorado' : 'Item reativado',
      ),
    );
    on<PedidoEntradaResolveuDivergencia>(
      (e, emit) => _salvar(
        emit,
        () => _resolverDivergencia(_pedidoId!, e.linhaId, e.observacao),
        'Divergência resolvida',
      ),
    );
    on<PedidoEntradaRegistrouContagem>(
      (e, emit) => _salvar(
        emit,
        () => _registrarContagem(
          _pedidoId!,
          e.itens,
          origem: e.origem,
          motivo: e.motivo,
        ),
        'Contagem registrada',
      ),
    );
    on<PedidoEntradaSelecionouPasso>(
      (e, emit) => emit(state.copyWith(passo: e.passo.clamp(0, 4))),
    );
    on<PedidoEntradaCorrigiuContagem>(_onCorrigiuContagem);
    on<PedidoEntradaDecidiuDivergencia>(
      (e, emit) => _salvar(
        emit,
        () => _decidirDivergencia(
          _pedidoId!,
          e.produtoId,
          e.acao,
          observacao: e.observacao,
        ),
        'Decisão registrada',
      ),
    );
    on<PedidoEntradaPulouEtiquetas>(
      (e, emit) => _etiquetas(emit, () => _registrarEtiquetas(
            _pedidoId!,
            pular: true,
          )),
    );
    on<PedidoEntradaImprimiuEtiquetas>(
      (e, emit) => _etiquetas(emit, () => _registrarEtiquetas(
            _pedidoId!,
            itens: e.itens,
          )),
    );
    on<PedidoEntradaFaturou>(_onFaturou);
    on<PedidoEntradaRegistrouContagemLivre>(
      (e, emit) => _salvar(
        emit,
        () => _registrarContagemLivre(_pedidoId!, e.itens),
        'Contagem sem referência registrada',
      ),
    );
    on<PedidoEntradaAssociouContagemLivre>(
      (e, emit) => _salvar(
        emit,
        () => _associarContagemLivre(
          _pedidoId!,
          e.ids,
          referenciaId: e.referenciaId,
          categoriaId: e.categoriaId,
          nome: e.nome,
        ),
        'Contagem associada à referência',
        seguirEtapa: true,
      ),
    );
  }

  Future<void> _onCarregou(
    PedidoEntradaCarregou event,
    Emitter<PedidoEntradaState> emit,
  ) async {
    _pedidoId = event.pedidoId;
    emit(state.copyWith(carregando: true));
    try {
      emit(
        state.copyWith(
          carregando: false,
          resumo: await _obter(event.pedidoId),
        ),
      );
    } catch (e, s) {
      emit(
        state.copyWith(
          carregando: false,
          erro: mensagemDeErroApi(e, 'Falha ao carregar o pedido de entrada.'),
        ),
      );
      addError(e, s);
    }
  }

  Future<void> _onImportou(
    PedidoEntradaImportouNfe event,
    Emitter<PedidoEntradaState> emit,
  ) async {
    emit(state.copyWith(salvando: true));
    try {
      final resumo = await _importarNfe(
        filePath: event.filePath,
        tabelaPrecoId: event.tabelaPrecoId,
      );
      _pedidoId = resumo.pedidoId;
      emit(
        state.copyWith(
          salvando: false,
          resumo: resumo,
          mensagem: 'NF-e importada',
        ),
      );
    } catch (e, s) {
      emit(
        state.copyWith(
          salvando: false,
          erro: mensagemDeErroApi(e, 'Falha ao importar a NF-e.'),
        ),
      );
      addError(e, s);
    }
  }

  Future<void> _onCriouPorContagem(
    PedidoEntradaCriouPorContagem event,
    Emitter<PedidoEntradaState> emit,
  ) async {
    emit(state.copyWith(salvando: true));
    try {
      final resumo = await _criarPorContagem(
        pessoaId: event.pessoaId,
        tabelaPrecoId: event.tabelaPrecoId,
      );
      _pedidoId = resumo.pedidoId;
      emit(state.copyWith(salvando: false, resumo: resumo));
    } catch (e, s) {
      emit(
        state.copyWith(
          salvando: false,
          erro: mensagemDeErroApi(e, 'Falha ao iniciar a contagem.'),
        ),
      );
      addError(e, s);
    }
  }

  Future<void> _onPreCadastrou(
    PedidoEntradaPreCadastrouLinha event,
    Emitter<PedidoEntradaState> emit,
  ) async {
    await _salvar(
      emit,
      () => _preCadastrar(
        _pedidoId!,
        event.linhaId,
        categoriaId: event.categoriaId,
        nome: event.nome,
      ),
      'Referência criada a partir da NF-e',
      aoConcluir: (resumo) => resumo.linhas
          .where((l) => l.id == event.linhaId)
          .map((l) => l.referenciaId)
          .firstOrNull,
    );
  }

  Future<void> _salvar(
    Emitter<PedidoEntradaState> emit,
    Future<EntradaResumo> Function() acao,
    String mensagem, {
    int? Function(EntradaResumo)? aoConcluir,
    bool seguirEtapa = false,
  }) async {
    // Congela o passo visível: salvar uma contagem não pode empurrar o usuário
    // pra frente (só os eventos que concluem um passo seguem a etapa).
    final visivel = state.resumo == null ? null : state.passoVisivel;
    emit(state.copyWith(salvando: true, resumo: state.resumo, passo: visivel));
    try {
      final resumo = await acao();
      emit(
        state.copyWith(
          salvando: false,
          resumo: resumo,
          mensagem: mensagem,
          referenciaCriadaId: aoConcluir?.call(resumo),
          limparPasso: seguirEtapa,
        ),
      );
    } catch (e, s) {
      emit(
        state.copyWith(
          salvando: false,
          resumo: state.resumo,
          erro: mensagemDeErroApi(e, 'Falha ao salvar.'),
        ),
      );
      addError(e, s);
    }
  }

  Future<void> _onCorrigiuContagem(
    PedidoEntradaCorrigiuContagem event,
    Emitter<PedidoEntradaState> emit,
  ) async {
    final lido = state.resumo?.conferencia.itens
            .where((i) => i.produtoId == event.produtoId)
            .map((i) => i.lido)
            .firstOrNull ??
        0;
    if (event.para < lido) {
      emit(
        state.copyWith(
          erro: 'O contado não pode ficar abaixo do lido (${lido.toInt()}). '
              'Remova a leitura antes.',
        ),
      );
      return;
    }
    await _salvar(
      emit,
      () => _corrigirContagem(
        _pedidoId!,
        event.produtoId,
        event.para,
        motivo: event.motivo,
        origem: event.origem,
      ),
      'Contagem corrigida',
    );
  }

  /// Registra etiquetas (impressas ou puladas) e segue pra Conferir. Backend
  /// antigo (sem `etapa`) não tem o endpoint: segue só no app.
  Future<void> _etiquetas(
    Emitter<PedidoEntradaState> emit,
    Future<EntradaResumo> Function() acao,
  ) async {
    emit(state.copyWith(salvando: true));
    try {
      final resumo = await acao();
      emit(state.copyWith(salvando: false, resumo: resumo, limparPasso: true));
    } catch (e, s) {
      if (state.resumo?.etapa == null) {
        emit(
          state.copyWith(
            salvando: false,
            etiquetasLocal: true,
            limparPasso: true,
          ),
        );
        return;
      }
      emit(
        state.copyWith(
          salvando: false,
          erro: mensagemDeErroApi(e, 'Falha ao registrar as etiquetas.'),
        ),
      );
      addError(e, s);
    }
  }

  Future<void> _onFaturou(
    PedidoEntradaFaturou event,
    Emitter<PedidoEntradaState> emit,
  ) async {
    final resumo = state.resumo;
    if (resumo == null || !TrilhaEntrada.podeFaturar(resumo)) {
      emit(state.copyWith(erro: 'Decida as divergências antes de faturar.'));
      return;
    }
    final caixaId = _sessao.caixaIdDaSessao;
    if (caixaId == null) {
      emit(state.copyWith(erro: 'Abra um caixa para faturar o pedido.'));
      return;
    }
    emit(state.copyWith(salvando: true));
    try {
      await _faturar(resumo.pedidoId, caixaId: caixaId);
      emit(
        state.copyWith(
          salvando: false,
          resumo: await _obter(resumo.pedidoId),
          faturado: true,
          mensagem: 'Pedido faturado',
        ),
      );
    } catch (e, s) {
      emit(
        state.copyWith(
          salvando: false,
          erro: mensagemDeErroApi(e, 'Falha ao faturar o pedido.'),
        ),
      );
      addError(e, s);
    }
  }
}
