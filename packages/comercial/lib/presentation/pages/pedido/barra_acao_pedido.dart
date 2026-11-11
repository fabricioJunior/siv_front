import 'package:comercial/models.dart';
import 'package:core/presentation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AcaoPrincipalIntent extends Intent {
  const AcaoPrincipalIntent();
}

class MaisAcoesIntent extends Intent {
  const MaisAcoesIntent();
}

class VoltarPedidoIntent extends Intent {
  const VoltarPedidoIntent();
}

class AdicionarProdutoIntent extends Intent {
  const AdicionarProdutoIntent();
}

class DescontoIntent extends Intent {
  const DescontoIntent();
}

class AbrirPagamentoIntent extends Intent {
  const AbrirPagamentoIntent();
}

class ImprimirDocumentoIntent extends Intent {
  const ImprimirDocumentoIntent();
}

class CopiarLinkCobrancaIntent extends Intent {
  const CopiarLinkCobrancaIntent();
}

const atalhosPedido = <ShortcutActivator, Intent>{
  SingleActivator(LogicalKeyboardKey.f9): AcaoPrincipalIntent(),
  SingleActivator(LogicalKeyboardKey.f10): MaisAcoesIntent(),
  SingleActivator(LogicalKeyboardKey.escape): VoltarPedidoIntent(),
  SingleActivator(LogicalKeyboardKey.f2): AdicionarProdutoIntent(),
  SingleActivator(LogicalKeyboardKey.f4): DescontoIntent(),
  SingleActivator(LogicalKeyboardKey.f6): AbrirPagamentoIntent(),
  SingleActivator(LogicalKeyboardKey.keyP, control: true): ImprimirDocumentoIntent(),
  SingleActivator(LogicalKeyboardKey.keyL, control: true): CopiarLinkCobrancaIntent(),
};

String rotuloAcaoPedido(AcaoPedido a) => switch (a) {
      AcaoPedido.assumirPedido => 'Assumir pedido',
      AcaoPedido.concluirConferencia => 'Concluir conferência',
      AcaoPedido.irParaPagamento => 'Ir para pagamento',
      AcaoPedido.lancarPagamento => 'Lançar pagamento',
      AcaoPedido.faturar => 'Faturar',
      AcaoPedido.marcarEmbalado => 'Marcar embalado',
      AcaoPedido.confirmarRetirada => 'Confirmar retirada',
      AcaoPedido.chamarEntregador => 'Chamar entregador',
      AcaoPedido.confirmarEntrega => 'Confirmar entrega',
      AcaoPedido.fecharAcerto => 'Fechar acerto e faturar',
    };

/// Barra de ação: no máximo 1 botão principal (F9) e 1 "Mais ações" (F10).
/// Principal desabilitado mostra o motivo em texto ao lado.
class BarraAcaoPedido extends StatelessWidget {
  final AcaoPedido? acao;
  final bool habilitada;
  final String? motivo;
  final VoidCallback onPrincipal;
  final VoidCallback onMais;
  final bool mobile;

  /// Falso antes de assumir: a tela inteira é só leitura com o único botão.
  final bool mostrarMais;

  const BarraAcaoPedido({
    super.key,
    required this.acao,
    required this.habilitada,
    required this.motivo,
    required this.onPrincipal,
    required this.onMais,
    this.mobile = false,
    this.mostrarMais = true,
  });

  @override
  Widget build(BuildContext context) {
    final a = acao;
    return SivRodapeAcoes(
      mobile: mobile,
      status: a == null ? '' : (motivo ?? ''),
      secundaria: !mostrarMais
          ? null
          : OutlinedButton(
        key: const Key('pedido_mais_acoes'),
        onPressed: onMais,
        child: Text(mobile ? 'Mais ações' : 'Mais ações · F10'),
      ),
      primaria: a == null
          ? const SizedBox.shrink()
          : FilledButton(
              key: const Key('pedido_acao_principal'),
              onPressed: habilitada ? onPrincipal : null,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(rotuloAcaoPedido(a)),
                  if (!mobile) ...[
                    const SizedBox(width: 8),
                    const Text('· F9'),
                  ],
                ],
              ),
            ),
    );
  }
}
