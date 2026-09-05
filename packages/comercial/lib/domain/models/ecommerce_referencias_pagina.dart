import 'package:comercial/domain/models/ecommerce_referencia.dart';

/// Envelope de `GET /v1/e-commerce/{id}/referencias`. Os contadores são
/// tolerantes -- `null` quando o backend ainda não os envia; a UI não conta
/// a página carregada e chama de total nesse caso.
class EcommerceReferenciasPagina {
  final List<EcommerceReferencia> itens;
  final int? total;
  final int? totalPublicados;
  final int? totalRascunho;
  final int? totalNaoPublicaveis;

  const EcommerceReferenciasPagina({
    required this.itens,
    this.total,
    this.totalPublicados,
    this.totalRascunho,
    this.totalNaoPublicaveis,
  });
}
