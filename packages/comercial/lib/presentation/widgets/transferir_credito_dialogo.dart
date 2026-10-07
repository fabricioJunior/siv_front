import 'package:comercial/models.dart';
import 'package:comercial/presentation/blocs/transferir_credito_bloc/transferir_credito_bloc.dart';
import 'package:core/bloc.dart';
import 'package:core/injecoes.dart';
import 'package:core/presentation.dart';
import 'package:core/tema.dart';
import 'package:flutter/material.dart';

String formatarMoedaBr(double v) {
  final partes = v.abs().toStringAsFixed(2).split('.');
  final inteiro = partes[0].replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+(?!\d))'),
    (_) => '.',
  );
  return '${v < 0 ? '-' : ''}R\$ $inteiro,${partes[1]}';
}

/// Lista os créditos do "Cliente não cadastrado" e transfere para [pessoaId].
/// Retorna o resultado quando transferiu, `null` se cancelou.
class TransferirCreditoDialogo extends StatelessWidget {
  final int pessoaId;
  final String nomeDestino;

  const TransferirCreditoDialogo({
    super.key,
    required this.pessoaId,
    required this.nomeDestino,
  });

  static Future<ResultadoTransferenciaCredito?> mostrar(
    BuildContext context, {
    required int pessoaId,
    required String nomeDestino,
  }) {
    final corpo = TransferirCreditoDialogo(
      pessoaId: pessoaId,
      nomeDestino: nomeDestino,
    );
    final desktop =
        MediaQuery.sizeOf(context).width >= SivDimensoes.breakpointMenuDrawer;
    if (desktop) {
      return showDialog<ResultadoTransferenciaCredito>(
        context: context,
        builder: (_) => Dialog(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560, maxHeight: 640),
            child: corpo,
          ),
        ),
      );
    }
    return showModalBottomSheet<ResultadoTransferenciaCredito>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => SizedBox(
        height: MediaQuery.sizeOf(context).height,
        child: corpo,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<TransferirCreditoBloc>(
      create: (_) =>
          sl<TransferirCreditoBloc>()..add(TransferirCreditoCarregou(pessoaId)),
      child: BlocConsumer<TransferirCreditoBloc, TransferirCreditoState>(
        listenWhen: (a, b) => a.status != b.status,
        listener: (context, state) {
          if (state.status == TransferirCreditoStatus.sucesso) {
            Navigator.of(context).pop(state.resultado);
          }
        },
        builder: (context, state) => _Conteudo(
          state: state,
          pessoaId: pessoaId,
          nomeDestino: nomeDestino,
        ),
      ),
    );
  }
}

class _Conteudo extends StatelessWidget {
  final TransferirCreditoState state;
  final int pessoaId;
  final String nomeDestino;

  const _Conteudo({
    required this.state,
    required this.pessoaId,
    required this.nomeDestino,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final transferindo = state.status == TransferirCreditoStatus.transferindo;
    final podeTransferir = state.selecionados.isNotEmpty && !transferindo;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Transferir crédito do cliente não cadastrado',
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 4),
          Text('Destino: $nomeDestino', style: theme.textTheme.bodySmall),
          const SizedBox(height: 12),
          Expanded(child: _Lista(state: state, pessoaId: pessoaId)),
          if (state.erro != null && state.status != TransferirCreditoStatus.erroCarga)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                state.erro!,
                style: TextStyle(color: theme.colorScheme.error),
              ),
            ),
          const SizedBox(height: 12),
          Text(
            'Total selecionado: ${formatarMoedaBr(state.total)}',
            style: theme.textTheme.titleMedium,
            textAlign: TextAlign.end,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              TextButton(
                onPressed:
                    transferindo ? null : () => Navigator.of(context).pop(),
                child: const Text('Cancelar'),
              ),
              const Spacer(),
              FilledButton(
                onPressed: podeTransferir
                    ? () => _confirmar(context)
                    : null,
                child: transferindo
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text('TRANSFERIR ${formatarMoedaBr(state.total)}'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _confirmar(BuildContext context) async {
    final bloc = context.read<TransferirCreditoBloc>();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirmar transferência'),
        content: Text(
          'Mover ${formatarMoedaBr(state.total)} do cliente não cadastrado '
          'para $nomeDestino? Essa ação não pode ser desfeita pela tela.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Voltar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Transferir'),
          ),
        ],
      ),
    );
    if (ok == true) bloc.add(TransferirCreditoConfirmou());
  }
}

class _Lista extends StatelessWidget {
  final TransferirCreditoState state;
  final int pessoaId;

  const _Lista({required this.state, required this.pessoaId});

  @override
  Widget build(BuildContext context) {
    switch (state.status) {
      case TransferirCreditoStatus.carregando:
        return const Center(child: CircularProgressIndicator.adaptive());
      case TransferirCreditoStatus.erroCarga:
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                state.erro ?? 'Falha ao carregar os créditos.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () => context
                    .read<TransferirCreditoBloc>()
                    .add(TransferirCreditoCarregou(pessoaId)),
                child: const Text('Tentar de novo'),
              ),
            ],
          ),
        );
      default:
        if (state.creditos.isEmpty) {
          return const Center(
            child: Text(
              'Não há crédito de devolução parado no cliente não cadastrado',
              textAlign: TextAlign.center,
            ),
          );
        }
        final bloqueado = state.status == TransferirCreditoStatus.transferindo;
        return ListView.builder(
          itemCount: state.creditos.length,
          itemBuilder: (context, i) {
            final c = state.creditos[i];
            return CheckboxListTile(
              value: state.selecionados.contains(c.romaneioId),
              onChanged: bloqueado
                  ? null
                  : (_) => context
                      .read<TransferirCreditoBloc>()
                      .add(TransferirCreditoAlternou(c.romaneioId)),
              title: Text(
                '${formatarDataHora(c.data)} • Romaneio ${c.romaneioId}',
              ),
              subtitle: c.observacao.isEmpty ? null : Text(c.observacao),
              secondary: Text(
                formatarMoedaBr(c.valor),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              controlAffinity: ListTileControlAffinity.leading,
            );
          },
        );
    }
  }
}
