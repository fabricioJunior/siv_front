part of 'precos_da_referencia_bloc.dart';

enum PrecosDaReferenciaStep { inicial, carregando, sucesso, salvando, falha }

class PrecosDaReferenciaState extends Equatable {
  final PrecosDaReferenciaStep step;
  final int? referenciaId;
  final List<PrecoDaReferenciaPorTabela> tabelas;
  final int? tabelaEmEdicaoId;
  final String valorDigitado;
  final String? erroValidacao;

  const PrecosDaReferenciaState({
    this.step = PrecosDaReferenciaStep.inicial,
    this.referenciaId,
    this.tabelas = const [],
    this.tabelaEmEdicaoId,
    this.valorDigitado = '',
    this.erroValidacao,
  });

  int get totalComPreco => tabelas.where((t) => t.temPreco).length;
  int get totalTabelas => tabelas.length;

  /// Prévia do valor final: o terminador da tabela sempre substitui as
  /// casas decimais digitadas ao salvar (ver [calcularValorComTerminador]).
  double? get previaValorComTerminador {
    final valor = parseValor(valorDigitado);
    if (valor == null || tabelaEmEdicaoId == null) return null;
    final tabela = tabelas.firstWhere(
      (t) => t.tabelaDePrecoId == tabelaEmEdicaoId,
      orElse: () => tabelas.first,
    );
    return calcularValorComTerminador(valor, tabela.terminador);
  }

  PrecosDaReferenciaState copyWith({
    PrecosDaReferenciaStep? step,
    int? referenciaId,
    List<PrecoDaReferenciaPorTabela>? tabelas,
    int? tabelaEmEdicaoId,
    bool clearTabelaEmEdicao = false,
    String? valorDigitado,
    String? erroValidacao,
    bool clearErro = false,
  }) {
    return PrecosDaReferenciaState(
      step: step ?? this.step,
      referenciaId: referenciaId ?? this.referenciaId,
      tabelas: tabelas ?? this.tabelas,
      tabelaEmEdicaoId: clearTabelaEmEdicao
          ? null
          : (tabelaEmEdicaoId ?? this.tabelaEmEdicaoId),
      valorDigitado: valorDigitado ?? this.valorDigitado,
      erroValidacao: clearErro ? erroValidacao : (erroValidacao ?? this.erroValidacao),
    );
  }

  @override
  List<Object?> get props => [
    step,
    referenciaId,
    tabelas,
    tabelaEmEdicaoId,
    valorDigitado,
    erroValidacao,
  ];
}
