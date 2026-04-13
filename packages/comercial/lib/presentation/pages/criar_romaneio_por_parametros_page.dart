import 'package:comercial/models.dart';
import 'package:comercial/presentation.dart';
import 'package:core/bloc.dart';
import 'package:core/injecoes.dart';
import 'package:flutter/material.dart';

class CriarRomaneioPorParametrosPage extends StatelessWidget {
  final String hashLista;

  const CriarRomaneioPorParametrosPage({
    super.key,
    required this.hashLista,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider<RomaneioCriacaoBloc>(
      create: (_) => sl<RomaneioCriacaoBloc>()
        ..add(
          RomaneioCriacaoSolicitada(hashLista: hashLista),
        ),
      child: BlocConsumer<RomaneioCriacaoBloc, RomaneioCriacaoState>(
        listenWhen: (previous, current) => previous.erro != current.erro,
        listener: (context, state) {
          if (state.step == RomaneioCriacaoStep.falha && state.erro != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.erro!)),
            );
          }
        },
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Criação de romaneio'),
            ),
            body: Padding(
              padding: const EdgeInsets.all(16),
              child: switch (state.step) {
                RomaneioCriacaoStep.inicial ||
                RomaneioCriacaoStep.processando =>
                  _ProcessandoRomaneioView(
                    quantidadeItens: state.produtosCompartilhados.length,
                  ),
                RomaneioCriacaoStep.falha => _FalhaRomaneioView(
                    erro: state.erro ?? 'Falha ao criar romaneio.',
                    onTentarNovamente: () {
                      context.read<RomaneioCriacaoBloc>().add(
                            RomaneioCriacaoSolicitada(hashLista: hashLista),
                          );
                    },
                  ),
                RomaneioCriacaoStep.sucesso => _SucessoRomaneioView(
                    romaneio: state.romaneio,
                    quantidadeItens: state.totalItensProcessados,
                  ),
              },
            ),
          );
        },
      ),
    );
  }
}

class _ProcessandoRomaneioView extends StatelessWidget {
  final int quantidadeItens;

  const _ProcessandoRomaneioView({required this.quantidadeItens});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator.adaptive(),
          const SizedBox(height: 16),
          Text(
            quantidadeItens > 0
                ? 'Criando romaneio e enviando $quantidadeItens item(ns)...'
                : 'Criando romaneio a partir da lista compartilhada...',
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _FalhaRomaneioView extends StatelessWidget {
  final String erro;
  final VoidCallback onTentarNovamente;

  const _FalhaRomaneioView({
    required this.erro,
    required this.onTentarNovamente,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, size: 48),
          const SizedBox(height: 12),
          Text(
            erro,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: onTentarNovamente,
            icon: const Icon(Icons.refresh),
            label: const Text('Tentar novamente'),
          ),
        ],
      ),
    );
  }
}

class _SucessoRomaneioView extends StatelessWidget {
  final Romaneio? romaneio;
  final int quantidadeItens;

  const _SucessoRomaneioView({
    required this.romaneio,
    required this.quantidadeItens,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListView(
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.check_circle_outline,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Romaneio criado com sucesso',
                      style: theme.textTheme.titleMedium,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text('Romaneio ID: ${romaneio?.id ?? '-'}'),
                Text('Operação: ${romaneio?.operacao?.descricao ?? '-'}'),
                Text('Funcionário ID: ${romaneio?.funcionarioId ?? '-'}'),
                Text('Tabela de preço ID: ${romaneio?.tabelaPrecoId ?? '-'}'),
                Text('Situação: ${romaneio?.situacao ?? '-'}'),
                Text('Itens enviados: $quantidadeItens'),
                if (romaneio?.quantidade != null)
                  Text('Quantidade: ${romaneio!.quantidade}'),
                if (romaneio?.valorBruto != null)
                  Text('Valor bruto: ${romaneio!.valorBruto}'),
                if (romaneio?.valorLiquido != null)
                  Text('Valor líquido: ${romaneio!.valorLiquido}'),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        FilledButton.icon(
          onPressed: romaneio?.id == null
              ? null
              : () {
                  Navigator.of(context).pushReplacementNamed(
                    '/romaneio',
                    arguments: {
                      'idRomaneio': romaneio!.id,
                      'permitirEdicao': false,
                    },
                  );
                },
          icon: const Icon(Icons.open_in_new),
          label: const Text('Abrir romaneio criado'),
        ),
        const SizedBox(height: 8),
        OutlinedButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('Fechar'),
        ),
      ],
    );
  }
}
