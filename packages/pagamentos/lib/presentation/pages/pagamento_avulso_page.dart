import 'package:core/bloc.dart';
import 'package:core/injecoes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pagamentos/presentation/bloc/pagamento_avulso_bloc/pagamento_avulso_bloc.dart';

class PagamentoAvulsoPage extends StatelessWidget {
  static const _providers = ['infinitypay', 'openpix'];

  final _formKey = GlobalKey<FormState>();

  PagamentoAvulsoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<PagamentoAvulsoBloc>(
      create: (_) => sl<PagamentoAvulsoBloc>()..add(PagamentoAvulsoIniciou()),
      child: BlocListener<PagamentoAvulsoBloc, PagamentoAvulsoState>(
        listenWhen: (previous, current) => previous.step != current.step,
        listener: (context, state) {
          if (state.step == PagamentoAvulsoStep.validacaoInvalida ||
              state.step == PagamentoAvulsoStep.falha) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.erro ?? 'Falha no processamento.')),
            );
          }

          if (state.step == PagamentoAvulsoStep.salvo) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text('Pagamento avulso criado com sucesso.')),
            );
          }
        },
        child: Scaffold(
          appBar: AppBar(title: const Text('Pagamento avulso')),
          floatingActionButton:
              BlocBuilder<PagamentoAvulsoBloc, PagamentoAvulsoState>(
            builder: (context, state) {
              final salvando = state.step == PagamentoAvulsoStep.salvando;
              return FloatingActionButton(
                onPressed: salvando
                    ? null
                    : () {
                        if (_formKey.currentState?.validate() ?? false) {
                          context
                              .read<PagamentoAvulsoBloc>()
                              .add(PagamentoAvulsoSalvou());
                        }
                      },
                child: salvando
                    ? const CircularProgressIndicator.adaptive()
                    : const Icon(Icons.check),
              );
            },
          ),
          body: BlocBuilder<PagamentoAvulsoBloc, PagamentoAvulsoState>(
            builder: (context, state) {
              return SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Forma de pagamento:',
                            style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _providers
                              .map(
                                (provider) => ChoiceChip(
                                  avatar: Icon(
                                    _providerIcon(provider),
                                    size: 18,
                                  ),
                                  label: Text(_providerLabel(provider)),
                                  selected: state.provider == provider,
                                  onSelected: (_) => _onCampoAlterado(
                                    context,
                                    provider: provider,
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                        const SizedBox(height: 12),
                        _campoTexto(
                          context,
                          label: 'Valor (R\$)',
                          initialValue: _formatarReais(state.amount),
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                              RegExp(r'[0-9.,]'),
                            ),
                          ],
                          onChanged: (value) => _onCampoAlterado(
                            context,
                            amount: _reaisParaCentavos(value),
                          ),
                        ),
                        _campoTexto(
                          context,
                          label: 'Descrição',
                          initialValue: state.description ?? '',
                          onChanged: (value) =>
                              _onCampoAlterado(context, description: value),
                        ),
                        _campoTextoSomenteLeitura(
                          context,
                          label: 'Chave de Idempotência',
                          value: state.idempotencyKey ?? '',
                        ),
                        const SizedBox(height: 8),
                        Text('Cliente',
                            style: Theme.of(context).textTheme.titleMedium),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _seletorPessoaPorRota(
                            context,
                            valorAtual: {
                              'nome': state.customerNome ?? '',
                              'documento': state.customerDocumento ?? '',
                              'email': state.customerEmail ?? '',
                              'telefone': state.customerTelefone ?? '',
                            },
                            onSelecionado: (pessoa) {
                              _onCampoAlterado(
                                context,
                                customerNome: pessoa['nome'],
                                customerDocumento: pessoa['documento'],
                                customerEmail: pessoa['email'],
                                customerTelefone: pessoa['telefone'],
                              );
                            },
                            onRemover: () {
                              _onCampoAlterado(
                                context,
                                customerNome: '',
                                customerDocumento: '',
                                customerEmail: '',
                                customerTelefone: '',
                              );
                            },
                          ),
                        ),
                        _campoTextoSomenteLeitura(
                          context,
                          label: 'Nome',
                          value: _textoOuTraco(state.customerNome),
                        ),
                        _campoTextoSomenteLeitura(
                          context,
                          label: 'Documento',
                          value: _textoOuTraco(state.customerDocumento),
                        ),
                        _campoTextoSomenteLeitura(
                          context,
                          label: 'E-mail',
                          value: _textoOuTraco(state.customerEmail),
                        ),
                        _campoTextoSomenteLeitura(
                          context,
                          label: 'Telefone',
                          value: _textoOuTraco(state.customerTelefone),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _campoTexto(
    BuildContext context, {
    required String label,
    required String initialValue,
    required ValueChanged<String> onChanged,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    bool obrigatorio = true,
    int minLines = 1,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        initialValue: initialValue,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        minLines: minLines,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        validator: (value) {
          if (obrigatorio && (value == null || value.trim().isEmpty)) {
            return 'Campo obrigatório';
          }
          return null;
        },
        onChanged: onChanged,
      ),
    );
  }

  Widget _campoTextoSomenteLeitura(
    BuildContext context, {
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        child: SelectableText(
          value,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ),
    );
  }

  Widget _seletorPessoaPorRota(
    BuildContext context, {
    required Map<String, String> valorAtual,
    required ValueChanged<Map<String, String>> onSelecionado,
    required VoidCallback onRemover,
  }) {
    final nome = valorAtual['nome'] ?? '';
    final documento = valorAtual['documento'] ?? '';
    final email = valorAtual['email'] ?? '';
    final telefone = valorAtual['telefone'] ?? '';
    final possuiValor = nome.trim().isNotEmpty ||
        documento.trim().isNotEmpty ||
        email.trim().isNotEmpty ||
        telefone.trim().isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () async {
            final resultado = await Navigator.of(context).pushNamed(
              '/selecionar_pessoa',
              arguments: const {
                'retornarSomenteId': false,
              },
            );

            if (resultado is! Map<String, String>) {
              return;
            }

            final nomeSelecionado = (resultado['nome'] ?? '').trim();
            final documentoSelecionado = (resultado['documento'] ?? '').trim();
            final emailSelecionado = (resultado['email'] ?? '').trim();
            final telefoneSelecionado = (resultado['telefone'] ?? '').trim();

            final camposVazios = <String>[];
            if (nomeSelecionado.isEmpty) camposVazios.add('nome');
            if (documentoSelecionado.isEmpty) camposVazios.add('documento');
            if (emailSelecionado.isEmpty) camposVazios.add('e-mail');
            if (telefoneSelecionado.isEmpty) camposVazios.add('telefone');

            if (camposVazios.isNotEmpty) {
              final campos = camposVazios.join(', ');
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Pessoa selecionada com campos obrigatorios vazios: $campos.',
                    ),
                  ),
                );
              }
              return;
            }

            onSelecionado(resultado);
          },
          borderRadius: BorderRadius.circular(8),
          child: InputDecorator(
            decoration: const InputDecoration(
              labelText: 'Selecionar pessoa',
              border: OutlineInputBorder(),
              suffixIcon: Icon(Icons.search),
            ),
            child: possuiValor
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(nome),
                      if (documento.trim().isNotEmpty)
                        Text(
                          documento,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                    ],
                  )
                : const Text('Opcional: toque para buscar uma pessoa'),
          ),
        ),
        if (possuiValor)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: OutlinedButton.icon(
                onPressed: onRemover,
                icon: const Icon(Icons.person_remove_outlined),
                label: const Text('Remover pessoa selecionada'),
              ),
            ),
          ),
      ],
    );
  }

  IconData _providerIcon(String provider) {
    if (provider == 'infinitypay') {
      return Icons.all_inclusive;
    }

    return Icons.pix;
  }

  String _providerLabel(String provider) {
    if (provider == 'infinitypay') {
      return 'InfinityPay';
    }

    return 'OpenPix';
  }

  String _formatarReais(int? amountInCents) {
    final cents = amountInCents ?? 0;
    final value = (cents / 100).toStringAsFixed(2);
    return value.replaceAll('.', ',');
  }

  int? _reaisParaCentavos(String raw) {
    final normalized = raw.trim().replaceAll('.', '').replaceAll(',', '.');
    if (normalized.isEmpty) {
      return null;
    }

    final parsed = double.tryParse(normalized);
    if (parsed == null) {
      return null;
    }

    return (parsed * 100).round();
  }

  String _textoOuTraco(String? value) {
    if (value == null || value.trim().isEmpty) {
      return '-';
    }
    return value;
  }

  void _onCampoAlterado(
    BuildContext context, {
    String? provider,
    int? amount,
    String? description,
    String? customerNome,
    String? customerDocumento,
    String? customerEmail,
    String? customerTelefone,
  }) {
    context.read<PagamentoAvulsoBloc>().add(
          PagamentoAvulsoCampoAlterado(
            provider: provider,
            amount: amount,
            description: description,
            customerNome: customerNome,
            customerDocumento: customerDocumento,
            customerEmail: customerEmail,
            customerTelefone: customerTelefone,
          ),
        );
  }
}
