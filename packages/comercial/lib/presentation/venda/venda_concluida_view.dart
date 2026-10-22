import 'package:comercial/domain/models/documento_fiscal.dart';
import 'package:comercial/presentation/pagamento/pagamento_resumo.dart';
import 'package:core/presentation.dart';
import 'package:core/tema.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class VendaProcessandoView extends StatelessWidget {
  const VendaProcessandoView({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator.adaptive(),
          const SizedBox(height: 16),
          Text(
            'Finalizando venda e emitindo nota fiscal, aguarde... '
            'Isso pode levar até 30 segundos.',
            textAlign: TextAlign.center,
            style: context.sivTextos.corpo,
          ),
        ],
      ),
    );
  }
}

String _hora(DateTime d) =>
    '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';

/// Venda concluída (1d): troco e nº do romaneio ficam até "Nova venda".
class VendaConcluidaView extends StatelessWidget {
  final int? romaneioId;
  final String? cliente;
  final DateTime concluidaEm;
  final List<(String, double)> formas;
  final double totalVenda;
  final double troco;
  final bool pontuou;
  final DocumentoFiscal? documentoFiscal;
  final String? emailNota;
  final VoidCallback onImprimir;
  final VoidCallback onReenviarNota;
  final VoidCallback onNovaVenda;

  const VendaConcluidaView({
    super.key,
    required this.romaneioId,
    required this.cliente,
    required this.concluidaEm,
    required this.formas,
    required this.totalVenda,
    required this.troco,
    required this.pontuou,
    required this.documentoFiscal,
    required this.emailNota,
    required this.onImprimir,
    required this.onReenviarNota,
    required this.onNovaVenda,
  });

  String get _statusNota {
    final doc = documentoFiscal;
    final email = (emailNota ?? '').isEmpty ? '' : ' · enviada para $emailNota';
    return switch (doc?.status) {
      'emitida' => 'NF-e autorizada$email',
      'pendente' || 'processando' => 'NF-e em emissão...',
      'falha' || 'rejeitada' =>
        'NF-e não emitida. A venda está concluída; reenvie a nota.',
      _ => 'NF-e: sem documento fiscal',
    };
  }

  @override
  Widget build(BuildContext context) {
    final cores = context.sivColors;
    final textos = context.sivTextos;
    final status = documentoFiscal?.status;
    final emitindo = status == 'pendente' || status == 'processando';
    final podeReenviar =
        status == 'emitida' || status == 'falha' || status == 'rejeitada';

    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.enter): onNovaVenda,
        const SingleActivator(LogicalKeyboardKey.numpadEnter): onNovaVenda,
        const SingleActivator(LogicalKeyboardKey.keyP): onImprimir,
      },
      child: Focus(
        autofocus: true,
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Icon(Icons.check_circle_outline, color: cores.verde),
                      const SizedBox(width: 8),
                      Text('VENDA CONCLUÍDA', style: textos.secao),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Romaneio #${romaneioId ?? '-'}'
                    '${cliente == null ? '' : ' · $cliente'}'
                    ' · ${_hora(concluidaEm)}',
                    style: textos.apoio,
                  ),
                  const SizedBox(height: 16),
                  SivCard(
                    variante: SivCardVariante.destaque,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          troco > 0.004 ? 'DEVOLVER DE TROCO' : 'SEM TROCO',
                          style: textos.rotulo.copyWith(
                            color: cores.textoSobreEscuroApoio,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          pagamentoMoeda(troco > 0.004 ? troco : 0),
                          style: textos.display.copyWith(
                            color: cores.textoSobreEscuroTitulo,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  SivCard(
                    child: Column(
                      children: [
                        for (final (nome, valor) in formas)
                          _Linha(nome, pagamentoMoeda(valor)),
                        Divider(color: cores.hairline),
                        _Linha('Total da venda', pagamentoMoeda(totalVenda)),
                        if (pontuou) const _Linha('Fidelidade', 'pontuada'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(_statusNota, style: textos.apoio),
                  if (emitindo) ...[
                    const SizedBox(height: 6),
                    const LinearProgressIndicator(),
                  ],
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: onImprimir,
                          child: const Text('Imprimir romaneio  P'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: podeReenviar ? onReenviarNota : null,
                          child: const Text('Reenviar nota'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 48,
                    child: FilledButton(
                      onPressed: onNovaVenda,
                      child: const Text('NOVA VENDA · ENTER'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Pendência (1e): romaneio criado, recebimento falhou. Nada cobrado.
class VendaPendenciaView extends StatelessWidget {
  final int? romaneioId;
  final String? motivo;
  final VoidCallback onVerRomaneio;
  final VoidCallback onNovaVenda;
  final VoidCallback onTentarNovamente;

  const VendaPendenciaView({
    super.key,
    required this.romaneioId,
    required this.motivo,
    required this.onVerRomaneio,
    required this.onNovaVenda,
    required this.onTentarNovamente,
  });

  @override
  Widget build(BuildContext context) {
    final cores = context.sivColors;
    final textos = context.sivTextos;

    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.enter): onTentarNovamente,
        const SingleActivator(LogicalKeyboardKey.numpadEnter):
            onTentarNovamente,
      },
      child: Focus(
        autofocus: true,
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Icon(Icons.warning_amber_rounded, color: cores.atencao),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'ROMANEIO #${romaneioId ?? '-'} CRIADO, '
                          'MAS NÃO RECEBIDO',
                          style: textos.secao,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Os itens foram gravados, mas o recebimento no caixa '
                    'falhou: nada foi cobrado e o estoque não baixou. '
                    'Não devolva troco. O romaneio fica em andamento, com o '
                    'motivo salvo.',
                    style: textos.corpo,
                  ),
                  if (motivo != null) ...[
                    const SizedBox(height: 12),
                    SivCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('MOTIVO', style: textos.rotulo),
                          const SizedBox(height: 4),
                          Text(motivo!, style: textos.corpo),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: onVerRomaneio,
                          child: const Text('Ver romaneio'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: onNovaVenda,
                          child: const Text('Nova venda'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 48,
                    child: FilledButton(
                      onPressed: onTentarNovamente,
                      child: const Text('TENTAR RECEBER DE NOVO · ENTER'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Linha extends StatelessWidget {
  final String rotulo;
  final String valor;

  const _Linha(this.rotulo, this.valor);

  @override
  Widget build(BuildContext context) {
    final textos = context.sivTextos;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(rotulo, style: textos.corpo),
          Text(valor, style: textos.corpo),
        ],
      ),
    );
  }
}
