part of 'importar_pedidos_csv_bloc.dart';

enum ImportarPedidosCsvStep {
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

class ImportarPedidosCsvState extends Equatable {
  final int? tabelaDePrecoId;
  final String? arquivoPath;
  final String? arquivoNome;
  final ImportacaoPedidoTransferencia? importacao;
  final String? erro;
  final ImportarPedidosCsvStep step;

  const ImportarPedidosCsvState({
    this.tabelaDePrecoId,
    this.arquivoPath,
    this.arquivoNome,
    this.importacao,
    this.erro,
    required this.step,
  });

  bool get podeEnviar => tabelaDePrecoId != null && arquivoPath != null;

  ImportarPedidosCsvState copyWith({
    int? tabelaDePrecoId,
    String? arquivoPath,
    String? arquivoNome,
    ImportacaoPedidoTransferencia? importacao,
    String? erro,
    ImportarPedidosCsvStep? step,
  }) {
    return ImportarPedidosCsvState(
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
        tabelaDePrecoId,
        arquivoPath,
        arquivoNome,
        importacao,
        erro,
        step,
      ];
}
