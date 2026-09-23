class ItemImportacaoEstoque {
  final int empresaId;
  final String produtoIdExterno;
  final double quantidade;

  const ItemImportacaoEstoque({
    required this.empresaId,
    required this.produtoIdExterno,
    required this.quantidade,
  });

  Map<String, dynamic> toJson() => {
        'empresaId': empresaId,
        'produtoIdExterno': produtoIdExterno,
        'quantidade': quantidade,
      };
}
