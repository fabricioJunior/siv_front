part of 'ecommerce_chaves_mcp_bloc.dart';

enum EcommerceChavesMcpStep { inicial, carregando, carregado, vazio, erro }

class EcommerceChavesMcpState extends Equatable {
  final EcommerceChavesMcpStep step;
  final int? ecommerceId;
  final List<EcommerceChaveMcp> chaves;

  const EcommerceChavesMcpState({
    this.step = EcommerceChavesMcpStep.inicial,
    this.ecommerceId,
    this.chaves = const [],
  });

  int get ativas => chaves.where((c) => c.situacao == SituacaoChaveMcp.ativa).length;

  EcommerceChavesMcpState copyWith({
    EcommerceChavesMcpStep? step,
    int? ecommerceId,
    List<EcommerceChaveMcp>? chaves,
  }) =>
      EcommerceChavesMcpState(
        step: step ?? this.step,
        ecommerceId: ecommerceId ?? this.ecommerceId,
        chaves: chaves ?? this.chaves,
      );

  @override
  List<Object?> get props => [step, ecommerceId, chaves.map((c) => (c.id, c.revogadaEm)).toList()];
}
