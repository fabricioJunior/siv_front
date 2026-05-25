/// Contrato generico para um item de impressao.
/// Qualquer dominio que queira usar [ImpressaoProgressPage]
/// deve fornecer objetos que implementem esta interface.
abstract class ItemDeImpressao {
  String get descricao;
  String get zpl;
}
