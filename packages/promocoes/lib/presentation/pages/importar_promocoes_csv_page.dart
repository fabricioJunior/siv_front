import 'package:core/bloc.dart';
import 'package:core/injecoes.dart';
import 'package:flutter/material.dart';
import 'package:promocoes/models.dart';
import 'package:promocoes/presentation.dart';

class ImportarPromocoesCsvPage extends StatefulWidget {
  const ImportarPromocoesCsvPage({super.key});

  @override
  State<ImportarPromocoesCsvPage> createState() =>
      _ImportarPromocoesCsvPageState();
}

class _ImportarPromocoesCsvPageState extends State<ImportarPromocoesCsvPage> {
  final _nomeController = TextEditingController();

  @override
  void dispose() {
    _nomeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ImportarPromocoesCsvBloc>(
      create: (_) => sl<ImportarPromocoesCsvBloc>(),
      child: BlocListener<ImportarPromocoesCsvBloc, ImportarPromocoesCsvState>(
        listenWhen: (previous, current) => previous.erro != current.erro,
        listener: (context, state) {
          if (state.erro != null) {
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(state.erro!)));
          }
        },
        child: Scaffold(
          appBar: AppBar(title: const Text('Importar promoções via CSV')),
          body: BlocBuilder<ImportarPromocoesCsvBloc, ImportarPromocoesCsvState>(
            builder: (context, state) {
              if (_nomeController.text != (state.nome ?? '')) {
                final nome = state.nome ?? '';
                _nomeController.value = TextEditingValue(
                  text: nome,
                  selection: TextSelection.collapsed(offset: nome.length),
                );
              }

              if (state.step == ImportarPromocoesCsvStep.concluido ||
                  state.step ==
                      ImportarPromocoesCsvStep.processandoEmSegundoPlano) {
                return _ResultadoView(state: state);
              }

              final processando =
                  state.step == ImportarPromocoesCsvStep.enviando ||
                      state.step == ImportarPromocoesCsvStep.processando;

              return SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '1. Baixe o modelo com todas as referências, preencha o percentual '
                        'de desconto somente nas que quer promocionar e faça upload de volta.',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        onPressed: () => context
                            .read<ImportarPromocoesCsvBloc>()
                            .add(ImportarPromocoesBaixouTemplate()),
                        icon: const Icon(Icons.download_outlined),
                        label: const Text('Baixar modelo'),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        '2. Preencha os dados da promoção',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _nomeController,
                        decoration: const InputDecoration(
                          labelText: 'Nome (prefixo das promoções geradas)',
                        ),
                        onChanged: (value) => context
                            .read<ImportarPromocoesCsvBloc>()
                            .add(ImportarPromocoesCampoAlterado(nome: value)),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _SeletorData(
                              titulo: 'Início',
                              data: state.dataInicio,
                              onSelecionado: (data) => context
                                  .read<ImportarPromocoesCsvBloc>()
                                  .add(ImportarPromocoesCampoAlterado(
                                      dataInicio: data)),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _SeletorData(
                              titulo: 'Fim',
                              data: state.dataFim,
                              onSelecionado: (data) => context
                                  .read<ImportarPromocoesCsvBloc>()
                                  .add(ImportarPromocoesCampoAlterado(
                                      dataFim: data)),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<PromocaoCanal>(
                        decoration: const InputDecoration(labelText: 'Canal'),
                        initialValue: state.canal,
                        items: const [
                          DropdownMenuItem(
                            value: PromocaoCanal.ambos,
                            child: Text('Ambos'),
                          ),
                          DropdownMenuItem(
                            value: PromocaoCanal.loja,
                            child: Text('Loja física'),
                          ),
                          DropdownMenuItem(
                            value: PromocaoCanal.ecommerce,
                            child: Text('E-commerce'),
                          ),
                        ],
                        onChanged: (canal) => context
                            .read<ImportarPromocoesCsvBloc>()
                            .add(ImportarPromocoesCampoAlterado(canal: canal)),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        '3. Selecione o CSV preenchido',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        onPressed: () => context
                            .read<ImportarPromocoesCsvBloc>()
                            .add(ImportarPromocoesArquivoSelecionado()),
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
                                .read<ImportarPromocoesCsvBloc>()
                                .add(ImportarPromocoesEnviou()),
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
                          state.step == ImportarPromocoesCsvStep.enviando
                              ? 'Enviando...'
                              : state.step ==
                                      ImportarPromocoesCsvStep.processando
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
  final ImportarPromocoesCsvState state;

  const _ResultadoView({required this.state});

  @override
  Widget build(BuildContext context) {
    final importacao = state.importacao;
    final resultado = importacao?.resultado;

    if (importacao == null ||
        state.step == ImportarPromocoesCsvStep.processandoEmSegundoPlano) {
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
          if (resultado.promocoesCriadas.isNotEmpty) ...[
            Text(
              'Promoções criadas',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            for (final promocao in resultado.promocoesCriadas)
              Card(
                child: ListTile(
                  leading: const Icon(Icons.local_offer_outlined),
                  title: Text(promocao.nome),
                  subtitle: Text(
                    '${promocao.valorPercentual}% · ${promocao.quantidadeReferencias} referência(s)',
                  ),
                ),
              ),
            const SizedBox(height: 16),
          ],
          if (resultado.rejeitados.isNotEmpty) ...[
            Text(
              'Linhas rejeitadas (${resultado.rejeitados.length})',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            for (final rejeicao in resultado.rejeitados)
              ListTile(
                leading: const Icon(Icons.error_outline, color: Colors.red),
                title: Text(
                  'Linha ${rejeicao.numeroLinha} · ${rejeicao.referenciaIdExterno}',
                ),
                subtitle: Text(rejeicao.motivo),
              ),
          ],
        ],
      ),
    );
  }
}

class _SeletorData extends StatelessWidget {
  final String titulo;
  final DateTime? data;
  final ValueChanged<DateTime> onSelecionado;

  const _SeletorData({
    required this.titulo,
    required this.data,
    required this.onSelecionado,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: () async {
        final selecionado = await showDatePicker(
          context: context,
          initialDate: data ?? DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
        );
        if (selecionado != null) {
          onSelecionado(selecionado);
        }
      },
      child: Text(
        data == null
            ? titulo
            : '$titulo: ${data!.day.toString().padLeft(2, '0')}/${data!.month.toString().padLeft(2, '0')}/${data!.year}',
      ),
    );
  }
}
