import 'dart:async';

import 'package:comercial/models.dart';
import 'package:comercial/use_cases.dart';
import 'package:core/bloc.dart';
import 'package:core/equals.dart';
import 'package:core/remote_data_sourcers.dart' show mensagemDeErroApi;

part 'ecommerce_vitrine_event.dart';
part 'ecommerce_vitrine_state.dart';

class EcommerceVitrineBloc extends Bloc<EcommerceVitrineEvent, EcommerceVitrineState> {
  final RecuperarVitrineEcommerce _recuperar;
  final SalvarVitrineEcommerce _salvar;
  final ListarListasPersonalizadas _listarListas;
  final ListarListasGrupos _listarGrupos;

  EcommerceVitrineBloc(
    this._recuperar,
    this._salvar,
    this._listarListas,
    this._listarGrupos,
  ) : super(const EcommerceVitrineState()) {
    on<EcommerceVitrineIniciou>(_onIniciou);
    on<EcommerceVitrineItemAdicionou>(_onAdicionou);
    on<EcommerceVitrineItemRemoveu>(_onRemoveu);
    on<EcommerceVitrineItemMoveu>(_onMoveu);
    on<EcommerceVitrineSalvou>(_onSalvou);
  }

  Future<void> _onIniciou(
    EcommerceVitrineIniciou event,
    Emitter<EcommerceVitrineState> emit,
  ) async {
    emit(
      state.copyWith(
        step: EcommerceVitrineStep.carregando,
        ecommerceId: event.ecommerceId,
        erro: '',
      ),
    );
    try {
      final resultados = await Future.wait([
        _recuperar.call(event.ecommerceId),
        _listarListas.call(limit: 100, tipo: ListaTipo.catalogo),
        _listarGrupos.call(limit: 100),
      ]);
      emit(
        state.copyWith(
          step: EcommerceVitrineStep.pronto,
          vitrine: resultados[0] as EcommerceVitrine,
          listas: (resultados[1] as PaginaListasPersonalizadas).items,
          grupos: (resultados[2] as PaginaListasGrupos).items,
        ),
      );
    } catch (e, s) {
      emit(
        state.copyWith(
          step: EcommerceVitrineStep.falha,
          erro: mensagemDeErroApi(e, 'Falha ao carregar a vitrine.'),
        ),
      );
      addError(e, s);
    }
  }

  List<EcommerceVitrineItem> _renumerar(List<EcommerceVitrineItem> itens) =>
      [for (var i = 0; i < itens.length; i++) itens[i].comOrdem(i)];

  void _atualizarLocal(
    Emitter<EcommerceVitrineState> emit,
    VitrineLocal local,
    List<EcommerceVitrineItem> itens,
  ) {
    final v = state.vitrine;
    final novos = _renumerar(itens);
    emit(
      state.copyWith(
        vitrine: local == VitrineLocal.menu
            ? EcommerceVitrine(menu: novos, home: v.home)
            : EcommerceVitrine(menu: v.menu, home: novos),
        erro: '',
      ),
    );
  }

  bool _mesmo(EcommerceVitrineItem i, VitrineItemTipo tipo, int id) =>
      i.tipo == tipo && i.itemId == id;

  void _onAdicionou(
    EcommerceVitrineItemAdicionou event,
    Emitter<EcommerceVitrineState> emit,
  ) {
    // Home só aceita lista (contrato).
    if (event.local == VitrineLocal.home && event.tipo == VitrineItemTipo.grupo) return;
    final atual = state.vitrine.doLocal(event.local);
    if (atual.any((i) => _mesmo(i, event.tipo, event.itemId))) return;

    final String nome;
    final String? icone;
    if (event.tipo == VitrineItemTipo.lista) {
      final l = state.listas.where((x) => x.id == event.itemId).firstOrNull;
      if (l == null) return;
      nome = l.titulo?.isNotEmpty == true ? l.titulo! : l.hash;
      icone = l.icone;
    } else {
      final g = state.grupos.where((x) => x.id == event.itemId).firstOrNull;
      if (g == null) return;
      nome = g.nome;
      icone = g.icone;
    }
    _atualizarLocal(emit, event.local, [
      ...atual,
      EcommerceVitrineItem(
        tipo: event.tipo,
        itemId: event.itemId,
        ordem: atual.length,
        nome: nome,
        icone: icone,
      ),
    ]);
  }

  void _onRemoveu(
    EcommerceVitrineItemRemoveu event,
    Emitter<EcommerceVitrineState> emit,
  ) {
    _atualizarLocal(
      emit,
      event.local,
      state.vitrine
          .doLocal(event.local)
          .where((i) => !_mesmo(i, event.tipo, event.itemId))
          .toList(),
    );
  }

  void _onMoveu(
    EcommerceVitrineItemMoveu event,
    Emitter<EcommerceVitrineState> emit,
  ) {
    final itens = [...state.vitrine.doLocal(event.local)];
    final de = itens.indexWhere((i) => _mesmo(i, event.tipo, event.itemId));
    if (de < 0) return;
    final para = event.indice.clamp(0, itens.length - 1);
    if (para == de) return;
    itens.insert(para, itens.removeAt(de));
    _atualizarLocal(emit, event.local, itens);
  }

  Future<void> _onSalvou(
    EcommerceVitrineSalvou event,
    Emitter<EcommerceVitrineState> emit,
  ) async {
    final id = state.ecommerceId;
    if (id == null) return;
    emit(state.copyWith(salvando: event.local, erro: ''));
    try {
      await _salvar.call(id, event.local, state.vitrine.doLocal(event.local));
      emit(state.copyWith(limparSalvando: true, ultimoSalvo: event.local));
    } catch (e, s) {
      emit(
        state.copyWith(
          limparSalvando: true,
          erro: mensagemDeErroApi(e, 'Falha ao salvar a vitrine.'),
        ),
      );
      addError(e, s);
    }
  }
}
