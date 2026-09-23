part of 'importar_produtos_csv_bloc.dart';

abstract class ImportarProdutosCsvEvent {}

class ImportarProdutosVarianteAlterada extends ImportarProdutosCsvEvent {
  final ImportacaoProdutoVariante variante;

  ImportarProdutosVarianteAlterada({required this.variante});
}

// Abre o seletor de arquivos e já atualiza o state com o path escolhido.
class ImportarProdutosArquivoSelecionado extends ImportarProdutosCsvEvent {}

class ImportarProdutosBaixouTemplate extends ImportarProdutosCsvEvent {}

class ImportarProdutosEnviou extends ImportarProdutosCsvEvent {}
