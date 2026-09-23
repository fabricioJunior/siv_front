import 'dart:io';

import 'package:estoque/domain/data/repositorios/i_importacao_estoque_repository.dart';
import 'package:estoque/domain/models/item_importacao_estoque.dart';

class ImportarEstoqueCsv {
  final IImportacaoEstoqueRepository _repository;

  ImportarEstoqueCsv({required IImportacaoEstoqueRepository repository})
      : _repository = repository;

  /// Lê e parseia o CSV localmente (separador `;`, cabeçalho
  /// `produtoIdExterno;quantidade` pulado) -- endpoint `/v1/estoque/importar`
  /// é síncrono e recebe array JSON puro, sem template nem polling no
  /// backend. Retorna a quantidade de linhas enviadas.
  Future<int> call({required String filePath, required int empresaId}) async {
    final linhas = await File(filePath).readAsLines();
    final itens = <ItemImportacaoEstoque>[];

    for (final linha in linhas.skip(1)) {
      if (linha.trim().isEmpty) continue;
      final campos = linha.split(';');
      if (campos.length < 2) continue;

      final produtoIdExterno = campos[0].trim();
      final quantidade =
          double.tryParse(campos[1].trim().replaceAll(',', '.'));
      if (produtoIdExterno.isEmpty || quantidade == null) continue;

      itens.add(ItemImportacaoEstoque(
        empresaId: empresaId,
        produtoIdExterno: produtoIdExterno,
        quantidade: quantidade,
      ));
    }

    await _repository.importar(itens);
    return itens.length;
  }
}
