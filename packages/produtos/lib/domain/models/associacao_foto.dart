import 'package:produtos/domain/models/produto_da_grade.dart';
import 'package:produtos/domain/models/referencia_midia.dart';

const tamanhoTodos = '*';
const estampaLiso = 'Liso';
const limiteFotosPorReferencia = 20;

/// Cor, estampa e tamanho de uma foto, como texto (formato gravado na mídia).
class AssociacaoFoto {
  final String? cor;
  final String? estampa;
  final String? tamanho;

  const AssociacaoFoto({this.cor, this.estampa, this.tamanho});

  List<String> get faltas => [
    if ((cor ?? '').trim().isEmpty) 'cor',
    if ((estampa ?? '').trim().isEmpty) 'estampa',
    if ((tamanho ?? '').trim().isEmpty) 'tamanho',
  ];

  bool get completa => faltas.isEmpty;

  /// "Falta cor, estampa" ou null quando completa.
  String? get avisoFalta => completa ? null : 'Falta ${faltas.join(', ')}';

  /// "cor · estampa · tamanho" para exibição.
  String get resumo {
    final t = tamanho == tamanhoTodos ? 'Todos os tamanhos' : tamanho;
    return [cor, estampa, t].map((e) => (e ?? '').trim().isEmpty ? '—' : e).join(' · ');
  }

  AssociacaoFoto copyWith({String? cor, String? estampa, String? tamanho}) =>
      AssociacaoFoto(
        cor: cor ?? this.cor,
        estampa: estampa ?? this.estampa,
        tamanho: tamanho ?? this.tamanho,
      );

  /// Troca de cor invalida a estampa; pega-se a única opção quando houver.
  AssociacaoFoto comCor(String? novaCor, OpcoesAssociacaoFoto opcoes) =>
      opcoes.preencher(AssociacaoFoto(cor: novaCor, tamanho: tamanho));

  @override
  bool operator ==(Object other) =>
      other is AssociacaoFoto && other.cor == cor && other.estampa == estampa && other.tamanho == tamanho;

  @override
  int get hashCode => Object.hash(cor, estampa, tamanho);
}

extension AssociacaoDaMidia on ReferenciaMidia {
  AssociacaoFoto get associacao => AssociacaoFoto(cor: cor, estampa: estampa, tamanho: tamanho);
}

/// Opções permitidas para as fotos, extraídas só da grade da referência.
class OpcoesAssociacaoFoto {
  final List<ProdutoDaGrade> produtos;

  const OpcoesAssociacaoFoto(this.produtos);

  static String _estampa(ProdutoDaGrade p) => p.estampaNome ?? estampaLiso;

  List<String> get cores => {for (final p in produtos) p.corNome}.toList();

  List<String> estampasDaCor(String? cor) => {
    for (final p in produtos)
      if (cor == p.corNome) _estampa(p),
  }.toList();

  List<String> get tamanhos => {for (final p in produtos) p.tamanhoNome}.toList();

  /// Preenche automaticamente os campos que só têm uma opção.
  AssociacaoFoto preencher(AssociacaoFoto a) {
    var cor = a.cor;
    if (cor == null && cores.length == 1) cor = cores.first;
    var estampa = a.estampa;
    final estampas = estampasDaCor(cor);
    if (estampa == null || !estampas.contains(estampa)) {
      estampa = estampas.length == 1 ? estampas.first : null;
    }
    var tamanho = a.tamanho;
    if (tamanho == null && tamanhos.length == 1) tamanho = tamanhos.first;
    return AssociacaoFoto(cor: cor, estampa: estampa, tamanho: tamanho);
  }

  /// Verdadeiro se a combinação existe na grade (tamanho aceita '*').
  bool valida(AssociacaoFoto a) =>
      a.completa &&
      estampasDaCor(a.cor).contains(a.estampa) &&
      (a.tamanho == tamanhoTodos || tamanhos.contains(a.tamanho));
}

/// Nome de arquivo para download: nome-da-referencia-cor-estampa-N.jpg
String nomeArquivoFoto(String referencia, AssociacaoFoto a, int n) {
  String slug(String? t) => (t ?? '')
      .toLowerCase()
      .replaceAll(RegExp(r'[áàâãä]'), 'a')
      .replaceAll(RegExp(r'[éèêë]'), 'e')
      .replaceAll(RegExp(r'[íìîï]'), 'i')
      .replaceAll(RegExp(r'[óòôõö]'), 'o')
      .replaceAll(RegExp(r'[úùûü]'), 'u')
      .replaceAll('ç', 'c')
      .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
      .replaceAll(RegExp(r'^-+|-+$'), '');
  return [referencia, a.cor, a.estampa, '$n'].map(slug).where((e) => e.isNotEmpty).join('-') + '.jpg';
}
