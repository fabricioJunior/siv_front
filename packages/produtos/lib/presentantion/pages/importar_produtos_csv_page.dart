import 'package:core/bloc.dart';
import 'package:core/injecoes.dart';
import 'package:flutter/material.dart';
import 'package:produtos/models.dart';
import 'package:produtos/presentation.dart';

class ImportarProdutosCsvPage extends StatelessWidget {
  const ImportarProdutosCsvPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ImportarProdutosCsvBloc>(
      create: (_) => sl<ImportarProdutosCsvBloc>(),
      child: BlocListener<ImportarProdutosCsvBloc, ImportarProdutosCsvState>(
        listenWhen: (previous, current) => previous.erro != current.erro,
        listener: (context, state) {
          if (state.erro != null) {
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(state.erro!)));
          }
        },
        child: Scaffold(
          appBar: AppBar(title: const Text('Importar produtos via CSV')),
          body: BlocBuilder<ImportarProdutosCsvBloc, ImportarProdutosCsvState>(
            builder: (context, state) {
              if (state.step == ImportarProdutosCsvStep.concluido ||
                  state.step ==
                      ImportarProdutosCsvStep.processandoEmSegundoPlano) {
                return _ResultadoView(state: state);
              }

              final processando =
                  state.step == ImportarProdutosCsvStep.enviando ||
                      state.step == ImportarProdutosCsvStep.processando;

              return SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '1. Escolha o tipo de importação',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 12),
                      SegmentedButton<ImportacaoProdutoVariante>(
                        segments: const [
                          ButtonSegment(
                            value: ImportacaoProdutoVariante.completo,
                            label: Text('Completo'),
                            icon: Icon(Icons.inventory_2_outlined, size: 16),
                          ),
                          ButtonSegment(
                            value: ImportacaoProdutoVariante.somente,
                            label: Text('Somente produto'),
                            icon: Icon(Icons.checkroom_outlined, size: 16),
                          ),
                        ],
                        selected: {state.variante},
                        onSelectionChanged: (selecao) => context
                            .read<ImportarProdutosCsvBloc>()
                            .add(ImportarProdutosVarianteAlterada(
                                variante: selecao.first)),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        state.variante == ImportacaoProdutoVariante.somente
                            ? 'Cria produtos (cor/tamanho) para uma referência já cadastrada.'
                            : 'Cria referências, produtos, categoria e marca em um só arquivo.',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 24),
                      Text(
                        '2. Baixe o modelo, preencha e faça upload de volta',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        onPressed: () => context
                            .read<ImportarProdutosCsvBloc>()
                            .add(ImportarProdutosBaixouTemplate()),
                        icon: const Icon(Icons.download_outlined),
                        label: const Text('Baixar modelo'),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        '3. Selecione o CSV preenchido',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        onPressed: () => context
                            .read<ImportarProdutosCsvBloc>()
                            .add(ImportarProdutosArquivoSelecionado()),
                        icon: const Icon(Icons.attach_file),
                        label: Text(
                          state.arquivoNome ?? 'Selecionar arquivo',
                        ),
                      ),
                      const SizedBox(height: 24),
                      FilledButton.icon(
                        onPressed: processando || !state.podeEnviar
                            ? null
                            : () => context
                                .read<ImportarProdutosCsvBloc>()
                                .add(ImportarProdutosEnviou()),
                        icon: processando
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator.adaptive(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.upload_outlined),
                        label: Text(
                          state.step == ImportarProdutosCsvStep.enviando
                              ? 'Enviando...'
                              : state.step ==
                                      ImportarProdutosCsvStep.processando
                                  ? 'Processando...'
                                  : 'Importar',
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _ResultadoView extends StatelessWidget {
  final ImportarProdutosCsvState state;

  const _ResultadoView({required this.state});

  @override
  Widget build(BuildContext context) {
    final importacao = state.importacao;
    final resultado = importacao?.resultado;

    if (importacao == null ||
        state.step == ImportarProdutosCsvStep.processandoEmSegundoPlano) {
      return const SafeArea(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Center(
            child: Text(
              'A importação continua sendo processada em segundo plano. '
              'Confira o resultado no histórico de importações.',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    if (importacao.situacao == ImportacaoSituacao.falha || resultado == null) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: Text(
              importacao.erro ?? 'Falha ao processar a importação.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ),
      );
    }

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            '${resultado.importados} de ${resultado.totalRecebidos} linhas importadas',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          if (resultado.rejeitados.isNotEmpty) ...[
            Text(
              'Linhas rejeitadas (${resultado.rejeitados.length})',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            for (final rejeicao in resultado.rejeitados)
              ListTile(
                leading: const Icon(Icons.error_outline, color: Colors.red),
                title: Text('Linha ${rejeicao.linha}'),
                subtitle: Text(rejeicao.motivo),
              ),
          ],
        ],
      ),
    );
  }
}
