import 'package:core/bloc.dart';
import 'package:core/injecoes.dart';
import 'package:financeiro/presentation.dart';
import 'package:flutter/material.dart';

class CancelamentoRomaneioPage extends StatefulWidget {
  final int? idRomaneio;

  const CancelamentoRomaneioPage({
    super.key,
    required this.idRomaneio,
  });

  @override
  State<CancelamentoRomaneioPage> createState() =>
      _CancelamentoRomaneioPageState();
}

class _CancelamentoRomaneioPageState extends State<CancelamentoRomaneioPage> {
  final _formKey = GlobalKey<FormState>();
  final _motivoController = TextEditingController();

  @override
  void dispose() {
    _motivoController.dispose();
    super.dispose();
  }

  Future<bool> _voltarSemCancelar() async {
    if (mounted) {
      Navigator.of(context).pop(false);
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<CancelamentoRomaneioBloc>(
      create: (_) => sl<CancelamentoRomaneioBloc>()
        ..add(CancelamentoRomaneioIniciou(idRomaneio: widget.idRomaneio)),
      child: BlocListener<CancelamentoRomaneioBloc, CancelamentoRomaneioState>(
        listenWhen: (previous, current) =>
            previous.step != current.step || previous.erro != current.erro,
        listener: (context, state) {
          if (state.step == CancelamentoRomaneioStep.cancelado) {
            Navigator.of(context).pop(true);
            return;
          }

          if ((state.step == CancelamentoRomaneioStep.falha ||
                  state.step == CancelamentoRomaneioStep.validacaoInvalida) &&
              state.erro != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.erro!)),
            );
          }
        },
        child:
            BlocBuilder<CancelamentoRomaneioBloc, CancelamentoRomaneioState>(
          builder: (context, state) {
            _sincronizarController(state);
            final processando =
                state.step == CancelamentoRomaneioStep.cancelando;

            return WillPopScope(
              onWillPop: _voltarSemCancelar,
              child: Scaffold(
                appBar: AppBar(
                  leading: IconButton(
                    onPressed: _voltarSemCancelar,
                    icon: const Icon(Icons.arrow_back),
                  ),
                  title: const Text('Cancelar romaneio'),
                ),
                body: SafeArea(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Card(
                            child: ListTile(
                              leading: const Icon(Icons.receipt_long_outlined),
                              title: const Text('Romaneio'),
                              subtitle: Text(
                                'ID do romaneio: ${state.idRomaneio ?? widget.idRomaneio ?? '-'}',
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _motivoController,
                            readOnly: processando,
                            minLines: 3,
                            maxLines: 5,
                            decoration: const InputDecoration(
                              labelText: 'Motivo do cancelamento',
                              hintText: 'Informe o motivo',
                              prefixIcon: Icon(Icons.edit_note_outlined),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Informe o motivo do cancelamento';
                              }
                              return null;
                            },
                            onChanged: (value) {
                              context.read<CancelamentoRomaneioBloc>().add(
                                    CancelamentoRomaneioMotivoAlterado(value),
                                  );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                bottomNavigationBar: SafeArea(
                  minimum: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  child: FilledButton.icon(
                    onPressed: processando
                        ? null
                        : () {
                            if (_formKey.currentState?.validate() ?? false) {
                              context.read<CancelamentoRomaneioBloc>().add(
                                    const CancelamentoRomaneioConfirmado(),
                                  );
                            }
                          },
                    icon: processando
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.cancel_outlined),
                    label: const Text('Confirmar cancelamento'),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _sincronizarController(CancelamentoRomaneioState state) {
    if (_motivoController.text == state.motivo) {
      return;
    }

    _motivoController.value = TextEditingValue(
      text: state.motivo,
      selection: TextSelection.collapsed(offset: state.motivo.length),
    );
  }
}