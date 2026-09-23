import 'package:core/bloc.dart';
import 'package:core/injecoes.dart';
import 'package:estoque/presentation.dart';
import 'package:flutter/material.dart';

class ImportarEstoqueCsvPage extends StatelessWidget {
  const ImportarEstoqueCsvPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ImportarEstoqueCsvBloc>(
      create: (_) => sl<ImportarEstoqueCsvBloc>(),
      child: BlocListener<ImportarEstoqueCsvBloc, ImportarEstoqueCsvState>(
        listenWhen: (previous, current) => previous.erro != current.erro,
        listener: (context, state) {
          if (state.erro != null) {
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(state.erro!)));
          }
        },
        child: Scaffold(
          appBar: AppBar(title: const Text('Importar estoque via CSV')),
          body: BlocBuilder<ImportarEstoqueCsvBloc, ImportarEstoqueCsvState>(
            builder: (context, state) {
              if (state.step == ImportarEstoqueCsvStep.concluido) {
                return SafeArea(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        '${state.linhasEnviadas ?? 0} linhas de estoque atualizadas',
                        style: Theme.of(context).textTheme.titleMedium,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                );
              }

              final processando =
                  state.step == ImportarEstoqueCsvStep.enviando;

              return SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '1. Baixe o modelo e preencha produtoIdExterno e quantidade',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        onPressed: () => context
                            .read<ImportarEstoqueCsvBloc>()
                            .add(ImportarEstoqueBaixouTemplate()),
                        icon: const Icon(Icons.download_outlined),
                        label: const Text('Baixar modelo'),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        '2. Selecione o CSV preenchido',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        onPressed: () => context
                            .read<ImportarEstoqueCsvBloc>()
                            .add(ImportarEstoqueArquivoSelecionado()),
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
                                .read<ImportarEstoqueCsvBloc>()
                                .add(ImportarEstoqueEnviou()),
                        icon: processando
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator.adaptive(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.upload_outlined),
                        label: Text(processando ? 'Enviando...' : 'Importar'),
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
