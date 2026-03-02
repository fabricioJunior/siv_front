import 'package:core/bloc.dart';
import 'package:core/injecoes.dart';
import 'package:flutter/material.dart';
import 'package:pessoas/models.dart';
import 'package:pessoas/presentation/bloc/endereco_cadastro_bloc/endereco_cadastro_bloc.dart';
import 'package:pessoas/presentation/bloc/enderecos_bloc/enderecos_bloc.dart';
import 'package:pessoas/presentation/pages/endereco_cadastro_page.dart';

class EnderecosPage extends StatelessWidget {
  final int idPessoa;

  const EnderecosPage({super.key, required this.idPessoa});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<EnderecosBloc>(
      create: (_) =>
          sl<EnderecosBloc>()..add(EnderecosIniciou(idPessoa: idPessoa)),
      child: Scaffold(
        appBar: AppBar(title: const Text('Endereços')),
        floatingActionButton: BlocBuilder<EnderecosBloc, EnderecosState>(
          builder: (context, state) {
            final carregando = state is EnderecosCarregarEmProgresso ||
                state is EnderecosCriarEmProgresso ||
                state is EnderecosSalvarEmProgresso ||
                state is EnderecosExcluirEmProgresso;

            return FloatingActionButton(
              onPressed: carregando
                  ? null
                  : () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => MultiBlocProvider(
                            providers: [
                              BlocProvider.value(
                                value: context.read<EnderecosBloc>(),
                              ),
                              BlocProvider(
                                create: (_) => sl<EnderecoCadastroBloc>(),
                              ),
                            ],
                            child: EnderecoCadastroPage(idPessoa: idPessoa),
                          ),
                        ),
                      );
                    },
              child: carregando
                  ? const CircularProgressIndicator.adaptive()
                  : const Icon(Icons.add),
            );
          },
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: BlocBuilder<EnderecosBloc, EnderecosState>(
              builder: (context, state) {
                if (state is EnderecosCarregarEmProgresso) {
                  return const Center(
                      child: CircularProgressIndicator.adaptive());
                }

                if (state.enderecos.isEmpty) {
                  return const Center(
                    child: Text('Nenhum endereço cadastrado.'),
                  );
                }

                return ListView.separated(
                  itemCount: state.enderecos.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final endereco = state.enderecos[index];

                    return Card(
                      child: ListTile(
                        title: Text(
                          '${_tipoEnderecoLabel(endereco.tipoEndereco)} · ${endereco.logradouro}, ${endereco.numero}',
                        ),
                        subtitle: Text(
                          '${endereco.bairro} · ${endereco.municipio}/${endereco.uf}\nCEP: ${endereco.cep}',
                        ),
                        isThreeLine: true,
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              onPressed: () async {
                                await _EnderecoModal.show(
                                  context: context,
                                  endereco: endereco,
                                );
                              },
                              icon: const Icon(Icons.edit),
                            ),
                            IconButton(
                              onPressed: endereco.id == null
                                  ? null
                                  : () {
                                      context.read<EnderecosBloc>().add(
                                            EnderecosExcluiuEndereco(
                                              idEndereco: endereco.id!,
                                            ),
                                          );
                                    },
                              icon: const Icon(Icons.delete_outline),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  String _tipoEnderecoLabel(TipoEndereco tipo) {
    switch (tipo) {
      case TipoEndereco.comercial:
        return 'Comercial';
      case TipoEndereco.residencial:
        return 'Residencial';
    }
  }
}

class _EnderecoModal extends StatefulWidget {
  final Endereco? endereco;

  const _EnderecoModal({this.endereco});

  static Future<Endereco?> show({
    required BuildContext context,
    Endereco? endereco,
  }) {
    return showModalBottomSheet<Endereco>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _EnderecoModal(endereco: endereco),
    );
  }

  @override
  State<_EnderecoModal> createState() => _EnderecoModalState();
}

class _EnderecoModalState extends State<_EnderecoModal> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _cepController;
  late final TextEditingController _logradouroController;
  late final TextEditingController _numeroController;
  late final TextEditingController _complementoController;
  late final TextEditingController _bairroController;
  late final TextEditingController _municipioController;
  late final TextEditingController _ufController;
  late final TextEditingController _paisController;
  late TipoEndereco _tipoEndereco;
  late bool _principal;

  @override
  void initState() {
    super.initState();
    final endereco = widget.endereco;
    _tipoEndereco = endereco?.tipoEndereco ?? TipoEndereco.residencial;
    _principal = endereco?.principal ?? false;
    _cepController = TextEditingController(text: endereco?.cep ?? '');
    _logradouroController =
        TextEditingController(text: endereco?.logradouro ?? '');
    _numeroController = TextEditingController(text: endereco?.numero ?? '');
    _complementoController =
        TextEditingController(text: endereco?.complemento ?? '');
    _bairroController = TextEditingController(text: endereco?.bairro ?? '');
    _municipioController =
        TextEditingController(text: endereco?.municipio ?? '');
    _ufController = TextEditingController(text: endereco?.uf ?? '');
    _paisController = TextEditingController(text: endereco?.pais ?? 'Brasil');
  }

  @override
  void dispose() {
    _cepController.dispose();
    _logradouroController.dispose();
    _numeroController.dispose();
    _complementoController.dispose();
    _bairroController.dispose();
    _municipioController.dispose();
    _ufController.dispose();
    _paisController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<EnderecosBloc, EnderecosState>(
      listener: (context, state) {
        if (state is EnderecosSalvarSucesso) {
          Navigator.of(context).pop();
        } else if (state is EnderecosSalvarFalha) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Nao foi possivel atualizar o endereco.'),
            ),
          );
        }
      },
      child: Padding(
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(8),
              topRight: Radius.circular(8),
            ),
          ),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.endereco == null
                        ? 'Novo endereço'
                        : 'Editar endereço',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<TipoEndereco>(
                    initialValue: _tipoEndereco,
                    items: const [
                      DropdownMenuItem(
                        value: TipoEndereco.residencial,
                        child: Text('Residencial'),
                      ),
                      DropdownMenuItem(
                        value: TipoEndereco.comercial,
                        child: Text('Comercial'),
                      ),
                    ],
                    onChanged: (value) {
                      if (value == null) return;
                      setState(() {
                        _tipoEndereco = value;
                      });
                    },
                    decoration:
                        const InputDecoration(labelText: 'Tipo de endereço'),
                  ),
                  const SizedBox(height: 8),
                  CheckboxListTile(
                    value: _principal,
                    onChanged: (value) {
                      if (value == null) return;
                      setState(() {
                        _principal = value;
                      });
                    },
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Endereço principal'),
                  ),
                  const SizedBox(height: 8),
                  _campo(_cepController, 'CEP'),
                  _campo(_logradouroController, 'Logradouro'),
                  _campo(_numeroController, 'Número'),
                  _campo(_complementoController, 'Complemento'),
                  _campo(_bairroController, 'Bairro'),
                  _campo(_municipioController, 'Município'),
                  _campo(_ufController, 'UF'),
                  _campo(_paisController, 'País'),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: BlocBuilder<EnderecosBloc, EnderecosState>(
                      builder: (context, state) {
                        final salvando = state is EnderecosSalvarEmProgresso;

                        return ElevatedButton.icon(
                          onPressed: salvando
                              ? null
                              : () {
                                  if (!(_formKey.currentState?.validate() ??
                                      false)) {
                                    return;
                                  }

                                  final endereco = Endereco.create(
                                    id: widget.endereco?.id,
                                    principal: _principal,
                                    tipoEndereco: _tipoEndereco,
                                    cep: _cepController.text.trim(),
                                    logradouro:
                                        _logradouroController.text.trim(),
                                    numero: _numeroController.text.trim(),
                                    complemento:
                                        _complementoController.text.trim(),
                                    bairro: _bairroController.text.trim(),
                                    municipio: _municipioController.text.trim(),
                                    uf: _ufController.text.trim(),
                                    pais: _paisController.text.trim(),
                                  );

                                  if (widget.endereco == null) {
                                    Navigator.of(context).pop(endereco);
                                    return;
                                  }

                                  context.read<EnderecosBloc>().add(
                                        EnderecosAtualizouEndereco(
                                          endereco: endereco,
                                        ),
                                      );
                                },
                          icon: salvando
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.check),
                          label: const Text('Confirmar'),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _campo(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(labelText: label),
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return 'Informe $label';
          }
          return null;
        },
      ),
    );
  }
}
