part of 'consignacao_acerto_bloc.dart';

enum ConsignacaoAcertoStep {
  processando,
  aguardandoPagamento,
  finalizando,
  sucesso,
  falha,
}

class ConsignacaoAcertoState extends Equatable {
  final ConsignacaoAcertoStep step;
  final Romaneio? romaneio;
  final List<RomaneioItem> itens;
  final String? erro;

  const ConsignacaoAcertoState({
    this.step = ConsignacaoAcertoStep.processando,
    this.romaneio,
    this.itens = const [],
    this.erro,
  });

  ConsignacaoAcertoState copyWith({
    ConsignacaoAcertoStep? step,
    Romaneio? romaneio,
    List<RomaneioItem>? itens,
    String? erro,
  }) {
    return ConsignacaoAcertoState(
      step: step ?? this.step,
      romaneio: romaneio ?? this.romaneio,
      itens: itens ?? this.itens,
      erro: erro,
    );
  }

  @override
  List<Object?> get props => [step, romaneio, itens, erro];
}
