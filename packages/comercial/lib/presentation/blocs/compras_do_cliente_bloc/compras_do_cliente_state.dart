part of 'compras_do_cliente_bloc.dart';

enum ComprasDoClienteStep { inicial, carregando, sucesso, falha }

class ComprasDoClienteState {
  final ComprasDoClienteStep step;
  final RelatorioClienteCompras? dados;
  final String? erro;

  const ComprasDoClienteState({
    required this.step,
    this.dados,
    this.erro,
  });

  const ComprasDoClienteState.initial()
      : step = ComprasDoClienteStep.inicial,
        dados = null,
        erro = null;
}
