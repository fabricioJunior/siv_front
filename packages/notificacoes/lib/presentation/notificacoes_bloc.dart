import 'dart:async';

import 'package:core/bloc.dart';
import 'package:core/sync.dart';
import 'package:notificacoes/domain/notificacao.dart';
import 'package:notificacoes/domain/use_cases.dart';

class NotificacoesState {
  final List<Notificacao> lista;
  final int naoLidas;
  final bool carregando;
  final String? erro;

  const NotificacoesState({
    this.lista = const [],
    this.naoLidas = 0,
    this.carregando = false,
    this.erro,
  });

  NotificacoesState copyWith({
    List<Notificacao>? lista,
    int? naoLidas,
    bool? carregando,
    String? erro,
  }) => NotificacoesState(
    lista: lista ?? this.lista,
    naoLidas: naoLidas ?? this.naoLidas,
    carregando: carregando ?? this.carregando,
    erro: erro,
  );
}

sealed class NotificacoesEvent {}

/// Busca as não lidas (carga inicial e catch-up após reconexão).
class NotificacoesRecarregou extends NotificacoesEvent {}

class NotificacaoRecebida extends NotificacoesEvent {
  final Notificacao notificacao;
  NotificacaoRecebida(this.notificacao);
}

class NotificacaoMarcouLida extends NotificacoesEvent {
  final int id;
  NotificacaoMarcouLida(this.id);
}

class NotificacoesMarcouTodasLidas extends NotificacoesEvent {}

class NotificacoesLimpou extends NotificacoesEvent {}

typedef ExibirNotificacao =
    Future<void> Function({required String titulo, required String corpo});

class NotificacoesBloc extends Bloc<NotificacoesEvent, NotificacoesState> {
  final ListarNotificacoesNaoLidas _listar;
  final ContarNotificacoesNaoLidas _contar;
  final MarcarNotificacaoLida _marcarLida;
  final MarcarTodasNotificacoesLidas _marcarTodas;
  final ExibirNotificacao _exibir;
  final _subs = <StreamSubscription<dynamic>>[];

  // Ids já avisados no sistema nesta sessão -- evita aviso duplo entre o
  // evento em tempo real e o catch-up.
  final _exibidas = <int>{};
  bool _jaCarregou = false;

  NotificacoesBloc(
    this._listar,
    this._contar,
    this._marcarLida,
    this._marcarTodas,
    this._exibir, {
    required Stream<NotificacaoEvent> novas,
    required Stream<bool> conectado,
    required Stream<void> desautenticado,
  }) : super(const NotificacoesState()) {
    on<NotificacoesRecarregou>(_onRecarregou);
    on<NotificacaoRecebida>(_onRecebida);
    on<NotificacaoMarcouLida>(_onMarcouLida);
    on<NotificacoesMarcouTodasLidas>(_onMarcouTodas);
    on<NotificacoesLimpou>((_, emit) {
      _exibidas.clear();
      _jaCarregou = false;
      emit(const NotificacoesState());
    });

    _subs
      ..add(
        novas.listen(
          (e) => add(NotificacaoRecebida(Notificacao.fromJson(e.json))),
        ),
      )
      ..add(
        conectado.listen((c) {
          if (c) add(NotificacoesRecarregou());
        }),
      )
      ..add(desautenticado.listen((_) => add(NotificacoesLimpou())));
    add(NotificacoesRecarregou());
  }

  Future<void> _onRecarregou(
    NotificacoesRecarregou event,
    Emitter<NotificacoesState> emit,
  ) async {
    emit(state.copyWith(carregando: true));
    try {
      final lista = await _listar();
      final total = await _contar();
      // Primeira carga é silenciosa (só marca como vistas); depois dela,
      // o que apareceu e ainda não foi avisado é avisado.
      final avisar = _jaCarregou;
      _jaCarregou = true;
      for (final n in lista.reversed) {
        if (_exibidas.add(n.id) && avisar) _avisar(n);
      }
      emit(NotificacoesState(lista: lista, naoLidas: total));
    } catch (e) {
      emit(state.copyWith(carregando: false, erro: e.toString()));
    }
  }

  void _onRecebida(NotificacaoRecebida event, Emitter<NotificacoesState> emit) {
    final n = event.notificacao;
    if (_exibidas.add(n.id)) _avisar(n);
    if (state.lista.any((x) => x.id == n.id)) return;
    emit(
      state.copyWith(lista: [n, ...state.lista], naoLidas: state.naoLidas + 1),
    );
  }

  Future<void> _onMarcouLida(
    NotificacaoMarcouLida event,
    Emitter<NotificacoesState> emit,
  ) async {
    final existia = state.lista.any((x) => x.id == event.id);
    emit(
      state.copyWith(
        lista: state.lista.where((x) => x.id != event.id).toList(),
        naoLidas: existia && state.naoLidas > 0
            ? state.naoLidas - 1
            : state.naoLidas,
      ),
    );
    try {
      await _marcarLida(event.id);
    } catch (e) {
      emit(state.copyWith(erro: e.toString()));
      add(NotificacoesRecarregou());
    }
  }

  Future<void> _onMarcouTodas(
    NotificacoesMarcouTodasLidas event,
    Emitter<NotificacoesState> emit,
  ) async {
    emit(state.copyWith(lista: const [], naoLidas: 0));
    try {
      await _marcarTodas();
    } catch (e) {
      emit(state.copyWith(erro: e.toString()));
      add(NotificacoesRecarregou());
    }
  }

  void _avisar(Notificacao n) => unawaited(_exibir(titulo: n.titulo, corpo: n.corpo));

  @override
  Future<void> close() {
    for (final s in _subs) {
      s.cancel();
    }
    return super.close();
  }
}
