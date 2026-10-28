import 'package:core/equals.dart';

/// Referência cadastrada antes da mercadoria chegar (aguardando 1ª entrada ou
/// reposição) do fornecedor da entrada. Só informa: nada aqui bloqueia a contagem.
class ReferenciaEsperada extends Equatable {
  final int id;
  final String nome;

  /// "Código no fornecedor" (idExterno da referência).
  final String? codigoNoFornecedor;
  final String? foto;
  final bool nova;
  final bool aguardandoPrimeiraEntrada;
  final bool aguardandoReposicao;
  final String resumoGrade;
  final int? quantidadeEsperada;

  const ReferenciaEsperada({
    required this.id,
    required this.nome,
    this.codigoNoFornecedor,
    this.foto,
    this.nova = false,
    this.aguardandoPrimeiraEntrada = false,
    this.aguardandoReposicao = false,
    this.resumoGrade = 'Sem variações',
    this.quantidadeEsperada,
  });

  factory ReferenciaEsperada.fromJson(Map<String, dynamic> json) {
    final status = ((json['status'] as List?) ?? const []).cast<String>();
    return ReferenciaEsperada(
      id: (json['id'] as num).toInt(),
      nome: json['nome'] as String? ?? 'Referência',
      codigoNoFornecedor: json['idExterno'] as String?,
      foto: json['foto'] as String?,
      nova: status.contains('nova'),
      aguardandoPrimeiraEntrada: status.contains('aguardandoPrimeiraEntrada'),
      aguardandoReposicao: status.contains('aguardandoReposicao'),
      resumoGrade: json['resumoGrade'] as String? ?? 'Sem variações',
      quantidadeEsperada: (json['quantidadeEsperada'] as num?)?.toInt(),
    );
  }

  @override
  List<Object?> get props => [
    id,
    nome,
    codigoNoFornecedor,
    foto,
    nova,
    aguardandoPrimeiraEntrada,
    aguardandoReposicao,
    resumoGrade,
    quantidadeEsperada,
  ];
}

/// Situação de uma esperada na lista de contagem.
enum SituacaoContagemEsperada { naoContada, parcial, completa, contada }

extension ReferenciaEsperadaContagem on ReferenciaEsperada {
  /// Contada = tem alguma peça contada nesta entrada. Com quantidade esperada:
  /// completa (>=) ou parcial (<); sem ela, só "contada".
  SituacaoContagemEsperada situacao(double contado) {
    if (contado <= 0) return SituacaoContagemEsperada.naoContada;
    final esperado = quantidadeEsperada;
    if (esperado == null) return SituacaoContagemEsperada.contada;
    return contado >= esperado
        ? SituacaoContagemEsperada.completa
        : SituacaoContagemEsperada.parcial;
  }
}

/// Ordem da lista: não contadas primeiro (por nome), contadas por último.
List<ReferenciaEsperada> ordenarEsperadas(
  List<ReferenciaEsperada> esperadas,
  Map<int, double> contadoPorReferencia,
) {
  final lista = [...esperadas];
  lista.sort((a, b) {
    final ca = (contadoPorReferencia[a.id] ?? 0) > 0 ? 1 : 0;
    final cb = (contadoPorReferencia[b.id] ?? 0) > 0 ? 1 : 0;
    if (ca != cb) return ca.compareTo(cb);
    return a.nome.toLowerCase().compareTo(b.nome.toLowerCase());
  });
  return lista;
}

const _acentos = {
  'á': 'a', 'à': 'a', 'â': 'a', 'ã': 'a', 'ä': 'a',
  'é': 'e', 'è': 'e', 'ê': 'e', 'ë': 'e',
  'í': 'i', 'ì': 'i', 'î': 'i', 'ï': 'i',
  'ó': 'o', 'ò': 'o', 'ô': 'o', 'õ': 'o', 'ö': 'o',
  'ú': 'u', 'ù': 'u', 'û': 'u', 'ü': 'u',
  'ç': 'c', 'ñ': 'n',
};

/// Minúsculas e sem acento, para a busca local ("Áurora" acha "aurora").
String semAcento(String texto) {
  final b = StringBuffer();
  for (final c in texto.toLowerCase().split('')) {
    b.write(_acentos[c] ?? c);
  }
  return b.toString();
}

/// Busca por nome, código no fornecedor ou REF, sem diferenciar acento.
bool esperadaCorresponde(ReferenciaEsperada e, String busca) {
  final termo = semAcento(busca.trim());
  if (termo.isEmpty) return true;
  return semAcento(e.nome).contains(termo) ||
      semAcento(e.codigoNoFornecedor ?? '').contains(termo) ||
      '${e.id}'.contains(termo);
}
