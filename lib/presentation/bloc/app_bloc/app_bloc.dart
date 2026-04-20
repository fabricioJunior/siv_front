import 'dart:async';

import 'package:autenticacao/models.dart';
import 'package:autenticacao/uses_cases.dart';
import 'package:core/bloc.dart';
import 'package:core/equals.dart';
import 'package:core/injecoes.dart';
import 'package:core/sessao.dart';
import 'package:financeiro/use_cases.dart';

part 'app_state.dart';
part 'app_event.dart';

class AppBloc extends Bloc<AppEvent, AppState> implements IAcessoGlobalSessao {
  final OnAutenticado _onAutenticado;
  final OnDesautenticado _onDesautenticado;
  final EstaAutenticado _estaAutenticado;
  final Deslogar _deslogar;
  final RecuperarUsuarioDaSessao _recuperarUsuarioDaSessao;
  final RecuperarLicenciadoDaSessao _recuperarLicenciadoDaSessao;
  final RecuperarEmpresaDaSessao _recuperarEmpresaDaSessao;
  final RecuperarTerminalDaSessao _recuperarTerminalDaSessao;
  final RecuperarTerminaisDoUsuarioPorEmpresa
  _recuperarTerminaisDoUsuarioPorEmpresa;
  final SalvarTerminalDaSessao _salvarTerminalDaSessao;
  final SincronizarPermissoesDoUsuario _sincronizarPermissoesDoUsuario;
  final RecuperarCaixaAberto _recuperarCaixaAberto;

  final ApiBaseUrlConfig _apiBaseUrlConfig;

  late StreamSubscription<Token> _onAutenticacoSubscription;
  late StreamSubscription<Null> _onDesautenticadoSubscription;
  AppBloc(
    this._estaAutenticado,
    this._onAutenticado,
    this._deslogar,
    this._recuperarUsuarioDaSessao,
    this._onDesautenticado,
    this._recuperarLicenciadoDaSessao,
    this._recuperarEmpresaDaSessao,
    this._recuperarTerminalDaSessao,
    this._recuperarTerminaisDoUsuarioPorEmpresa,
    this._salvarTerminalDaSessao,
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
    on<AppSelecionouTerminalDaSessao>(_onSelecionouTerminalDaSessao);
    on<AppAtualizouCaixaDaSessao>(_onAtualizouCaixaDaSessao);
  }

  FutureOr<void> _onAppAutenticou(
    AppAutenticou event,
    Emitter<AppState> emit,
  ) async {
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
        idUsuario: usuarioDaSessao.id,
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
      final terminalDaSessaoResolvido = await _resolverTerminalDaSessao(
        empresaDaSessao: empresaDaSessao,
        terminaisDaEmpresaDaSessao: terminaisDaEmpresaDaSessao,
        terminalSalvo: terminalDaSessao,
      );
      if (event.token.idEmpresa != null) {
        _atualizarEtapaCarregamento(emit, 'Carregando caixa da sessão');
      }
      final caixaIdDaSessao = await _recuperarCaixaIdDaSessao(
        empresaDaSessao: empresaDaSessao,
        terminalDaSessao: terminalDaSessaoResolvido,
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
          terminalDaSessao: () => terminalDaSessaoResolvido,
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
      final terminalDaSessaoResolvido = await _resolverTerminalDaSessao(
        empresaDaSessao: empresaDaSessao,
        terminaisDaEmpresaDaSessao: terminaisDaEmpresaDaSessao,
        terminalSalvo: terminalDaSessao,
      );
      if (estaAutenticado) {
        _atualizarEtapaCarregamento(emit, 'Carregando caixa da sessão');
      }
      final caixaIdDaSessao = await _recuperarCaixaIdDaSessao(
        empresaDaSessao: empresaDaSessao,
        terminalDaSessao: terminalDaSessaoResolvido,
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
          terminalDaSessao: () => terminalDaSessaoResolvido,
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

  Future<TerminalDoUsuario?> _resolverTerminalDaSessao({
    required Empresa? empresaDaSessao,
    required List<TerminalDoUsuario> terminaisDaEmpresaDaSessao,
    required TerminalDoUsuario? terminalSalvo,
  }) async {
    if (empresaDaSessao == null) {
      return terminalSalvo;
    }

    if (terminaisDaEmpresaDaSessao.isEmpty) {
      return terminalSalvo?.idEmpresa == empresaDaSessao.id
          ? terminalSalvo
          : null;
    }

    if (terminalSalvo != null) {
      final terminalValido = terminaisDaEmpresaDaSessao.where(
        (t) => t.id == terminalSalvo.id,
      );
      if (terminalValido.isNotEmpty) {
        return terminalValido.first;
      }
    }

    final terminalSelecionado = terminaisDaEmpresaDaSessao.first;
    await _salvarTerminalDaSessao.call(terminalSelecionado);
    return terminalSelecionado;
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
    await _salvarTerminalDaSessao.call(event.terminal);
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
  int? get usuarioIdDaSessao => state.usuarioDaSessao?.id;

  @override
  int? get empresaIdDaSessao => state.empresaDaSessao?.id;

  @override
  int? get terminalIdDaSessao => state.terminalDaSessao?.id;

  @override
  String? get terminalNomeDaSessao => state.terminalDaSessao?.nome;

  @override
  int? get caixaIdDaSessao => state.caixaIdDaSessao;

  @override
  void atualizarCaixaIdDaSessao({required int terminalId, int? caixaId}) {
    add(AppAtualizouCaixaDaSessao(terminalId: terminalId, caixaId: caixaId));
  }

  @override
  Future<void> close() async {
    await _onAutenticacoSubscription.cancel();
    await _onDesautenticadoSubscription.cancel();
    return super.close();
  }
}
