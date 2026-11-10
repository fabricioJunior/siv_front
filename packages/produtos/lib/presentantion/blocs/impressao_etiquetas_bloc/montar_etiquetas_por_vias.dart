import 'package:produtos/models.dart';
import 'package:produtos/use_cases.dart';

/// Uma etiqueta fisica a imprimir (um item da fila, antes de distribuir nas vias).
class RequisicaoEtiqueta {
  final double preco;
  final String descricao;
  final String cor;
  // Cor + estampa separados por ' · ', só pra exibição na tela/pilha; o ZPL recebe [cor] ("COR ESTAMPA").
  final String corExibicao;
  final String tamanho;
  final String codigoBarras;

  const RequisicaoEtiqueta({
    required this.preco,
    required this.descricao,
    required this.cor,
    required this.corExibicao,
    required this.tamanho,
    required this.codigoBarras,
  });
}

/// Distribui as [requisicoes] nas vias da [etiqueta] e gera o ZPL de cada uma.
/// Pre-condicao: [etiqueta] tem ao menos uma via.
List<EtiquetaImpressaoItem> montarEtiquetasPorVias({
  required Etiqueta etiqueta,
  required List<RequisicaoEtiqueta> requisicoes,
  required String titulo,
  required ProcessarEtiquetaParaImpressao processar,
}) {
  final viasOrdenadas = [...etiqueta.vias]
    ..sort((a, b) => a.ordem.compareTo(b.ordem));
  final limitesCaracteres = <String, int>{
    for (final elemento in etiqueta.elementos)
      if (elemento.limiteCaracteres != null)
        elemento.nome: elemento.limiteCaracteres!,
  };
  final novosItens = <EtiquetaImpressaoItem>[];

  // "Vias" sao COLUNAS de uma mesma linha fisica impressa (MesclaEtiquetas junta N vias
  // consecutivas num unico ^XA/^XZ = 1 linha/adesivo). Cada coluna deve mostrar um item
  // DIFERENTE da fila -- por isso agrupa as requisicoes em blocos do tamanho de
  // N, e dentro de cada bloco casa requisicao[j] com via[j] (posicao =
  // coluna). Ex: etiqueta de 2 vias, 5 itens (X1..X5) -> blocos [X1,X2] [X3,X4] [X5] = 2
  // linhas completas + 1 linha final com o item que sobrou (coluna 2 fica em branco, ja que
  // o bloco final tem só 1 item -- nao duplica o ultimo item pra preencher a coluna vazia).
  //
  // Bug anterior: pra cada requisicao gerava TODAS as vias com os MESMOS dados (mesma
  // requisicao repetida em todas as colunas) -- "X e Y" saia "X e X" numa linha e "Y e Y" em
  // outra, em vez de "X e Y" numa linha so.
  for (
    var inicio = 0;
    inicio < requisicoes.length;
    inicio += viasOrdenadas.length
  ) {
    final bloco = requisicoes
        .skip(inicio)
        .take(viasOrdenadas.length)
        .toList(growable: false);

    for (var coluna = 0; coluna < bloco.length; coluna++) {
      final requisicao = bloco[coluna];
      final via = viasOrdenadas[coluna];

      final zplProcessado = processar(
        templateZpl: via.zpl,
        titulo: titulo,
        cor: requisicao.cor,
        tamanho: requisicao.tamanho,
        codigoBarras: requisicao.codigoBarras,
        preco: requisicao.preco,
        descricao: requisicao.descricao,
        limitesCaracteres: limitesCaracteres,
      );

      novosItens.add(
        EtiquetaImpressaoItem.create(
          descricao:
              '${requisicao.descricao} | Cor: ${requisicao.corExibicao} | Tam: ${requisicao.tamanho} | Via ${via.ordem + 1}',
          zpl: zplProcessado,
          referencia: requisicao.descricao,
          cor: requisicao.corExibicao,
          tamanho: requisicao.tamanho,
          viaOrdem: via.ordem,
        ),
      );
    }
  }

  return novosItens;
}
