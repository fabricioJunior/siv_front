import 'dart:async';

import 'package:autenticacao/models.dart';
import 'package:autenticacao/uses_cases.dart';
import 'package:core/bloc.dart';
import 'package:core/equals.dart';
import 'package:core/injecoes.dart';
import 'package:financeiro/use_cases.dart';

part 'app_state.dart';
part 'app_event.dart';

class AppBloc extends Bloc<AppEvent, AppState>  {
  final OnAutenticado _onAutenticado;
  final OnDesautenticado _onDesautenticado;
  final EstaAutenticado _estaAutenticado;
  final Deslogar _deslogar;
  final RecuperarUsuarioDaSessao _recuperarUsuarioDaSessao;
  final RecuperarLicenciadoDaSessao _recuperarLicenciadoDaSessao;
  final RecuperarEmpresaDaSessao _recuperarEmpresaDaSessao;
  final CriarTokenDeAutenticacao _criarTokenDeAutenticacao;
  final RecuperarCredenciaisDeAutenticacao _recuperarCredenciaisDeAutenticacao;
  final RecuperarTerminalDaSessao _recuperarTerminalDaSessao;
  final RecuperarTerminaisDoUsuarioPorEmpresa
  _recuperarTerminaisDoUsuarioPorEmpresa;
  final SalvarTerminalDaSessao _salvarTerminalDaSessao;
  final LimparTerminalDaSessao _limparTerminalDaSessao;
  final SincronizarPermissoesDoUsuario _sincronizarPermissoesDoUsuario;
  final RecuperarCaixaAberto _recuperarCaixaAberto;

  final ApiBaseUrlConfig _apiBaseUrlConfig;

  late StreamSubscription<Token> _onAutenticacoSubscription;
  late StreamSubscription<Null> _onDesautenticadoSubscription;
  bool _ignorarProximoEventoAppAutenticou = false;
  AppBloc(
    this._estaAutenticado,
    this._onAutenticado,
    this._deslogar,
    this._recuperarUsuarioDaSessao,
    this._onDesautenticado,
    this._recuperarLicenciadoDaSessao,
    this._recuperarEmpresaDaSessao,
    this._criarTokenDeAutenticacao,
    this._recuperarCredenciaisDeAutenticacao,
    this._recuperarTerminalDaSessao,
    this._recuperarTerminaisDoUsuarioPorEmpresa,
    this._salvarTerminalDaSessao,
    this._limparTerminalDaSessao,
    this._sincronizarPermissoesDoUsuario,
    this._recuperarCaixaAberto,
    this._apiBaseUrlConfig,
  ) : super(const AppState()) {
    _onAutenticacoSubscription = _onAutenticado.call().listen(
      (token) => add(AppAutenticou(token: token)),
    );
    _onDesautenticadoSubscription = _onDesautenticado.call().listen(
      (_) => add(AppDesautenticou()),
    );
    on<AppIniciou>(_onAppIniciou);
    on<AppAutenticou>(_onAppAutenticou);
    on<AppDesautenticou>(_onDesautenticou);
    on<AppSelecionouEmpresaDaSessao>(_onSelecionouEmpresaDaSessao);
    on<AppSelecionouTerminalDaSessao>(_onSelecionouTerminalDaSessao);
    on<AppLimpouTerminalDaSessao>(_onLimpouTerminalDaSessao);
    on<AppAtualizouCaixaDaSessao>(_onAtualizouCaixaDaSessao);
  }

  FutureOr<void> _onAppAutenticou(
    AppAutenticou event,
    Emitter<AppState> emit,
  ) async {
    if (_ignorarProximoEventoAppAutenticou) {
      _ignorarProximoEventoAppAutenticou = false;
      return;
    }

    try {
      if (event.token.idEmpresa != null) {
        _atualizarEtapaCarregamento(emit, 'Recuperando usuário da sessão');
      }
      var usuarioDaSessao = await _recuperarUsuarioDaSessao();
      final Empresa? empresaDaSessao;
      if (event.token.idEmpresa == null) {
        empresaDaSessao = null;
      } else {
        _atualizarEtapaCarregamento(emit, 'Carregando empresa da sessão');
        empresaDaSessao = await _recuperarEmpresaDaSessao.call();
      }

      if (event.token.idEmpresa != null) {
        _atualizarEtapaCarregamento(emit, 'Carregando dados do licenciado');
      }
      var licenciadoDaSessao = await _recuperarLicenciadoDaSessao.call();
      if (event.token.idEmpresa != null) {
        _atualizarEtapaCarregamento(emit, 'Carregando terminal da sessão');
      }
      final terminalDaSessao = await _recuperarTerminalDaSessao.call();
      if (event.token.idEmpresa != null) {
        _atualizarEtapaCarregamento(emit, 'Sincronizando permissões');
      }
      var permissoes = await _sincronizarPermissoesDoUsuario(
        idUsuario: usuarioDaSessao!.id,
      );
      var permissoesMap = _mapPermissoes(permissoes);
      if (event.token.idEmpresa != null) {
        _atualizarEtapaCarregamento(emit, 'Carregando terminais disponíveis');
      }
      final terminaisDaEmpresaDaSessao =
          await _carregarTerminaisDaEmpresaDaSessao(
            usuarioDaSessao: usuarioDaSessao,
            empresaDaSessao: empresaDaSessao,
          );
      if (event.token.idEmpresa != null) {
        _atualizarEtapaCarregamento(emit, 'Validando terminal ativo');
      }
   
      if (event.token.idEmpresa != null) {
        _atualizarEtapaCarregamento(emit, 'Carregando caixa da sessão');
      }
      final caixaIdDaSessao = await _recuperarCaixaIdDaSessao(
        empresaDaSessao: empresaDaSessao,
        terminalDaSessao: terminalDaSessao,
      );
      if (event.token.idEmpresa == null) {}
      emit(
        state.copyWith(
          statusAutenticacao: event.token.idEmpresa == null
              ? StatusAutenticacao.autenticando
              : StatusAutenticacao.autenticado,
          usuarioDaSessao: () => usuarioDaSessao,
          empresaDaSessao: () => empresaDaSessao,
          terminaisDaEmpresaDaSessao: terminaisDaEmpresaDaSessao,
          terminalDaSessao: () => terminalDaSessao,
          caixaIdDaSessao: () => caixaIdDaSessao,
          licenciadoDaSessao: () => licenciadoDaSessao,
          permissoesDoUsuario: permissoesMap,
          mensagemErroInicializacao: null,
          detalhesErroInicializacao: null,
          etapaAtualInicializacao: null,
          etapasInicializacaoConcluidas: const [],
        ),
      );
    } catch (e, s) {
      _emitFalhaInicializacao(emit, e, s);
      addError(e, s);
    }
  }

  FutureOr<void> _onDesautenticou(
    AppDesautenticou event,
    Emitter<AppState> emit,
  ) async {
    try {
      await _deslogar.call();
      emit(
        state.copyWith(
          statusAutenticacao: StatusAutenticacao.naoAutenticao,
          usuarioDaSessao: () => null,
          empresaDaSessao: () => null,
          terminalDaSessao: () => null,
          caixaIdDaSessao: () => null,
          licenciadoDaSessao: () => null,
          mensagemErroInicializacao: null,
          detalhesErroInicializacao: null,
          etapaAtualInicializacao: null,
          etapasInicializacaoConcluidas: const [],
        ),
      );
    } catch (e, s) {
      addError(e, s);
    }
  }

  FutureOr<void> _onAppIniciou(AppIniciou event, Emitter<AppState> emit) async {
    try {
      _atualizarEtapaCarregamento(emit, 'Validando licenciamento');
      final licenciadoDaSessao = await _recuperarLicenciadoDaSessao.call();
      if (licenciadoDaSessao != null) {
        _atualizarEtapaCarregamento(emit, 'Configurando conexão com a API');
        _apiBaseUrlConfig.atualizar(licenciadoDaSessao.urlApi);
      } else {
        emit(
          state.copyWith(
            usuarioDaSessao: null,
            statusAutenticacao: StatusAutenticacao.naoAutenticao,
            mensagemErroInicializacao: null,
            detalhesErroInicializacao: null,
            etapaAtualInicializacao: null,
            etapasInicializacaoConcluidas: const [],
          ),
        );
        return;
      }
      _atualizarEtapaCarregamento(emit, 'Verificando autenticação');

      var estaAutenticado = await _estaAutenticado.call();
      Usuario? usuarioDaSessao;
      Empresa? empresaDaSessao;
      TerminalDoUsuario? terminalDaSessao;

      if (estaAutenticado) {
        _atualizarEtapaCarregamento(emit, 'Recuperando usuário da sessão');
        usuarioDaSessao = await _recuperarUsuarioDaSessao();

        _atualizarEtapaCarregamento(emit, 'Carregando empresa da sessão');
        empresaDaSessao = await _recuperarEmpresaDaSessao.call();

        _atualizarEtapaCarregamento(emit, 'Carregando terminal da sessão');
        terminalDaSessao = await _recuperarTerminalDaSessao.call();
      }
      if (estaAutenticado) {
        _atualizarEtapaCarregamento(emit, 'Carregando terminais disponíveis');
      }
      final terminaisDaEmpresaDaSessao =
          await _carregarTerminaisDaEmpresaDaSessao(
            usuarioDaSessao: usuarioDaSessao,
            empresaDaSessao: empresaDaSessao,
          );
      if (estaAutenticado) {
        _atualizarEtapaCarregamento(emit, 'Validando terminal ativo');
      }
      
      if (estaAutenticado) {
        _atualizarEtapaCarregamento(emit, 'Carregando caixa da sessão');
      }
      final caixaIdDaSessao = await _recuperarCaixaIdDaSessao(
        empresaDaSessao: empresaDaSessao,
        terminalDaSessao: terminalDaSessao,
      );
      Map<String, PermissaoDoUsuario>? permissoesMap;
      if (estaAutenticado) {
        _atualizarEtapaCarregamento(emit, 'Sincronizando permissões');
        var permissoes = await _sincronizarPermissoesDoUsuario(
          idUsuario: usuarioDaSessao!.id,
        );
        permissoesMap = _mapPermissoes(permissoes);
      }
      emit(
        state.copyWith(
          usuarioDaSessao: () => usuarioDaSessao,
          empresaDaSessao: () => empresaDaSessao,
          terminaisDaEmpresaDaSessao: terminaisDaEmpresaDaSessao,
          terminalDaSessao: () => terminalDaSessao,
          caixaIdDaSessao: () => caixaIdDaSessao,
          statusAutenticacao: estaAutenticado
              ? StatusAutenticacao.autenticado
              : StatusAutenticacao.naoAutenticao,
          permissoesDoUsuario: estaAutenticado ? permissoesMap : null,
          mensagemErroInicializacao: null,
          detalhesErroInicializacao: null,
          etapaAtualInicializacao: null,
          etapasInicializacaoConcluidas: const [],
        ),
      );
    } catch (e, s) {
      _emitFalhaInicializacao(emit, e, s);
      addError(e, s);
    }
  }

  Map<String, PermissaoDoUsuario> _mapPermissoes(
    Iterable<PermissaoDoUsuario> permissoes,
  ) {
    return Map.fromEntries(
      permissoes.map(
        (permissao) => MapEntry(permissao.componenteId, permissao),
      ),
    );
  }


  Future<List<TerminalDoUsuario>> _carregarTerminaisDaEmpresaDaSessao({
    required Usuario? usuarioDaSessao,
    required Empresa? empresaDaSessao,
  }) async {
    if (usuarioDaSessao == null || empresaDaSessao == null) {
      return const [];
    }

    try {
      return await _recuperarTerminaisDoUsuarioPorEmpresa.call(
        idUsuario: usuarioDaSessao.id,
        idEmpresa: empresaDaSessao.id,
      );
    } catch (_) {
      return const [];
    }
  }

  FutureOr<void> _onSelecionouTerminalDaSessao(
    AppSelecionouTerminalDaSessao event,
    Emitter<AppState> emit,
  ) async {
    final caixaIdDaSessao = await _recuperarCaixaIdDaSessao(
      empresaDaSessao: state.empresaDaSessao,
      terminalDaSessao: event.terminal,
    );

    emit(
      state.copyWith(
        terminalDaSessao: () => event.terminal,
        caixaIdDaSessao: () => caixaIdDaSessao,
      ),
    );

    try {
      await _salvarTerminalDaSessao.call(event.terminal);
    } catch (e, s) {
      addError(e, s);
    }
  }

  FutureOr<void> _onSelecionouEmpresaDaSessao(
    AppSelecionouEmpresaDaSessao event,
    Emitter<AppState> emit,
  ) async {
    try {
      final credenciais = await _recuperarCredenciaisDeAutenticacao.call();
      if (credenciais == null) {
        return;
      }

      _ignorarProximoEventoAppAutenticou = true;
      final token = await _criarTokenDeAutenticacao.call(
        usuario: credenciais.usuario,
        senha: credenciais.senha,
        empresa: event.empresa,
      );

      if (token == null) {
        return;
      }

      final usuarioDaSessao = state.usuarioDaSessao ?? await _recuperarUsuarioDaSessao();
      final licenciadoDaSessao = state.licenciadoDaSessao ?? await _recuperarLicenciadoDaSessao.call();

      final permissoes = await _sincronizarPermissoesDoUsuario(
        idUsuario: usuarioDaSessao!.id,
      );
      final permissoesMap = _mapPermissoes(permissoes);

      final terminaisDaEmpresaDaSessao = await _carregarTerminaisDaEmpresaDaSessao(
        usuarioDaSessao: usuarioDaSessao,
        empresaDaSessao: event.empresa,
      );

      await _limparTerminalDaSessao.call();

      emit(
        state.copyWith(
          statusAutenticacao: StatusAutenticacao.autenticado,
          usuarioDaSessao: () => usuarioDaSessao,
          empresaDaSessao: () => event.empresa,
          terminaisDaEmpresaDaSessao: terminaisDaEmpresaDaSessao,
          terminalDaSessao: () => null,
          caixaIdDaSessao: () => null,
          licenciadoDaSessao: () => licenciadoDaSessao,
          permissoesDoUsuario: permissoesMap,
          mensagemErroInicializacao: null,
          detalhesErroInicializacao: null,
          etapaAtualInicializacao: null,
          etapasInicializacaoConcluidas: const [],
        ),
      );
    } catch (e, s) {
      addError(e, s);
    }
  }

  FutureOr<void> _onLimpouTerminalDaSessao(
    AppLimpouTerminalDaSessao event,
    Emitter<AppState> emit,
  ) async {
    await _limparTerminalDaSessao.call();
    emit(
      state.copyWith(
        terminalDaSessao: () => null,
        caixaIdDaSessao: () => null,
      ),
    );
  }

  FutureOr<void> _onAtualizouCaixaDaSessao(
    AppAtualizouCaixaDaSessao event,
    Emitter<AppState> emit,
  ) {
    if (state.terminalDaSessao?.id == event.terminalId) {
      emit(state.copyWith(caixaIdDaSessao: () => event.caixaId));
    }
  }

  Future<int?> _recuperarCaixaIdDaSessao({
    required Empresa? empresaDaSessao,
    required TerminalDoUsuario? terminalDaSessao,
  }) async {
    if (empresaDaSessao == null || terminalDaSessao == null) {
      return null;
    }

    try {
      final caixa = await _recuperarCaixaAberto.call(
        idEmpresa: empresaDaSessao.id,
        idTerminal: terminalDaSessao.id,
      );
      return caixa?.id;
    } catch (_) {
      return null;
    }
  }

  void _emitFalhaInicializacao(
    Emitter<AppState> emit,
    Object erro,
    StackTrace stackTrace,
  ) {
    emit(
      state.copyWith(
        statusAutenticacao: StatusAutenticacao.falhaInicializacao,
        mensagemErroInicializacao:
            'Não foi possível concluir a inicialização do aplicativo. Tente novamente ou consulte os detalhes técnicos.',
        detalhesErroInicializacao:
            'Etapa: ${state.etapaAtualInicializacao ?? 'Não identificada'}\n\nOrigem: ${erro.runtimeType}\n\nErro: $erro\n\nStack trace:\n$stackTrace',
      ),
    );
  }

  void _atualizarEtapaCarregamento(Emitter<AppState> emit, String etapa) {
    final etapasConcluidas = List<String>.from(
      state.etapasInicializacaoConcluidas,
    );
    final etapaAnterior = state.etapaAtualInicializacao;

    if (etapaAnterior != null &&
        etapaAnterior != etapa &&
        !etapasConcluidas.contains(etapaAnterior)) {
      etapasConcluidas.add(etapaAnterior);
    }

    emit(
      state.copyWith(
        statusAutenticacao: StatusAutenticacao.carregandoDados,
        etapaAtualInicializacao: etapa,
        etapasInicializacaoConcluidas: etapasConcluidas,
      ),
    );
  }


  @override
  Future<void> close() async {
    await _onAutenticacoSubscription.cancel();
    await _onDesautenticadoSubscription.cancel();
    return super.close();
  }
}
