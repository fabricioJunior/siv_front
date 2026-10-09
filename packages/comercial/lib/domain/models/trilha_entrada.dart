import 'package:comercial/domain/models/pedido_entrada.dart';
import 'package:core/equals.dart';

enum StatusPasso { ativo, concluido, atencao, futuro }

class PassoTrilha extends Equatable {
  final int indice;
  final String titulo;
  final StatusPasso status;
  final String subtitulo;

  const PassoTrilha({
    required this.indice,
    required this.titulo,
    required this.status,
    required this.subtitulo,
  });

  @override
  List<Object?> get props => [indice, titulo, status, subtitulo];
}

class ItemDiffEtiqueta extends Equatable {
  final int produtoId;
  final String descricao;
  final String grade;
  final double quantidade;

  const ItemDiffEtiqueta({
    required this.produtoId,
    required this.descricao,
    required this.grade,
    required this.quantidade,
  });

  @override
  List<Object?> get props => [produtoId, quantidade];
}

/// Diferença entre o contado atual e o que já foi etiquetado (3c/5j).
class DiffEtiquetas extends Equatable {
  final List<ItemDiffEtiqueta> imprimir;
  final List<ItemDiffEtiqueta> descartar;

  const DiffEtiquetas({this.imprimir = const [], this.descartar = const []});

  double get totalImprimir => imprimir.fold(0, (s, i) => s + i.quantidade);
  double get totalDescartar => descartar.fold(0, (s, i) => s + i.quantidade);
  bool get vazio => imprimir.isEmpty && descartar.isEmpty;

  @override
  List<Object?> get props => [imprimir, descartar];
}

const titulosDosPassos = [
  'Contar',
  'Associar',
  'Etiquetas',
  'Conferir',
  'Faturar',
];

String _qtd(double v) => v == v.roundToDouble() ? '${v.toInt()}' : '$v';

/// Estado da trilha de 5 passos, derivado do [EntradaResumo]. Se o backend não
/// mandar `etapa`/`etiquetas`/`conferencia`, deriva do que existe (contagens,
/// contagensLivres, pendências).
class TrilhaEntrada {
  const TrilhaEntrada._();

  static int _gruposLivres(EntradaResumo r) =>
      r.livresSemReferencia.map((c) => c.descricao).toSet().length;

  static int _variacoes(EntradaResumo r) => r.variacoesNovas.length;

  static bool _temContagem(EntradaResumo r) =>
      r.contagens.isNotEmpty || r.contagensLivres.isNotEmpty;

  static bool etiquetasConcluidas(EntradaResumo r, {bool local = false}) =>
      r.etiquetas.concluidas || local;

  /// 0..4 (4 = faturar; também quando já faturado).
  static int etapaAtual(EntradaResumo r, {bool etiquetasLocal = false}) {
    switch (r.etapa) {
      case 'faturado':
        return 4;
      case 'contando':
        return 0;
      case 'associando':
        return 1;
      case 'etiquetando':
        return etiquetasLocal ? 3 : 2;
      case 'conferindo':
        return 3;
    }
    if (!_temContagem(r)) return 0;
    if (r.contagensLivres.isNotEmpty) return 1;
    return etiquetasConcluidas(r, local: etiquetasLocal) ? 3 : 2;
  }

  static int divergenciasSemDecisao(EntradaResumo r) =>
      r.divergencias.where((d) => !d.decidida).length;

  /// Contagem livre bloqueia etiquetas (sem referência não há código de barras).
  static bool etiquetasBloqueadas(EntradaResumo r) =>
      r.contagensLivres.isNotEmpty || r.pendencias.isNotEmpty;

  static bool podeFaturar(EntradaResumo r) =>
      divergenciasSemDecisao(r) == 0 && (r.revisao.podeFaturar ?? true);

  static DiffEtiquetas diffEtiquetas(EntradaResumo r) {
    final impressas = r.etiquetas.impressasPorProduto;
    if (impressas.isEmpty) return const DiffEtiquetas();
    final imprimir = <ItemDiffEtiqueta>[];
    final descartar = <ItemDiffEtiqueta>[];
    final vistos = <int>{};
    for (final c in r.contagens) {
      vistos.add(c.produtoId);
      final dif = c.quantidade - (impressas[c.produtoId] ?? 0);
      if (dif == 0) continue;
      final item = ItemDiffEtiqueta(
        produtoId: c.produtoId,
        descricao: c.referenciaNome ?? 'Produto ${c.produtoId}',
        grade: [c.corNome, c.tamanhoNome]
            .whereType<String>()
            .where((e) => e.isNotEmpty)
            .join(' · '),
        quantidade: dif.abs(),
      );
      (dif > 0 ? imprimir : descartar).add(item);
    }
    for (final e in impressas.entries) {
      if (vistos.contains(e.key) || e.value <= 0) continue;
      final ci = r.conferencia.itens.where((i) => i.produtoId == e.key);
      descartar.add(
        ItemDiffEtiqueta(
          produtoId: e.key,
          descricao: ci.isEmpty ? 'Produto ${e.key}' : ci.first.descricao,
          grade: ci.isEmpty ? '' : ci.first.grade,
          quantidade: e.value,
        ),
      );
    }
    return DiffEtiquetas(imprimir: imprimir, descartar: descartar);
  }

  static List<PassoTrilha> trilha(
    EntradaResumo r, {
    required int passo,
    bool etiquetasLocal = false,
  }) {
    final etapa = etapaAtual(r, etiquetasLocal: etiquetasLocal);
    final faturado = r.etapa == 'faturado';
    final livres = _gruposLivres(r);
    final variacoes = _variacoes(r);
    final semDecisao = divergenciasSemDecisao(r);
    final etiquetas = etiquetasConcluidas(r, local: etiquetasLocal);
    final diff = diffEtiquetas(r);
    final contagemCorrigida =
        r.correcoes.where((c) => c.tipo == 'contagem').length;
    final conf = r.conferencia;
    final todasConferidas = conf.itens.isNotEmpty &&
        conf.itens.every((i) => i.situacao == SituacaoConferencia.conferido);

    final produtos = r.contagens.map((c) => c.referenciaId ?? c.produtoId).toSet().length + livres;
    final concluido = [
      _temContagem(r),
      _temContagem(r) && r.contagensLivres.isEmpty,
      etiquetas,
      todasConferidas || passo == 4 || faturado,
      faturado,
    ];

    final subtitulos = [
      !_temContagem(r)
          ? 'nada contado'
          : passo == 0 && etapa >= 2
              ? 'editando'
              : contagemCorrigida > 0
                  ? 'corrigida $contagemCorrigida×'
                  : '${_qtd(r.totalContado)} peças · $produtos produtos',
      livres > 0 && variacoes > 0
          ? '$livres sem referência · $variacoes variações'
          : livres > 0
          ? '$livres sem referência'
          : variacoes > 0
          ? (variacoes == 1 ? '1 variação a cadastrar' : '$variacoes variações a cadastrar')
          : _temContagem(r)
              ? 'tudo com referência'
              : 'após contar',
      etiquetasBloqueadas(r)
          ? 'após associar'
          : !diff.vazio
              ? '+${_qtd(diff.totalImprimir)} a imprimir · ${_qtd(diff.totalDescartar)} a descartar'
              : etiquetas
                  ? (r.etiquetas.puladas ? 'puladas' : 'impressas')
                  : '${_qtd(r.totalContado)} a imprimir',
      semDecisao > 0 && passo == 4
          ? '$semDecisao itens a decidir'
          : '${_qtd(conf.totalLido)} de ${_qtd(conf.totalContado > 0 ? conf.totalContado : r.totalContado)} peças',
      faturado ? 'faturado' : 'só peças conferidas',
    ];

    return [
      for (var i = 0; i < 5; i++)
        PassoTrilha(
          indice: i,
          titulo: titulosDosPassos[i],
          subtitulo: subtitulos[i],
          status: i == passo
              ? StatusPasso.ativo
              : (i == 1 && (livres > 0 || variacoes > 0) && passo > 1) ||
                      (i == 3 && semDecisao > 0 && passo == 4)
                  ? StatusPasso.atencao
                  : concluido[i]
                      ? StatusPasso.concluido
                      : StatusPasso.futuro,
        ),
    ];
  }
}
