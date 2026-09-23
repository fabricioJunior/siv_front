part of 'importar_estoque_csv_bloc.dart';

enum ImportarEstoqueCsvStep {
  editando,
  validacaoInvalida,
  enviando,
  concluido,
  falha,
}

class ImportarEstoqueCsvState extends Equatable {
  final String? arquivoPath;
  final String? arquivoNome;
  final int? linhasEnviadas;
  final String? erro;
  final ImportarEstoqueCsvStep step;

  const ImportarEstoqueCsvState({
    this.arquivoPath,
    this.arquivoNome,
    this.linhasEnviadas,
    this.erro,
    required this.step,
  });

  bool get podeEnviar => arquivoPath != null;

  ImportarEstoqueCsvState copyWith({
    String? arquivoPath,
    String? arquivoNome,
    int? linhasEnviadas,
    String? erro,
    ImportarEstoqueCsvStep? step,
  }) {
    return ImportarEstoqueCsvState(
      arquivoPath: arquivoPath ?? this.arquivoPath,
      arquivoNome: arquivoNome ?? this.arquivoNome,
      linhasEnviadas: linhasEnviadas ?? this.linhasEnviadas,
      erro: erro,
      step: step ?? this.step,
    );
  }

  @override
  List<Object?> get props =>
      [arquivoPath, arquivoNome, linhasEnviadas, erro, step];
}
