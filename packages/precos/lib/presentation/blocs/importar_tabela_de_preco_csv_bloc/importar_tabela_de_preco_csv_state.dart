part of 'importar_tabela_de_preco_csv_bloc.dart';

enum ImportarTabelaDePrecoCsvStep {
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

class ImportarTabelaDePrecoCsvState extends Equatable {
  final List<TabelaDePreco> tabelas;
  final int? tabelaDePrecoId;
  final String? arquivoPath;
  final String? arquivoNome;
  final ImportacaoTabelaDePreco? importacao;
  final String? erro;
  final ImportarTabelaDePrecoCsvStep step;

  const ImportarTabelaDePrecoCsvState({
    this.tabelas = const [],
    this.tabelaDePrecoId,
    this.arquivoPath,
    this.arquivoNome,
    this.importacao,
    this.erro,
    required this.step,
  });

  bool get podeEnviar => tabelaDePrecoId != null && arquivoPath != null;

  ImportarTabelaDePrecoCsvState copyWith({
    List<TabelaDePreco>? tabelas,
    int? tabelaDePrecoId,
    String? arquivoPath,
    String? arquivoNome,
    ImportacaoTabelaDePreco? importacao,
    String? erro,
    ImportarTabelaDePrecoCsvStep? step,
  }) {
    return ImportarTabelaDePrecoCsvState(
      tabelas: tabelas ?? this.tabelas,
      tabelaDePrecoId: tabelaDePrecoId ?? this.tabelaDePrecoId,
      arquivoPath: arquivoPath ?? this.arquivoPath,
      arquivoNome: arquivoNome ?? this.arquivoNome,
      importacao: importacao ?? this.importacao,
      erro: erro,
      step: step ?? this.step,
    );
  }

  @override
  List<Object?> get props => [
        tabelas,
        tabelaDePrecoId,
        arquivoPath,
        arquivoNome,
        importacao,
        erro,
        step,
      ];
}
