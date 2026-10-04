part of 'pedido_entrada_bloc.dart';

class PedidoEntradaState extends Equatable {
  final bool carregando;
  final bool salvando;
  final EntradaResumo? resumo;

  /// Mensagens de uma exibição só (SnackBar).
  final String? erro;
  final String? mensagem;

  /// Última referência criada por pré-cadastro (a tela oferece abrir).
  final int? referenciaCriadaId;

  const PedidoEntradaState({
    this.carregando = false,
    this.salvando = false,
    this.resumo,
    this.erro,
    this.mensagem,
    this.referenciaCriadaId,
  });

  PedidoEntradaState copyWith({
    bool? carregando,
    bool? salvando,
    EntradaResumo? resumo,
    String? erro,
    String? mensagem,
    int? referenciaCriadaId,
  }) {
    return PedidoEntradaState(
      carregando: carregando ?? this.carregando,
      salvando: salvando ?? this.salvando,
      resumo: resumo ?? this.resumo,
      erro: erro,
      mensagem: mensagem,
      referenciaCriadaId: referenciaCriadaId,
    );
  }

  @override
  List<Object?> get props => [
        carregando,
        salvando,
        resumo,
        erro,
        mensagem,
        referenciaCriadaId,
      ];
}
