import 'dart:async';

import 'package:core/bloc.dart';
import 'package:core/equals.dart';
import 'package:core/paginacao/paginacao.dart';
import 'package:core/permissoes/i_permissoes_controller.dart';
import 'package:estoque/estoque.dart';
import 'package:precos/use_cases.dart';
import 'package:produtos/domain/use_cases/sincronizar_codigos.dart';
import 'package:siv_front/presentation/bloc/app_bloc/app_bloc.dart';

part 'sync_data_event.dart';
part 'sync_data_state.dart';

class SyncDataBloc extends Bloc<SyncDataEvent, SyncDataState> {
  final SincronizarCodigos _sincronizarCodigos;
  final SincronizarEstoque _sincronizarEstoque;
  final SincronziarTabelasDePreco _sincronizarTabelasDePreco;
  final SincronizarPrecos _sincronizarPrecos;
  final AppBloc _appBloc;
  final IPermissoesController _permissoesController;

  StreamSubscription<Paginacao>? _codigosSubscription;
  StreamSubscription<Paginacao>? _estoqueSubscription;
  StreamSubscription<Paginacao>? _tabelasDePrecoSubscription;
  StreamSubscription<Paginacao>? _precosDaReferenciaSubscription;

  SyncDataBloc(
    this._sincronizarCodigos,
    this._sincronizarEstoque,
    this._sincronizarTabelasDePreco,
    this._sincronizarPrecos,
    this._appBloc,
    this._permissoesController,
  ) : super(const SyncDataState()) {
    on<SyncDataSolicitouSincronizacao>(_onSolicitouSincronizacao);
    on<SyncDataAtualizacaoRecebida>(_onAtualizacaoRecebida);
    on<SyncDataModuloConcluido>(_onModuloConcluido);
    on<SyncDataModuloFalhou>(_onModuloFalhou);
  }

  Future<void> _onSolicitouSincronizacao(
    SyncDataSolicitouSincronizacao event,
    Emitter<SyncDataState> emit,
  ) async {
    if (!_usuarioAutenticadoComEmpresa()) {
      return;
    }

    if (_sincronizacaoEmAndamentoSemErros()) {
      return;
    }

    if (event.origem == SyncDataOrigem.home && state.homeJaSincronizada) {
      return;
    }

    await _cancelarSincronizacoesAtivas();

    final modulosPermitidos = _resolverModulosPermitidos();

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
        modulos: modulosEmSincronizacao,
      ),
    );

    if (modulosPermitidos.contains(SyncModulo.codigos)) {
      _iniciarSincronizacaoCodigos();
    }
    if (modulosPermitidos.contains(SyncModulo.estoque)) {
      _iniciarSincronizacaoEstoque();
    }
    if (modulosPermitidos.contains(SyncModulo.tabelasDePreco)) {
      _iniciarSincronizacaoTabelasDePreco();
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
      if (!_resolverModulosPermitidos().contains(
        SyncModulo.precosDaReferencia,
      )) {
        return;
      }
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

  bool _usuarioAutenticadoComEmpresa() {
    final appState = _appBloc.state;
    return appState.statusAutenticacao == StatusAutenticacao.autenticado &&
        appState.empresaDaSessao != null;
  }

  bool _sincronizacaoEmAndamentoSemErros() {
    return state.sincronizando &&
        state.modulos.values.every(
          (modulo) => modulo.status != SyncModuloStatus.falha,
        );
  }

  Set<SyncModulo> _resolverModulosPermitidos() {
    final permitidos = <SyncModulo>{};

    if (_temAcessoAAlgumComponente(const [
      'PRDFM001',
      'PRDFM003',
      'PRDFM004',
      'PRDFM005',
      'PRDFM006',
      'PRDFM007',
      'PRDFM010',
      'PRDFM011',
    ])) {
      permitidos.add(SyncModulo.codigos);
    }

    if (_temAcessoAAlgumComponente(const [
      'PRDFL001',
      'BALFP001',
      'BALFP002',
      'BALFP003',
      'BALFP004',
    ])) {
      permitidos.add(SyncModulo.estoque);
    }

    if (_temAcessoAAlgumComponente(const ['PRDFM010'])) {
      permitidos.add(SyncModulo.tabelasDePreco);
    }

    if (_temAcessoAAlgumComponente(const ['PRDFM011'])) {
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

  bool _temAcessoAAlgumComponente(List<String> componentes) {
    for (final componente in componentes) {
      if (_permissoesController.temAcesso(idComponente: componente)) {
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
    return super.close();
  }
}
