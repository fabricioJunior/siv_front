import 'dart:async';

import 'package:core/bloc.dart';
import 'package:core/equals.dart';
import 'package:core/paginacao/paginacao.dart';
import 'package:estoque/estoque.dart';
import 'package:produtos/domain/use_cases/sincronizar_codigos.dart';
import 'package:siv_front/presentation/bloc/app_bloc/app_bloc.dart';

part 'sync_data_event.dart';
part 'sync_data_state.dart';

class SyncDataBloc extends Bloc<SyncDataEvent, SyncDataState> {
  final SincronizarCodigos _sincronizarCodigos;
  final SincronizarEstoque _sincronizarEstoque;
  final AppBloc _appBloc;

  StreamSubscription<Paginacao>? _codigosSubscription;
  StreamSubscription<Paginacao>? _estoqueSubscription;

  SyncDataBloc(
    this._sincronizarCodigos,
    this._sincronizarEstoque,
    this._appBloc,
  ) : super(const SyncDataState()) {
    on<SyncDataSolicitouSincronizacao>(_onSolicitouSincronizacao);
    on<SyncDataAtualizacaoRecebida>(_onAtualizacaoRecebida);
    on<SyncDataModuloConcluido>(_onModuloConcluido);
    on<SyncDataModuloFalhou>(_onModuloFalhou);
  }

  FutureOr<void> _onSolicitouSincronizacao(
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

    final modulosEmSincronizacao = <SyncModulo, SyncModuloState>{
      for (final modulo in state.modulos.entries)
        modulo.key: modulo.value.copyWith(
          status: SyncModuloStatus.sincronizando,
          erro: null,
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

    _iniciarSincronizacaoCodigos();
    _iniciarSincronizacaoEstoque();
  }

  FutureOr<void> _onAtualizacaoRecebida(
    SyncDataAtualizacaoRecebida event,
    Emitter<SyncDataState> emit,
  ) {
    final modulo = state.modulos[event.modulo]!;
    final houveProcessamentoNaPagina =
        event.paginacao.itensProcessadosNaPagina > 0;
    final paginasSincronizadas = houveProcessamentoNaPagina
        ? (modulo.paginasSincronizadas + 1)
            .clamp(0, event.paginacao.totalPaginas)
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

  FutureOr<void> _onModuloConcluido(
    SyncDataModuloConcluido event,
    Emitter<SyncDataState> emit,
  ) {
    final modulo = state.modulos[event.modulo]!;

    // Preserve failure on UI if this module has already failed.
    if (modulo.status != SyncModuloStatus.falha) {
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
    }
  }

  FutureOr<void> _onModuloFalhou(
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
        state.modulos.values
            .every((modulo) => modulo.status != SyncModuloStatus.falha);
  }

  Future<void> _cancelarSincronizacoesAtivas() async {
    await _codigosSubscription?.cancel();
    await _estoqueSubscription?.cancel();
    _codigosSubscription = null;
    _estoqueSubscription = null;
  }

  @override
  Future<void> close() async {
    await _cancelarSincronizacoesAtivas();
    return super.close();
  }
}
