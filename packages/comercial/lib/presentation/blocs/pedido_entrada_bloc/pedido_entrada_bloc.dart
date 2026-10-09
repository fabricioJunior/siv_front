import 'dart:async';

import 'package:comercial/domain/models/pedido_entrada.dart';
import 'package:comercial/domain/use_cases/pedido_entrada/pedido_entrada_use_cases.dart';
import 'package:core/bloc.dart';
import 'package:core/equals.dart';
import 'package:core/remote_data_sourcers.dart';

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
        () => _registrarContagem(_pedidoId!, e.itens),
        'Contagem registrada',
      ),
    );
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
  }) async {
    emit(state.copyWith(salvando: true, resumo: state.resumo));
    try {
      final resumo = await acao();
      emit(
        state.copyWith(
          salvando: false,
          resumo: resumo,
          mensagem: mensagem,
          referenciaCriadaId: aoConcluir?.call(resumo),
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
}
