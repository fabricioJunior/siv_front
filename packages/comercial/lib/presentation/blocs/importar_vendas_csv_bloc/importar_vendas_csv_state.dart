part of 'importar_vendas_csv_bloc.dart';

enum ImportarVendasCsvStep {
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

class ImportarVendasCsvState extends Equatable {
  final int? tabelaDePrecoId;
  final int? funcionarioId;
  final String? arquivoPath;
  final String? arquivoNome;
  final ImportacaoVenda? importacao;
  final String? erro;
  final ImportarVendasCsvStep step;

  const ImportarVendasCsvState({
    this.tabelaDePrecoId,
    this.funcionarioId,
    this.arquivoPath,
    this.arquivoNome,
    this.importacao,
    this.erro,
    required this.step,
  });

  bool get podeEnviar =>
      tabelaDePrecoId != null && funcionarioId != null && arquivoPath != null;

  ImportarVendasCsvState copyWith({
    int? tabelaDePrecoId,
    int? funcionarioId,
    String? arquivoPath,
    String? arquivoNome,
    ImportacaoVenda? importacao,
    String? erro,
    ImportarVendasCsvStep? step,
  }) {
    return ImportarVendasCsvState(
      tabelaDePrecoId: tabelaDePrecoId ?? this.tabelaDePrecoId,
      funcionarioId: funcionarioId ?? this.funcionarioId,
      arquivoPath: arquivoPath ?? this.arquivoPath,
      arquivoNome: arquivoNome ?? this.arquivoNome,
      importacao: importacao ?? this.importacao,
      erro: erro,
      step: step ?? this.step,
    );
  }

  @override
  List<Object?> get props => [
        tabelaDePrecoId,
        funcionarioId,
        arquivoPath,
        arquivoNome,
        importacao,
        erro,
        step,
      ];
}
