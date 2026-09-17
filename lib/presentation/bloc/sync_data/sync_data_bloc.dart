import 'dart:async';

import 'package:autenticacao/models.dart';
import 'package:autenticacao/domain/usecases/recuperar_permissoes_do_usuario.dart';
import 'package:autenticacao/uses_cases.dart';
import 'package:core/bloc.dart';
import 'package:core/equals.dart';
import 'package:core/injecoes.dart';
import 'package:core/paginacao.dart';
import 'package:core/sync.dart';
import 'package:estoque/estoque.dart';
import 'package:precos/use_cases.dart';
import 'package:produtos/domain/use_cases/sincronizar_codigos.dart';

part 'sync_data_event.dart';
part 'sync_data_state.dart';

class SyncDataBloc extends Bloc<SyncDataEvent, SyncDataState> {
  // Ordem em que os 3 modulos "pesados" (paginacao completa do catalogo) sao
  // sincronizados -- um de cada vez, nunca em paralelo. Disparar os 3 juntos
  // (como era antes) triplicava a carga simultanea no servidor: cada modulo
  // pagina sozinho de forma bem-comportada, mas rodar 3 streams concorrentes
  // multiplicava picos de CPU no backend (confirmado via teste de carga).
  // precosDaReferencia fica de fora dessa fila -- ja tem encadeamento proprio
  // em _onModuloConcluido, so depois que tabelasDePreco termina.
  static const _ordemModulosSequenciais = [
    SyncModulo.codigos,
    SyncModulo.estoque,
    SyncModulo.tabelasDePreco,
  ];
  final SincronizarCodigos _sincronizarCodigos;
  final SincronizarEstoque _sincronizarEstoque;
  final SincronziarTabelasDePreco _sincronizarTabelasDePreco;
  final SincronizarPrecos _sincronizarPrecos;
  final EstaAutenticado _estaAutenticado;
  final RecuperarUsuarioDaSessao _recuperarUsuarioDaSessao;
  final RecuperarEmpresaDaSessao _recuperarEmpresaDaSessao;
  final RecuperarPermissoesDoUsuario _recuperarPermissoesDoUsuario;
  final LimparSincronizacaoIncremental _limparSincronizacaoIncremental;
  final SyncWebSocketService _syncWebSocketService;
  final RecuperarTokenJwt _recuperarTokenJwt;
  final ApiBaseUrlConfig _apiBaseUrlConfig;
  final OnDesautenticado _onDesautenticado;

  StreamSubscription<Paginacao>? _codigosSubscription;
  StreamSubscription<Paginacao>? _estoqueSubscription;
  StreamSubscription<Paginacao>? _tabelasDePrecoSubscription;
  StreamSubscription<Paginacao>? _precosDaReferenciaSubscription;
  StreamSubscription<SyncMudancaEvent>? _mudancasWsSubscription;
  StreamSubscription<bool>? _conectadoWsSubscription;
  StreamSubscription<Null>? _onDesautenticadoSubscription;

  // Rajada de eventos `sync:mudanca` (varias mudancas em sequencia no
  // servidor) vira 1 sync so -- reinicia o timer a cada evento novo.
  Timer? _debounceMudancaWs;
  static const _debounceMudancaWsDuracao = Duration(seconds: 3);

  // Rede de seguranca: se o WS ficar desconectado por tempo demais (ex:
  // instabilidade de rede que o retry automatico do socket.io ainda nao
  // recuperou), poll de baixa frequencia garante que o app nao fica cego
  // indefinidamente -- a sync incremental por atualizadoEm cobre o que
  // ficou pra tras sozinha, isso so garante que ela roda de tempos em tempos.
  Timer? _fallbackPollingWs;
  static const _fallbackPollingWsIntervalo = Duration(minutes: 3);

  bool _conectadoAoWs = false;
  bool _jaConectouAoWsAlgumaVez = false;

  SyncDataOrigem? _origemPendenteAposSincronizacaoAtual;

  SyncDataBloc(
    this._sincronizarCodigos,
    this._sincronizarEstoque,
    this._sincronizarTabelasDePreco,
    this._sincronizarPrecos,
    this._estaAutenticado,
    this._recuperarUsuarioDaSessao,
    this._recuperarEmpresaDaSessao,
    this._recuperarPermissoesDoUsuario,
    this._limparSincronizacaoIncremental,
    this._syncWebSocketService,
    this._recuperarTokenJwt,
    this._apiBaseUrlConfig,
    this._onDesautenticado,
  ) : super(const SyncDataState()) {
    on<SyncDataSolicitouSincronizacao>(_onSolicitouSincronizacao);
    on<SyncDataAtualizacaoRecebida>(_onAtualizacaoRecebida);
    on<SyncDataModuloConcluido>(_onModuloConcluido);
    on<SyncDataModuloFalhou>(_onModuloFalhou);
    on<SyncDataSolicitouResetIncremental>(_onResetIncremental);

    _mudancasWsSubscription = _syncWebSocketService.mudancas.listen((_) {
      _debounceMudancaWs?.cancel();
      _debounceMudancaWs = Timer(_debounceMudancaWsDuracao, () {
        add(
          const SyncDataSolicitouSincronizacao(
            origem: SyncDataOrigem.tempoReal,
          ),
        );
      });
    });

    _conectadoWsSubscription = _syncWebSocketService.conectado.listen((
      conectado,
    ) {
      final reconectou =
          !_conectadoAoWs && conectado && _jaConectouAoWsAlgumaVez;
      _conectadoAoWs = conectado;
      _jaConectouAoWsAlgumaVez = true;
      if (reconectou) {
        add(
          const SyncDataSolicitouSincronizacao(
            origem: SyncDataOrigem.tempoReal,
          ),
        );
      }
    });

    _onDesautenticadoSubscription = _onDesautenticado.call().listen((_) {
      _syncWebSocketService.disconnect();
    });

    _fallbackPollingWs = Timer.periodic(_fallbackPollingWsIntervalo, (_) {
      if (!_conectadoAoWs) {
        add(
          const SyncDataSolicitouSincronizacao(
            origem: SyncDataOrigem.tempoReal,
          ),
        );
      }
    });
  }

  Future<void> _onResetIncremental(
    SyncDataSolicitouResetIncremental event,
    Emitter<SyncDataState> emit,
  ) async {
    await _limparSincronizacaoIncremental();
    add(const SyncDataSolicitouSincronizacao(origem: SyncDataOrigem.manual));
  }

  Future<void> _onSolicitouSincronizacao(
    SyncDataSolicitouSincronizacao event,
    Emitter<SyncDataState> emit,
  ) async {
    if (!await _usuarioAutenticadoComEmpresa()) {
      return;
    }

    await _conectarWebSocketSeNecessario();

    if (_sincronizacaoEmAndamentoSemErros()) {
      _origemPendenteAposSincronizacaoAtual = event.origem;
      return;
    }

    if (event.origem == SyncDataOrigem.home && state.homeJaSincronizada) {
      return;
    }

    await _cancelarSincronizacoesAtivas();

    final usuarioDaSessao = await _recuperarUsuarioDaSessao();
    final usuarioAtualEhSysAdmin =
      usuarioDaSessao?.tipo == TipoUsuario.sysadmin;

    final permissoesDoUsuario = await _carregarPermissoesDoUsuario();
    final modulosPermitidos = _resolverModulosPermitidos(
      permissoesDoUsuario: permissoesDoUsuario,
      usuarioAtualEhSysAdmin: usuarioAtualEhSysAdmin,
    );

    final modulosEmSincronizacao = <SyncModulo, SyncModuloState>{
      for (final modulo in state.modulos.entries)
        modulo.key: modulo.value.copyWith(
          status: _resolverStatusInicialModulo(modulo.key, modulosPermitidos),
          erro: modulosPermitidos.contains(modulo.key)
              ? null
              : 'Sincronização não permitida para o seu perfil.',
          paginaAtual: 0,
          totalPaginas: 0,
          paginasSincronizadas: 0,
          totalItens: 0,
          itensSincronizados: 0,
          atualizadoEm: DateTime.now(),
        ),
    };

    emit(
      state.copyWith(
        homeJaSincronizada: event.origem == SyncDataOrigem.home
            ? true
            : state.homeJaSincronizada,
        iniciadoEm: DateTime.now(),
        finalizadoEm: null,
        origemUltimaSincronizacao: event.origem,
        usuarioAtualEhSysAdmin: usuarioAtualEhSysAdmin,
        permissoesDoUsuario: permissoesDoUsuario,
        modulos: modulosEmSincronizacao,
      ),
    );

    _iniciarProximoModuloSequencial(modulosPermitidos);
  }

  // Dispara o primeiro modulo da fila (a partir de `apos`, exclusive) que
  // estiver em `modulosPermitidos` -- os demais so iniciam quando esse
  // terminar (sucesso ou falha), via _onModuloConcluido/_onModuloFalhou.
  void _iniciarProximoModuloSequencial(
    Set<SyncModulo> modulosPermitidos, [
    SyncModulo? apos,
  ]) {
    final indiceInicial = apos == null
        ? 0
        : _ordemModulosSequenciais.indexOf(apos) + 1;

    for (var i = indiceInicial; i < _ordemModulosSequenciais.length; i++) {
      final modulo = _ordemModulosSequenciais[i];
      if (!modulosPermitidos.contains(modulo)) {
        continue;
      }
      switch (modulo) {
        case SyncModulo.codigos:
          _iniciarSincronizacaoCodigos();
        case SyncModulo.estoque:
          _iniciarSincronizacaoEstoque();
        case SyncModulo.tabelasDePreco:
          _iniciarSincronizacaoTabelasDePreco();
        case SyncModulo.precosDaReferencia:
          break;
      }
      return;
    }
  }

  void _onAtualizacaoRecebida(
    SyncDataAtualizacaoRecebida event,
    Emitter<SyncDataState> emit,
  ) {
    final modulo = state.modulos[event.modulo]!;
    final houveProcessamentoNaPagina =
        event.paginacao.itensProcessadosNaPagina > 0;
    final paginasSincronizadas = houveProcessamentoNaPagina
        ? (modulo.paginasSincronizadas + 1).clamp(
            0,
            event.paginacao.totalPaginas,
          )
        : modulo.paginasSincronizadas;
    final itensSincronizados =
        (modulo.itensSincronizados + event.paginacao.itensProcessadosNaPagina)
            .clamp(0, event.paginacao.totalItens);

    emit(
      state.copyWith(
        modulos: {
          ...state.modulos,
          event.modulo: modulo.copyWith(
            status: SyncModuloStatus.sincronizando,
            paginaAtual: event.paginacao.paginaAtual,
            totalPaginas: event.paginacao.totalPaginas,
            paginasSincronizadas: paginasSincronizadas,
            totalItens: event.paginacao.totalItens,
            itensSincronizados: itensSincronizados,
            atualizadoEm: event.paginacao.dataAtualizacao,
            erro: null,
          ),
        },
      ),
    );
  }

  void _onModuloConcluido(
    SyncDataModuloConcluido event,
    Emitter<SyncDataState> emit,
  ) {
    final modulo = state.modulos[event.modulo]!;

    if (modulo.status == SyncModuloStatus.falha) {
      return;
    }

    final modulosAtualizados = {
      ...state.modulos,
      event.modulo: modulo.copyWith(
        status: SyncModuloStatus.concluido,
        atualizadoEm: DateTime.now(),
      ),
    };

    emit(
      state.copyWith(
        modulos: modulosAtualizados,
        finalizadoEm: _todosModulosFinalizados(modulosAtualizados)
            ? DateTime.now()
            : null,
      ),
    );

    if (event.modulo == SyncModulo.tabelasDePreco) {
      if (_resolverModulosPermitidos().contains(
        SyncModulo.precosDaReferencia,
      )) {
        final moduloPrecos = state.modulos[SyncModulo.precosDaReferencia]!;
        if (moduloPrecos.status == SyncModuloStatus.aguardando) {
          emit(
            state.copyWith(
              modulos: {
                ...state.modulos,
                SyncModulo.precosDaReferencia: moduloPrecos.copyWith(
                  status: SyncModuloStatus.sincronizando,
                  erro: null,
                  atualizadoEm: DateTime.now(),
                ),
              },
            ),
          );
          _iniciarSincronizacaoPrecosDaReferencia();
        }
      }
    }

    if (_ordemModulosSequenciais.contains(event.modulo)) {
      _iniciarProximoModuloSequencial(
        _resolverModulosPermitidos(),
        event.modulo,
      );
    }

    _dispararSincronizacaoPendenteSeTudoFinalizado();
  }

  void _onModuloFalhou(
    SyncDataModuloFalhou event,
    Emitter<SyncDataState> emit,
  ) {
    final modulo = state.modulos[event.modulo]!;
    final modulosAtualizados = {
      ...state.modulos,
      event.modulo: modulo.copyWith(
        status: SyncModuloStatus.falha,
        erro: event.erro,
        atualizadoEm: DateTime.now(),
      ),
    };

    if (event.modulo == SyncModulo.tabelasDePreco) {
      final moduloPrecos = modulosAtualizados[SyncModulo.precosDaReferencia]!;
      if (moduloPrecos.status != SyncModuloStatus.concluido &&
          moduloPrecos.status != SyncModuloStatus.falha) {
        modulosAtualizados[SyncModulo.precosDaReferencia] = moduloPrecos
            .copyWith(
              status: SyncModuloStatus.falha,
              erro:
                  'A sincronização depende da conclusão das tabelas de preço.',
              atualizadoEm: DateTime.now(),
            );
      }
    }

    emit(
      state.copyWith(
        modulos: modulosAtualizados,
        finalizadoEm: _todosModulosFinalizados(modulosAtualizados)
            ? DateTime.now()
            : null,
      ),
    );

    if (_ordemModulosSequenciais.contains(event.modulo)) {
      _iniciarProximoModuloSequencial(
        _resolverModulosPermitidos(),
        event.modulo,
      );
    }

    _dispararSincronizacaoPendenteSeTudoFinalizado();
  }

  void _dispararSincronizacaoPendenteSeTudoFinalizado() {
    final origemPendente = _origemPendenteAposSincronizacaoAtual;
    if (origemPendente == null || state.sincronizando) {
      return;
    }

    _origemPendenteAposSincronizacaoAtual = null;
    add(SyncDataSolicitouSincronizacao(origem: origemPendente));
  }

  void _iniciarSincronizacaoCodigos() {
    _codigosSubscription = _sincronizarCodigos().listen(
      (paginacao) {
        add(
          SyncDataAtualizacaoRecebida(
            modulo: SyncModulo.codigos,
            paginacao: paginacao,
          ),
        );
      },
      onError: (error, stackTrace) {
        addError(error, stackTrace);
        add(
          SyncDataModuloFalhou(
            modulo: SyncModulo.codigos,
            erro: error.toString(),
          ),
        );
      },
      onDone: () {
        add(const SyncDataModuloConcluido(modulo: SyncModulo.codigos));
      },
      cancelOnError: true,
    );
  }

  void _iniciarSincronizacaoEstoque() {
    _estoqueSubscription = _sincronizarEstoque().listen(
      (paginacao) {
        add(
          SyncDataAtualizacaoRecebida(
            modulo: SyncModulo.estoque,
            paginacao: paginacao,
          ),
        );
      },
      onError: (error, stackTrace) {
        addError(error, stackTrace);
        add(
          SyncDataModuloFalhou(
            modulo: SyncModulo.estoque,
            erro: error.toString(),
          ),
        );
      },
      onDone: () {
        add(const SyncDataModuloConcluido(modulo: SyncModulo.estoque));
      },
      cancelOnError: true,
    );
  }

  void _iniciarSincronizacaoTabelasDePreco() {
    _tabelasDePrecoSubscription = _sincronizarTabelasDePreco().listen(
      (paginacao) {
        add(
          SyncDataAtualizacaoRecebida(
            modulo: SyncModulo.tabelasDePreco,
            paginacao: paginacao,
          ),
        );
      },
      onError: (error, stackTrace) {
        addError(error, stackTrace);
        add(
          SyncDataModuloFalhou(
            modulo: SyncModulo.tabelasDePreco,
            erro: error.toString(),
          ),
        );
      },
      onDone: () {
        add(const SyncDataModuloConcluido(modulo: SyncModulo.tabelasDePreco));
      },
      cancelOnError: true,
    );
  }

  void _iniciarSincronizacaoPrecosDaReferencia() {
    _precosDaReferenciaSubscription = _sincronizarPrecos().listen(
      (paginacao) {
        add(
          SyncDataAtualizacaoRecebida(
            modulo: SyncModulo.precosDaReferencia,
            paginacao: paginacao,
          ),
        );
      },
      onError: (error, stackTrace) {
        addError(error, stackTrace);
        add(
          SyncDataModuloFalhou(
            modulo: SyncModulo.precosDaReferencia,
            erro: error.toString(),
          ),
        );
      },
      onDone: () {
        add(
          const SyncDataModuloConcluido(modulo: SyncModulo.precosDaReferencia),
        );
      },
      cancelOnError: true,
    );
  }

  bool _todosModulosFinalizados(Map<SyncModulo, SyncModuloState> modulos) {
    return modulos.values.every(
      (modulo) =>
          modulo.status == SyncModuloStatus.concluido ||
          modulo.status == SyncModuloStatus.falha,
    );
  }

  // Conecta o WS de sinalizacao (idempotente -- `connect` e' no-op se ja
  // conectado com o mesmo token). Chamado a cada solicitacao de sync porque
  // e' o unico ponto que sabemos que ha sessao valida; cobre tanto o login
  // recente quanto a sessao restaurada num boot novo do app (que nao dispara
  // nenhum evento de "acabou de logar").
  Future<void> _conectarWebSocketSeNecessario() async {
    final token = await _recuperarTokenJwt();
    if (token == null) {
      return;
    }
    _syncWebSocketService.connect(
      token: token,
      baseUrl: _apiBaseUrlConfig.urlBase,
    );
  }

  Future<bool> _usuarioAutenticadoComEmpresa() async {
    final estaAutenticado = await _estaAutenticado();
    final empresa = await _recuperarEmpresaDaSessao();
    return estaAutenticado &&
        empresa != null;
  }

  bool _sincronizacaoEmAndamentoSemErros() {
    return state.sincronizando &&
        state.modulos.values.every(
          (modulo) => modulo.status != SyncModuloStatus.falha,
        );
  }

  Future<Map<String, PermissaoDoUsuario>> _carregarPermissoesDoUsuario() async {
    final usuario = await _recuperarUsuarioDaSessao();
    if (usuario == null) {
      return const {};
    }

    final permissoes = await _recuperarPermissoesDoUsuario(usuario.id);
    return Map.fromEntries(
      permissoes.map(
        (permissao) => MapEntry(permissao.componenteId, permissao),
      ),
    );
  }

  Set<SyncModulo> _resolverModulosPermitidos({
    Map<String, PermissaoDoUsuario>? permissoesDoUsuario,
    bool? usuarioAtualEhSysAdmin,
  }) {
    if (usuarioAtualEhSysAdmin ?? state.usuarioAtualEhSysAdmin) {
      return SyncModulo.values.toSet();
    }

    final permitidos = <SyncModulo>{};
    final permissoes = permissoesDoUsuario ?? state.permissoesDoUsuario;

    if (_temAcessoAAlgumComponente(const [
      'PRDFM001',
      'PRDFM003',
      'PRDFM004',
      'PRDFM005',
      'PRDFM006',
      'PRDFM007',
      'PRDFM010',
      'PRDFM011',
    ], permissoes)) {
      permitidos.add(SyncModulo.codigos);
    }

    if (_temAcessoAAlgumComponente(const [
      'PRDFL001',
      'BALFP001',
      'BALFP002',
      'BALFP003',
      'BALFP004',
    ], permissoes)) {
      permitidos.add(SyncModulo.estoque);
    }

    if (_temAcessoAAlgumComponente(const ['PRDFM010'], permissoes)) {
      permitidos.add(SyncModulo.tabelasDePreco);
    }

    if (_temAcessoAAlgumComponente(const ['PRDFM011'], permissoes)) {
      permitidos.add(SyncModulo.precosDaReferencia);
    }

    return permitidos;
  }

  SyncModuloStatus _resolverStatusInicialModulo(
    SyncModulo modulo,
    Set<SyncModulo> modulosPermitidos,
  ) {
    if (!modulosPermitidos.contains(modulo)) {
      return SyncModuloStatus.concluido;
    }

    if (modulo == SyncModulo.precosDaReferencia) {
      return SyncModuloStatus.aguardando;
    }

    return SyncModuloStatus.sincronizando;
  }

  bool _temAcessoAAlgumComponente(
    List<String> componentes,
    Map<String, PermissaoDoUsuario> permissoesDoUsuario,
  ) {
    for (final componente in componentes) {
      if (permissoesDoUsuario.containsKey(componente)) {
        return true;
      }
    }

    return false;
  }

  Future<void> _cancelarSincronizacoesAtivas() async {
    await _codigosSubscription?.cancel();
    await _estoqueSubscription?.cancel();
    await _tabelasDePrecoSubscription?.cancel();
    await _precosDaReferenciaSubscription?.cancel();
    _codigosSubscription = null;
    _estoqueSubscription = null;
    _tabelasDePrecoSubscription = null;
    _precosDaReferenciaSubscription = null;
  }

  @override
  Future<void> close() async {
    await _cancelarSincronizacoesAtivas();
    await _mudancasWsSubscription?.cancel();
    await _conectadoWsSubscription?.cancel();
    await _onDesautenticadoSubscription?.cancel();
    _debounceMudancaWs?.cancel();
    _fallbackPollingWs?.cancel();
    return super.close();
  }
}
