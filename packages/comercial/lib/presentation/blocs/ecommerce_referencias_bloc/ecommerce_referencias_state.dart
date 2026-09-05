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
  bool? get publicavelFiltro => null;

  /// Contadores do envelope -- `null` quando o backend ainda não os envia.
  int? get total => null;
  int? get totalPublicados => null;
  int? get totalRascunho => null;
  int? get totalNaoPublicaveis => null;

  int get pagina => 1;
  bool get temMaisPaginas => false;
  bool get carregandoMais => false;

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
        publicavelFiltro,
        total,
        totalPublicados,
        totalRascunho,
        totalNaoPublicaveis,
        pagina,
        temMaisPaginas,
        carregandoMais,
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
  @override
  final bool? publicavelFiltro;
  @override
  final int? total;
  @override
  final int? totalPublicados;
  @override
  final int? totalRascunho;
  @override
  final int? totalNaoPublicaveis;
  @override
  final int pagina;
  @override
  final bool temMaisPaginas;
  @override
  final bool carregandoMais;

  const EcommerceReferenciasCarregarSucesso({
    required this.ecommerceId,
    required this.referencias,
    this.processandoLote = false,
    this.loteAtual,
    this.loteTotal,
    this.busca,
    this.categoriaIds,
    this.rascunhoFiltro,
    this.publicavelFiltro,
    this.total,
    this.totalPublicados,
    this.totalRascunho,
    this.totalNaoPublicaveis,
    this.pagina = 1,
    this.temMaisPaginas = false,
    this.carregandoMais = false,
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
  @override
  final int? total;
  @override
  final int? totalPublicados;
  @override
  final int? totalRascunho;
  @override
  final int? totalNaoPublicaveis;
  final int publicados;
  final int falharam;
  final List<EcommerceLoteFalha> falhas;

  const EcommerceReferenciasLoteConcluiu({
    required this.ecommerceId,
    required this.referencias,
    this.busca,
    this.categoriaIds,
    this.rascunhoFiltro,
    this.total,
    this.totalPublicados,
    this.totalRascunho,
    this.totalNaoPublicaveis,
    required this.publicados,
    required this.falharam,
    this.falhas = const [],
  });
}
