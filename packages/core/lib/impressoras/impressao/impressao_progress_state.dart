part of 'impressao_progress_cubit.dart';

enum ImpressaoProgressStatus {
  carregandoImpressoras,
  aguardandoConfirmacao,
  imprimindo,
  sucesso,
  erro,
}

class ImpressaoProgressState extends Equatable {
  final ImpressaoProgressStatus status;
  final List<Impressora> impressoras;
  final Impressora? impressoraSelecionada;
  final int progressoAtual;
  final int totalEtiquetas;
  final String? descricaoAtual;
  final String? mensagemErro;

  const ImpressaoProgressState({
    this.status = ImpressaoProgressStatus.carregandoImpressoras,
    this.impressoras = const [],
    this.impressoraSelecionada,
    this.progressoAtual = 0,
    this.totalEtiquetas = 0,
    this.descricaoAtual,
    this.mensagemErro,
  });

  double get percentualProgresso =>
      totalEtiquetas == 0 ? 0.0 : progressoAtual / totalEtiquetas;

  ImpressaoProgressState copyWith({
    ImpressaoProgressStatus? status,
    List<Impressora>? impressoras,
    Impressora? Function()? impressoraSelecionada,
    int? progressoAtual,
    int? totalEtiquetas,
    String? Function()? descricaoAtual,
    String? Function()? mensagemErro,
  }) {
    return ImpressaoProgressState(
      status: status ?? this.status,
      impressoras: impressoras ?? this.impressoras,
      impressoraSelecionada: impressoraSelecionada != null
          ? impressoraSelecionada()
          : this.impressoraSelecionada,
      progressoAtual: progressoAtual ?? this.progressoAtual,
      totalEtiquetas: totalEtiquetas ?? this.totalEtiquetas,
      descricaoAtual:
          descricaoAtual != null ? descricaoAtual() : this.descricaoAtual,
      mensagemErro:
          mensagemErro != null ? mensagemErro() : this.mensagemErro,
    );
  }

  @override
  List<Object?> get props => [
        status,
        impressoras,
        impressoraSelecionada,
        progressoAtual,
        totalEtiquetas,
        descricaoAtual,
        mensagemErro,
      ];
}
