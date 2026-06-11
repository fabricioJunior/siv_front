import 'package:core/bloc.dart';
import 'package:estoque/presentation/bloc/lote/lote_bloc.dart';
import 'package:flutter/material.dart';

class CriarLoteBalancoPage extends StatefulWidget {
  final int balancoId;

  const CriarLoteBalancoPage({Key? key, required this.balancoId})
    : super(key: key);

  @override
  State<CriarLoteBalancoPage> createState() => _CriarLoteBalancoPageState();
}

class _CriarLoteBalancoPageState extends State<CriarLoteBalancoPage> {
  late TextEditingController _loteController;
  late TextEditingController _observacaoController;

  @override
  void initState() {
    super.initState();
    _loteController = TextEditingController();
    _observacaoController = TextEditingController();
  }

  @override
  void dispose() {
    _loteController.dispose();
    _observacaoController.dispose();
    super.dispose();
  }

  void _criarLote() {
    if (_loteController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, digite o número do lote')),
      );
      return;
    }

    context.read<LoteBloc>().add(
      CriarLoteEvent(
        balancoId: widget.balancoId,
        lote: _loteController.text,
        observacao: _observacaoController.text.isNotEmpty
            ? _observacaoController.text
            : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Criar Lote')),
      body: BlocListener<LoteBloc, LoteState>(
        listener: (context, state) {
          if (state.status == LoteStatus.success && state.lote != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Lote criado com sucesso')),
            );
            Navigator.of(context).pop(state.lote);
          } else if (state.status == LoteStatus.error &&
              state.message != null) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message!)));
          }
        },
        child: BlocBuilder<LoteBloc, LoteState>(
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
                            Icons.layers_outlined,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Crie um lote para organizar a contagem por etapa, setor ou equipe.',
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
                            controller: _loteController,
                            decoration: const InputDecoration(
                              labelText: 'Número do Lote',
                              border: OutlineInputBorder(),
                              hintText: 'Digite o número identificador do lote',
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: _observacaoController,
                            minLines: 3,
                            maxLines: 5,
                            decoration: const InputDecoration(
                              labelText: 'Observação (opcional)',
                              border: OutlineInputBorder(),
                              hintText: 'Digite uma observação para este lote',
                            ),
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: state.status == LoteStatus.loading
                                  ? null
                                  : _criarLote,
                              icon: state.status == LoteStatus.loading
                                  ? const SizedBox(
                                      height: 18,
                                      width: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Icon(Icons.add_task_outlined),
                              label: Text(
                                state.status == LoteStatus.loading
                                    ? 'Criando lote...'
                                    : 'Criar Lote',
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
