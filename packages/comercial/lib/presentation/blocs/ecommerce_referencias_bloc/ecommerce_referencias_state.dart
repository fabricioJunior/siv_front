part of 'ecommerce_referencias_bloc.dart';

abstract class EcommerceReferenciasState extends Equatable {
  int? get ecommerceId => null;
  List<EcommerceReferencia> get referencias => const [];
  bool get processandoLote => false;
  int? get loteAtual => null;
  int? get loteTotal => null;
  String? get busca => null;
  List<int>? get categoriaIds => null;
  bool? get rascunhoFiltro => null;

  const EcommerceReferenciasState();

  @override
  List<Object?> get props => [
        ecommerceId,
        referencias,
        processandoLote,
        loteAtual,
        loteTotal,
        busca,
        categoriaIds,
        rascunhoFiltro,
      ];
}

class EcommerceReferenciasInitial extends EcommerceReferenciasState {
  const EcommerceReferenciasInitial();
}

class EcommerceReferenciasCarregarEmProgresso
    extends EcommerceReferenciasState {
  const EcommerceReferenciasCarregarEmProgresso();
}

class EcommerceReferenciasCarregarSucesso extends EcommerceReferenciasState {
  @override
  final int? ecommerceId;
  @override
  final List<EcommerceReferencia> referencias;
  @override
  final bool processandoLote;
  @override
  final int? loteAtual;
  @override
  final int? loteTotal;
  @override
  final String? busca;
  @override
  final List<int>? categoriaIds;
  @override
  final bool? rascunhoFiltro;

  const EcommerceReferenciasCarregarSucesso({
    required this.ecommerceId,
    required this.referencias,
    this.processandoLote = false,
    this.loteAtual,
    this.loteTotal,
    this.busca,
    this.categoriaIds,
    this.rascunhoFiltro,
  });
}

class EcommerceReferenciasCarregarFalha extends EcommerceReferenciasState {
  const EcommerceReferenciasCarregarFalha();
}

class EcommerceReferenciasAdicionarFalha extends EcommerceReferenciasState {
  @override
  final int? ecommerceId;
  @override
  final List<EcommerceReferencia> referencias;

  const EcommerceReferenciasAdicionarFalha({
    required this.ecommerceId,
    required this.referencias,
  });
}

class EcommerceReferenciasDespublicarTodasFalha
    extends EcommerceReferenciasState {
  @override
  final int? ecommerceId;
  @override
  final List<EcommerceReferencia> referencias;

  const EcommerceReferenciasDespublicarTodasFalha({
    required this.ecommerceId,
    required this.referencias,
  });
}

// Estado one-shot: sinaliza fim do lote (R4) pra a página exibir a mensagem
// "X publicados, Y falharam" via BlocListener. Já vem com a lista recarregada.
class EcommerceReferenciasLoteConcluiu extends EcommerceReferenciasState {
  @override
  final int? ecommerceId;
  @override
  final List<EcommerceReferencia> referencias;
  @override
  final String? busca;
  @override
  final List<int>? categoriaIds;
  @override
  final bool? rascunhoFiltro;
  final int publicados;
  final int falharam;

  const EcommerceReferenciasLoteConcluiu({
    required this.ecommerceId,
    required this.referencias,
    this.busca,
    this.categoriaIds,
    this.rascunhoFiltro,
    required this.publicados,
    required this.falharam,
  });
}
