import 'package:estoque/presentation/bloc/balanco/balanco_bloc.dart';
import 'package:core/bloc.dart';
import 'package:flutter/material.dart';

class CriarBalancoPage extends StatefulWidget {
  const CriarBalancoPage({super.key});

  @override
  State<CriarBalancoPage> createState() => _CriarBalancoPageState();
}

class _CriarBalancoPageState extends State<CriarBalancoPage> {
  late TextEditingController _observacaoController;

  @override
  void initState() {
    super.initState();
    _observacaoController = TextEditingController();
  }

  @override
  void dispose() {
    _observacaoController.dispose();
    super.dispose();
  }

  void _criarBalanco() {
    context.read<BalancoBloc>().add(
      CriarBalancoEvent(
        observacao: _observacaoController.text.isNotEmpty
            ? _observacaoController.text
            : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Criar Balanço')),
      body: BlocListener<BalancoBloc, BalancoState>(
        listener: (context, state) {
          if (state is BalancoCreated) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Balanço criado com sucesso')),
            );
            Navigator.of(context).pop(state.balanco);
          } else if (state is BalancoError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        child: BlocBuilder<BalancoBloc, BalancoState>(
          builder: (context, state) {
            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(color: Colors.grey.shade300),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Adicione uma observação para ajudar na identificação do balanço. Esse campo é opcional.',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(color: Colors.grey.shade300),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          TextField(
                            controller: _observacaoController,
                            minLines: 3,
                            maxLines: 5,
                            decoration: const InputDecoration(
                              labelText: 'Observação (opcional)',
                              border: OutlineInputBorder(),
                              hintText:
                                  'Digite uma observação para este balanço',
                            ),
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton.icon(
                              onPressed: state is BalancoLoading
                                  ? null
                                  : _criarBalanco,
                              icon: state is BalancoLoading
                                  ? const SizedBox(
                                      height: 18,
                                      width: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Icon(Icons.check_circle_outline),
                              label: Text(
                                state is BalancoLoading
                                    ? 'Criando balanço...'
                                    : 'Criar Balanço',
                              ),
                            ),
                          ),
                        ],
                      ),
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
