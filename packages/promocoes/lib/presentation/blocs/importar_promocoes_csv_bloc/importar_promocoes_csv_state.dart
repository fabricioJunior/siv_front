part of 'importar_promocoes_csv_bloc.dart';

enum ImportarPromocoesCsvStep {
  editando,
  validacaoInvalida,
  enviando,
  processando,
  // Backend ainda não concluiu depois do tempo máximo de polling -- não é
  // falha, só não dá mais pra esperar na tela (ver histórico de importações).
  processandoEmSegundoPlano,
  concluido,
  falha,
}

class ImportarPromocoesCsvState extends Equatable {
  final String? nome;
  final DateTime? dataInicio;
  final DateTime? dataFim;
  final PromocaoCanal canal;
  final String? arquivoPath;
  final String? arquivoNome;
  final ImportacaoPromocao? importacao;
  final String? erro;
  final ImportarPromocoesCsvStep step;

  const ImportarPromocoesCsvState({
    this.nome,
    this.dataInicio,
    this.dataFim,
    this.canal = PromocaoCanal.ambos,
    this.arquivoPath,
    this.arquivoNome,
    this.importacao,
    this.erro,
    required this.step,
  });

  bool get podeEnviar =>
      (nome?.trim().isNotEmpty ?? false) &&
      dataInicio != null &&
      dataFim != null &&
      arquivoPath != null;

  ImportarPromocoesCsvState copyWith({
    String? nome,
    DateTime? dataInicio,
    DateTime? dataFim,
    PromocaoCanal? canal,
    String? arquivoPath,
    String? arquivoNome,
    ImportacaoPromocao? importacao,
    String? erro,
    ImportarPromocoesCsvStep? step,
  }) {
    return ImportarPromocoesCsvState(
      nome: nome ?? this.nome,
      dataInicio: dataInicio ?? this.dataInicio,
      dataFim: dataFim ?? this.dataFim,
      canal: canal ?? this.canal,
      arquivoPath: arquivoPath ?? this.arquivoPath,
      arquivoNome: arquivoNome ?? this.arquivoNome,
      importacao: importacao ?? this.importacao,
      erro: erro,
      step: step ?? this.step,
    );
  }

  @override
  List<Object?> get props => [
        nome,
        dataInicio,
        dataFim,
        canal,
        arquivoPath,
        arquivoNome,
        importacao,
        erro,
        step,
      ];
}
