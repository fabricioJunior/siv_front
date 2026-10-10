import 'dart:async';

import 'package:comercial/models.dart';
import 'package:comercial/use_cases.dart';
import 'package:core/bloc.dart';
import 'package:core/equals.dart';
import 'package:core/remote_data_sourcers.dart' show mensagemDeErroApi;

part 'ecommerce_vitrine_event.dart';
part 'ecommerce_vitrine_state.dart';

class EcommerceVitrineBloc
    extends Bloc<EcommerceVitrineEvent, EcommerceVitrineState> {
  final RecuperarVitrineEcommerce _recuperar;
  final SalvarVitrineEcommerce _salvar;
  final ListarListasPersonalizadas _listarListas;
  final ListarListasGrupos _listarGrupos;
  final RecuperarListaGrupo _recuperarGrupo;

  EcommerceVitrineBloc(
    this._recuperar,
    this._salvar,
    this._listarListas,
    this._listarGrupos,
    this._recuperarGrupo,
  ) : super(const EcommerceVitrineState()) {
    on<EcommerceVitrineIniciou>(_onIniciou);
    on<EcommerceVitrineItemAdicionou>(_onAdicionou);
    on<EcommerceVitrineItemRemoveu>(_onRemoveu);
    on<EcommerceVitrineItemMoveu>(_onMoveu);
    on<EcommerceVitrineItensAdicionou>(_onItensAdicionou);
    on<EcommerceVitrinePublicou>(_onPublicou);
    on<EcommerceVitrineDescartou>(_onDescartou);
    on<EcommerceVitrineRecarregouCatalogo>(_onRecarregouCatalogo);
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
        _todasListas(),
        _todosGrupos(),
      ]);
      final vitrine = resultados[0] as EcommerceVitrine;
      final grupos =
          await _comListasDosGrupos(resultados[2] as List<ListaGrupo>);
      emit(
        state.copyWith(
          step: EcommerceVitrineStep.pronto,
          vitrine: vitrine,
          publicada: vitrine,
          listas: resultados[1] as List<ListaPersonalizadaResumo>,
          grupos: grupos,
          limparPublicadoEm: true,
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

  // Só o acervo: a vitrine em edição e o que já foi publicado continuam como estão.
  Future<void> _onRecarregouCatalogo(
    EcommerceVitrineRecarregouCatalogo event,
    Emitter<EcommerceVitrineState> emit,
  ) async {
    if (state.step != EcommerceVitrineStep.pronto) return;
    try {
      final resultados = await Future.wait([_todasListas(), _todosGrupos()]);
      final grupos =
          await _comListasDosGrupos(resultados[1] as List<ListaGrupo>);
      emit(
        state.copyWith(
          listas: resultados[0] as List<ListaPersonalizadaResumo>,
          grupos: grupos,
        ),
      );
    } catch (e, s) {
      // Falhar aqui não pode derrubar a tela: segue com o acervo que já estava em memória.
      addError(e, s);
    }
  }

  Future<List<ListaPersonalizadaResumo>> _todasListas() async {
    final todas = <ListaPersonalizadaResumo>[];
    var page = 1;
    int total;
    do {
      final p = await _listarListas.call(
          page: page, limit: 100, tipo: ListaTipo.catalogo);
      todas.addAll(p.items);
      total = p.meta.totalPages;
      page++;
    } while (page <= total);
    return todas;
  }

  Future<List<ListaGrupo>> _todosGrupos() async {
    final todos = <ListaGrupo>[];
    var page = 1;
    int total;
    do {
      final p = await _listarGrupos.call(page: page, limit: 100);
      todos.addAll(p.items);
      total = p.totalPages;
      page++;
    } while (page <= total);
    return todos;
  }

  /// A listagem de grupos pode vir sem as listas; completa pelo detalhe
  /// (necessárias para duplicidade e "onde aparece").
  Future<List<ListaGrupo>> _comListasDosGrupos(List<ListaGrupo> grupos) =>
      Future.wait([
        for (final g in grupos)
          g.listas.isEmpty ? _detalhe(g) : Future.value(g),
      ]);

  Future<ListaGrupo> _detalhe(ListaGrupo g) async {
    try {
      return await _recuperarGrupo.call(g.id);
    } catch (_) {
      return g;
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
        limparPublicadoEm: true,
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
    if (event.local == VitrineLocal.home && event.tipo == VitrineItemTipo.grupo)
      return;
    final atual = state.vitrine.doLocal(event.local);
    if (atual.any((i) => _mesmo(i, event.tipo, event.itemId))) return;

    final novo = _novoItem(event.tipo, event.itemId, atual.length);
    if (novo == null) return;
    _atualizarLocal(emit, event.local, [...atual, novo]);
  }

  EcommerceVitrineItem? _novoItem(VitrineItemTipo tipo, int itemId, int ordem) {
    if (tipo == VitrineItemTipo.lista) {
      final l = state.listas.where((x) => x.id == itemId).firstOrNull;
      if (l == null) return null;
      return EcommerceVitrineItem(
        tipo: tipo,
        itemId: itemId,
        ordem: ordem,
        nome: l.titulo?.isNotEmpty == true ? l.titulo! : l.hash,
        icone: l.icone,
        situacao: l.situacao.name,
      );
    }
    final g = state.grupos.where((x) => x.id == itemId).firstOrNull;
    if (g == null) return null;
    return EcommerceVitrineItem(
      tipo: tipo,
      itemId: itemId,
      ordem: ordem,
      nome: g.nome,
      icone: g.icone,
    );
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

  void _onItensAdicionou(
    EcommerceVitrineItensAdicionou event,
    Emitter<EcommerceVitrineState> emit,
  ) {
    final itens = [...state.vitrine.doLocal(event.local)];
    for (final ref in event.itens) {
      // Home só aceita lista (contrato).
      if (event.local == VitrineLocal.home && ref.tipo == VitrineItemTipo.grupo)
        continue;
      if (itens.any((i) => _mesmo(i, ref.tipo, ref.itemId))) continue;
      final novo = _novoItem(ref.tipo, ref.itemId, itens.length);
      if (novo != null) itens.add(novo);
    }
    if (itens.length == state.vitrine.doLocal(event.local).length) return;
    _atualizarLocal(emit, event.local, itens);
  }

  Future<void> _onPublicou(
    EcommerceVitrinePublicou event,
    Emitter<EcommerceVitrineState> emit,
  ) async {
    final id = state.ecommerceId;
    if (id == null || state.publicando) return;
    emit(state.copyWith(publicando: true));
    var publicada = state.publicada;
    String? erro;
    Object? falha;
    StackTrace? pilha;
    for (final local in VitrineLocal.values) {
      if (!state.localAlterado(local)) continue;
      final itens = state.vitrine.doLocal(local);
      try {
        await _salvar.call(id, local, itens);
        publicada = local == VitrineLocal.menu
            ? EcommerceVitrine(menu: itens, home: publicada.home)
            : EcommerceVitrine(menu: publicada.menu, home: itens);
      } catch (e, s) {
        falha = e;
        pilha = s;
        erro = mensagemDeErroApi(e, 'Falha ao publicar a vitrine.');
        break;
      }
    }
    emit(
      state.copyWith(
        publicando: false,
        publicada: publicada,
        publicadoEm: erro == null ? DateTime.now() : null,
        erro: erro,
      ),
    );
    if (falha != null) addError(falha, pilha);
  }

  void _onDescartou(
    EcommerceVitrineDescartou event,
    Emitter<EcommerceVitrineState> emit,
  ) =>
      emit(state.copyWith(vitrine: state.publicada, limparPublicadoEm: true));
}
