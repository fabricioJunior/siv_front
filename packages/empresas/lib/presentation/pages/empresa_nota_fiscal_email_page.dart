import 'package:core/bloc.dart';
import 'package:core/injecoes.dart';
import 'package:empresas/presentation/blocs/empresa_nota_fiscal_email_bloc/empresa_nota_fiscal_email_bloc.dart';
import 'package:flutter/material.dart';

class EmpresaNotaFiscalEmailPage extends StatelessWidget {
  final int idEmpresa;

  const EmpresaNotaFiscalEmailPage({super.key, required this.idEmpresa});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<EmpresaNotaFiscalEmailBloc>(
      create: (_) => sl<EmpresaNotaFiscalEmailBloc>()
        ..add(EmpresaNotaFiscalEmailIniciou(idEmpresa)),
      child: const _EmpresaNotaFiscalEmailView(),
    );
  }
}

class _EmpresaNotaFiscalEmailView extends StatefulWidget {
  const _EmpresaNotaFiscalEmailView();

  @override
  State<_EmpresaNotaFiscalEmailView> createState() =>
      _EmpresaNotaFiscalEmailViewState();
}

class _EmpresaNotaFiscalEmailViewState
    extends State<_EmpresaNotaFiscalEmailView> {
  final _assuntoController = TextEditingController();
  final _templateController = TextEditingController();
  bool _controllersInicializados = false;

  @override
  void dispose() {
    _assuntoController.dispose();
    _templateController.dispose();
    super.dispose();
  }

  void _inserirVariavel(String variavel) {
    final selecao = _templateController.selection;
    final texto = _templateController.text;
    final indice = selecao.isValid ? selecao.start : texto.length;
    final fim = selecao.isValid ? selecao.end : texto.length;

    final novoTexto = texto.replaceRange(indice, fim, variavel);
    final novaPosicao = indice + variavel.length;

    _templateController.value = TextEditingValue(
      text: novoTexto,
      selection: TextSelection.collapsed(offset: novaPosicao),
    );

    context.read<EmpresaNotaFiscalEmailBloc>().add(
          EmpresaNotaFiscalEmailTemplateHtmlAlterado(novoTexto),
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<EmpresaNotaFiscalEmailBloc, EmpresaNotaFiscalEmailState>(
      listenWhen: (previous, current) =>
          previous.carregando != current.carregando ||
          previous.salvou != current.salvou ||
          previous.erro != current.erro,
      listener: (context, state) {
        if (!state.carregando && !_controllersInicializados) {
          _controllersInicializados = true;
          _assuntoController.text = state.assunto;
          _templateController.text = state.templateHtml;
        }

        if (state.salvou) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Configuração salva com sucesso.')),
          );
        }

        if (state.erro != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.erro!)),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Nota fiscal por e-mail'),
          actions: [
            BlocBuilder<EmpresaNotaFiscalEmailBloc, EmpresaNotaFiscalEmailState>(
              builder: (context, state) {
                if (state.salvando) {
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator.adaptive(strokeWidth: 2),
                    ),
                  );
                }
                return IconButton(
                  tooltip: 'Salvar',
                  icon: const Icon(Icons.save),
                  onPressed: () => context
                      .read<EmpresaNotaFiscalEmailBloc>()
                      .add(EmpresaNotaFiscalEmailSalvar()),
                );
              },
            ),
          ],
        ),
        body: BlocBuilder<EmpresaNotaFiscalEmailBloc, EmpresaNotaFiscalEmailState>(
          builder: (context, state) {
            if (state.carregando) {
              return const Center(child: CircularProgressIndicator.adaptive());
            }

            return SafeArea(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  SwitchListTile(
                    title: const Text(
                      'Habilitar envio de nota fiscal por e-mail',
                    ),
                    value: state.ativo,
                    onChanged: (value) => context
                        .read<EmpresaNotaFiscalEmailBloc>()
                        .add(EmpresaNotaFiscalEmailAtivoAlterado(value)),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _assuntoController,
                    decoration: const InputDecoration(
                      labelText: 'Assunto do e-mail',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) => context
                        .read<EmpresaNotaFiscalEmailBloc>()
                        .add(EmpresaNotaFiscalEmailAssuntoAlterado(value)),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Layout do e-mail (HTML)',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                      PopupMenuButton<String>(
                        tooltip: 'Inserir variável',
                        onSelected: _inserirVariavel,
                        itemBuilder: (context) => const [
                          PopupMenuItem(
                            value: '@{nomeEmpresa}',
                            child: Text('@{nomeEmpresa}'),
                          ),
                          PopupMenuItem(
                            value: '@{linkNotaFiscal}',
                            child: Text('@{linkNotaFiscal}'),
                          ),
                        ],
                        child: const Chip(
                          avatar: Icon(Icons.add, size: 18),
                          label: Text('Inserir variável'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _templateController,
                    maxLines: null,
                    minLines: 8,
                    decoration: const InputDecoration(
                      hintText: '<html>...</html>',
                      border: OutlineInputBorder(),
                      alignLabelWithHint: true,
                    ),
                    onChanged: (value) => context
                        .read<EmpresaNotaFiscalEmailBloc>()
                        .add(EmpresaNotaFiscalEmailTemplateHtmlAlterado(value)),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Use @{nomeEmpresa} e @{linkNotaFiscal} no HTML para '
                    'inserir o nome da empresa e o link da nota fiscal '
                    'automaticamente.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.black54,
                        ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
