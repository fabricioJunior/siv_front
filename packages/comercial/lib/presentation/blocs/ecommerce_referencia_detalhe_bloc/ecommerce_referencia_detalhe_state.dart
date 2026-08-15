part of 'ecommerce_referencia_detalhe_bloc.dart';

class EcommerceReferenciaDetalheState extends Equatable {
  final int? ecommerceId;
  final int? referenciaEcommerceId;
  final int? referenciaId;
  final bool rascunho;
  final List<EcommerceReferenciaProduto> produtos;
  final String? erro;
  final EcommerceReferenciaDetalheStep step;
  final bool processandoLote;

  const EcommerceReferenciaDetalheState({
    this.ecommerceId,
    this.referenciaEcommerceId,
    this.referenciaId,
    this.rascunho = true,
    this.produtos = const [],
    this.erro,
    required this.step,
    this.processandoLote = false,
  });

  EcommerceReferenciaDetalheState copyWith({
    int? ecommerceId,
    int? referenciaEcommerceId,
    int? referenciaId,
    bool? rascunho,
    List<EcommerceReferenciaProduto>? produtos,
    String? erro,
    EcommerceReferenciaDetalheStep? step,
    bool? processandoLote,
  }) {
    return EcommerceReferenciaDetalheState(
      ecommerceId: ecommerceId ?? this.ecommerceId,
      referenciaEcommerceId: referenciaEcommerceId ?? this.referenciaEcommerceId,
      referenciaId: referenciaId ?? this.referenciaId,
      rascunho: rascunho ?? this.rascunho,
      produtos: produtos ?? this.produtos,
      erro: erro?.isEmpty == true ? null : (erro ?? this.erro),
      step: step ?? this.step,
      processandoLote: processandoLote ?? this.processandoLote,
    );
  }

  @override
  List<Object?> get props => [
        ecommerceId,
        referenciaEcommerceId,
        referenciaId,
        rascunho,
        produtos,
        erro,
        step,
        processandoLote,
      ];
}

enum EcommerceReferenciaDetalheStep {
  inicial,
  carregando,
  carregado,
  atualizado,
  falha,
}
