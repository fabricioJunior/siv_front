part of 'ecommerce_vitrine_bloc.dart';

enum EcommerceVitrineStep { inicial, carregando, pronto, falha }

class EcommerceVitrineState extends Equatable {
  final EcommerceVitrineStep step;
  final int? ecommerceId;

  /// Rascunho (o que está na tela).
  final EcommerceVitrine vitrine;

  /// Versão no site.
  final EcommerceVitrine publicada;
  final List<ListaPersonalizadaResumo> listas;
  final List<ListaGrupo> grupos;
  final bool publicando;
  final DateTime? publicadoEm;
  final String? erro;

  const EcommerceVitrineState({
    this.step = EcommerceVitrineStep.inicial,
    this.ecommerceId,
    this.vitrine = const EcommerceVitrine(),
    this.publicada = const EcommerceVitrine(),
    this.listas = const [],
    this.grupos = const [],
    this.publicando = false,
    this.publicadoEm,
    this.erro,
  });

  static bool _mesmaOrdem(
      List<EcommerceVitrineItem> a, List<EcommerceVitrineItem> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i].tipo != b[i].tipo || a[i].itemId != b[i].itemId) return false;
    }
    return true;
  }

  static int _diff(List<EcommerceVitrineItem> a, List<EcommerceVitrineItem> b) {
    var n = 0;
    final max = a.length > b.length ? a.length : b.length;
    for (var i = 0; i < max; i++) {
      final x = i < a.length ? a[i] : null;
      final y = i < b.length ? b[i] : null;
      if (x?.tipo != y?.tipo || x?.itemId != y?.itemId) n++;
    }
    return n;
  }

  bool localAlterado(VitrineLocal l) =>
      !_mesmaOrdem(vitrine.doLocal(l), publicada.doLocal(l));

  /// Posições diferentes do publicado, somando Menu e Home.
  int get alteracoesPendentes =>
      _diff(vitrine.menu, publicada.menu) + _diff(vitrine.home, publicada.home);

  List<ListaGrupo> get _gruposNoMenu {
    final ids = {
      for (final i in vitrine.menu)
        if (i.tipo == VitrineItemTipo.grupo) i.itemId,
    };
    return grupos.where((g) => ids.contains(g.id)).toList();
  }

  /// Grupo do menu (rascunho) que contém a lista, se houver.
  String? grupoDoMenuQueContem(int listaId) {
    for (final g in _gruposNoMenu) {
      if (g.listas.any((l) => l.listaId == listaId)) return g.nome;
    }
    return null;
  }

  /// listaId -> nome do grupo, para listas no menu direto que também estão
  /// dentro de um grupo do menu.
  Map<int, String> get duplicidades => {
        for (final i in vitrine.menu)
          if (i.tipo == VitrineItemTipo.lista &&
              grupoDoMenuQueContem(i.itemId) != null)
            i.itemId: grupoDoMenuQueContem(i.itemId)!,
      };

  /// Onde a lista aparece no site hoje (versão publicada), ex.: "Menu › Feminino · 2º".
  List<String> ondeAparece(int listaId) {
    final r = <String>[];
    for (var n = 0; n < publicada.menu.length; n++) {
      final i = publicada.menu[n];
      if (i.tipo == VitrineItemTipo.lista && i.itemId == listaId) {
        r.add('Menu · ${n + 1}º');
      } else if (i.tipo == VitrineItemTipo.grupo) {
        final g = grupos.where((x) => x.id == i.itemId).firstOrNull;
        if (g == null) continue;
        final ordenadas = [...g.listas]
          ..sort((a, b) => a.ordem.compareTo(b.ordem));
        final pos = ordenadas.indexWhere((l) => l.listaId == listaId);
        if (pos >= 0) r.add('Menu › ${g.nome} · ${pos + 1}º');
      }
    }
    for (var n = 0; n < publicada.home.length; n++) {
      final i = publicada.home[n];
      if (i.tipo == VitrineItemTipo.lista && i.itemId == listaId)
        r.add('Home · ${n + 1}º');
    }
    return r;
  }

  EcommerceVitrineState copyWith({
    EcommerceVitrineStep? step,
    int? ecommerceId,
    EcommerceVitrine? vitrine,
    EcommerceVitrine? publicada,
    List<ListaPersonalizadaResumo>? listas,
    List<ListaGrupo>? grupos,
    bool? publicando,
    DateTime? publicadoEm,
    bool limparPublicadoEm = false,
    String? erro,
  }) =>
      EcommerceVitrineState(
        step: step ?? this.step,
        ecommerceId: ecommerceId ?? this.ecommerceId,
        vitrine: vitrine ?? this.vitrine,
        publicada: publicada ?? this.publicada,
        listas: listas ?? this.listas,
        grupos: grupos ?? this.grupos,
        publicando: publicando ?? this.publicando,
        publicadoEm:
            limparPublicadoEm ? null : (publicadoEm ?? this.publicadoEm),
        erro: erro,
      );

  @override
  List<Object?> get props => [
        step,
        ecommerceId,
        vitrine,
        publicada,
        listas,
        grupos,
        publicando,
        publicadoEm,
        erro,
      ];
}
