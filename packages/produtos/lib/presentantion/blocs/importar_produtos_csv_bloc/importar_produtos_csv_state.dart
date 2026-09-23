part of 'importar_produtos_csv_bloc.dart';

enum ImportarProdutosCsvStep {
  editando,
  validacaoInvalida,
  enviando,
  processando,
  // Backend ainda não concluiu depois do tempo máximo de polling -- não é
  // falha, só não dá mais pra esperar na tela.
  processandoEmSegundoPlano,
  concluido,
  falha,
}

class ImportarProdutosCsvState extends Equatable {
  final ImportacaoProdutoVariante variante;
  final String? arquivoPath;
  final String? arquivoNome;
  final ImportacaoProduto? importacao;
  final String? erro;
  final ImportarProdutosCsvStep step;

  const ImportarProdutosCsvState({
    this.variante = ImportacaoProdutoVariante.completo,
    this.arquivoPath,
    this.arquivoNome,
    this.importacao,
    this.erro,
    required this.step,
  });

  bool get podeEnviar => arquivoPath != null;

  ImportarProdutosCsvState copyWith({
    ImportacaoProdutoVariante? variante,
    String? arquivoPath,
    String? arquivoNome,
    bool limparArquivo = false,
    ImportacaoProduto? importacao,
    String? erro,
    ImportarProdutosCsvStep? step,
  }) {
    return ImportarProdutosCsvState(
      variante: variante ?? this.variante,
      arquivoPath: limparArquivo ? null : (arquivoPath ?? this.arquivoPath),
      arquivoNome: limparArquivo ? null : (arquivoNome ?? this.arquivoNome),
      importacao: importacao ?? this.importacao,
      erro: erro,
      step: step ?? this.step,
    );
  }

  @override
  List<Object?> get props =>
      [variante, arquivoPath, arquivoNome, importacao, erro, step];
}
