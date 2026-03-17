import 'package:core/bloc.dart';
import 'package:core/injecoes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:produtos/presentation.dart';

class ReferenciaCadastroModal extends StatefulWidget {
  const ReferenciaCadastroModal({super.key});

  static Future<bool?> show({required BuildContext context}) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const ReferenciaCadastroModal(),
    );
  }

  @override
  State<ReferenciaCadastroModal> createState() =>
      _ReferenciaCadastroModalState();
}

class _ReferenciaCadastroModalState extends State<ReferenciaCadastroModal> {
  final _idController = TextEditingController();
  final _nomeController = TextEditingController();
  final _unidadeMedidaController = TextEditingController();
  final _descricaoController = TextEditingController();
  final _composicaoController = TextEditingController();
  final _cuidadosController = TextEditingController();
  final _categoriaSearchController = TextEditingController();
  final _subCategoriaSearchController = TextEditingController();

  String _categoriaQuery = '';
  String _subCategoriaQuery = '';

  @override
  void dispose() {
    _idController.dispose();
    _nomeController.dispose();
    _unidadeMedidaController.dispose();
    _descricaoController.dispose();
    _composicaoController.dispose();
    _cuidadosController.dispose();
    _categoriaSearchController.dispose();
    _subCategoriaSearchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ReferenciaCadastroBloc>(
      create: (context) =>
          sl<ReferenciaCadastroBloc>()..add(ReferenciaCadastroIniciou()),
      child: BlocBuilder<ReferenciaCadastroBloc, ReferenciaCadastroState>(
        builder: (context, state) {
          _syncControllers(state);

          return SizedBox(
            height: MediaQuery.of(context).size.height,
            child: Material(
              color: Colors.white,
              child: SafeArea(
                child: Padding(
                  padding: EdgeInsets.only(
                    left: 16,
                    right: 16,
                    top: 16,
                    bottom: MediaQuery.of(context).viewInsets.bottom + 16,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildHeader(context, state),
                      const SizedBox(height: 12),
                      if (state.carregandoCategorias ||
                          state.carregandoSubCategorias)
                        const Padding(
                          padding: EdgeInsets.all(24),
                          child: Center(
                            child: CircularProgressIndicator.adaptive(),
                          ),
                        )
                      else
                        Expanded(child: _buildStepContent(context, state)),
                      if (state.mensagem != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            state.mensagem!,
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                      const SizedBox(height: 16),
                      _buildActions(context, state),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _syncControllers(ReferenciaCadastroState state) {
    final idText = state.referenciaId?.toString() ?? '';
    if (_idController.text != idText) {
      _idController.text = idText;
    }

    final nomeText = state.nome ?? '';
    if (_nomeController.text != nomeText) {
      _nomeController.text = nomeText;
    }

    if (_unidadeMedidaController.text != state.unidadeMedida) {
      _unidadeMedidaController.text = state.unidadeMedida;
    }
    if (_descricaoController.text != state.descricao) {
      _descricaoController.text = state.descricao;
    }
    if (_composicaoController.text != state.composicao) {
      _composicaoController.text = state.composicao;
    }
    if (_cuidadosController.text != state.cuidados) {
      _cuidadosController.text = state.cuidados;
    }
  }

  Widget _buildHeader(BuildContext context, ReferenciaCadastroState state) {
    final titulo = switch (state.step) {
      ReferenciaCadastroStep.categoria => 'Selecionar categoria',
      ReferenciaCadastroStep.subCategoria => 'Selecionar sub-categoria',
      ReferenciaCadastroStep.id => 'Definir ID da referencia',
      ReferenciaCadastroStep.nome => 'Definir nome da referencia',
      ReferenciaCadastroStep.resumo => 'Resumo da referencia',
    };

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Cadastrar Modelo - Referencia',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 4),
              Text(titulo, style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
        ),
        IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }

  Widget _buildStepContent(
    BuildContext context,
    ReferenciaCadastroState state,
  ) {
    switch (state.step) {
      case ReferenciaCadastroStep.categoria:
        return _buildCategoriaStep(context, state);
      case ReferenciaCadastroStep.subCategoria:
        return _buildSubCategoriaStep(context, state);
      case ReferenciaCadastroStep.id:
        return _buildIdStep(context, state);
      case ReferenciaCadastroStep.nome:
        return _buildNomeStep(context, state);
      case ReferenciaCadastroStep.resumo:
        return _buildResumoStep(context, state);
    }
  }

  Widget _buildCategoriaStep(
    BuildContext context,
    ReferenciaCadastroState state,
  ) {
    final categoriasFiltradas = state.categorias
        .where(
          (categoria) => categoria.nome.toLowerCase().contains(
            _categoriaQuery.toLowerCase().trim(),
          ),
        )
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _categoriaSearchController,
          decoration: const InputDecoration(
            labelText: 'Buscar categoria',
            prefixIcon: Icon(Icons.search),
            border: OutlineInputBorder(),
          ),
          onChanged: (value) {
            setState(() {
              _categoriaQuery = value;
            });
          },
        ),
        const SizedBox(height: 12),
        Expanded(
          child: categoriasFiltradas.isEmpty
              ? _buildEmptyList('Nenhuma categoria encontrada')
              : ListView.builder(
                  itemCount: categoriasFiltradas.length,
                  itemBuilder: (context, index) {
                    final categoria = categoriasFiltradas[index];
                    return CheckboxListTile(
                      value: state.categoria?.id == categoria.id,
                      title: Text(categoria.nome),
                      onChanged: (_) {
                        context.read<ReferenciaCadastroBloc>().add(
                          ReferenciaCadastroCategoriaSelecionada(
                            categoria: categoria,
                          ),
                        );
                      },
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildSubCategoriaStep(
    BuildContext context,
    ReferenciaCadastroState state,
  ) {
    final subCategoriasFiltradas = state.subCategorias
        .where(
          (subCategoria) => subCategoria.nome.toLowerCase().contains(
            _subCategoriaQuery.toLowerCase().trim(),
          ),
        )
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _subCategoriaSearchController,
          decoration: const InputDecoration(
            labelText: 'Buscar sub-categoria',
            prefixIcon: Icon(Icons.search),
            border: OutlineInputBorder(),
          ),
          onChanged: (value) {
            setState(() {
              _subCategoriaQuery = value;
            });
          },
        ),
        const SizedBox(height: 12),
        Expanded(
          child: subCategoriasFiltradas.isEmpty
              ? _buildEmptyList('Nenhuma sub-categoria encontrada')
              : ListView.builder(
                  itemCount: subCategoriasFiltradas.length,
                  itemBuilder: (context, index) {
                    final subCategoria = subCategoriasFiltradas[index];
                    return CheckboxListTile(
                      value: state.subCategoria?.id == subCategoria.id,
                      title: Text(subCategoria.nome),
                      onChanged: (_) {
                        context.read<ReferenciaCadastroBloc>().add(
                          ReferenciaCadastroSubCategoriaSelecionada(
                            subCategoria: subCategoria,
                          ),
                        );
                      },
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildIdStep(BuildContext context, ReferenciaCadastroState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _idController,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: const InputDecoration(
            labelText: 'ID da referencia',
            border: OutlineInputBorder(),
          ),
          onChanged: (value) {
            final id = int.tryParse(value);
            context.read<ReferenciaCadastroBloc>().add(
              ReferenciaCadastroIdAlterado(id: id),
            );
          },
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: () {
            context.read<ReferenciaCadastroBloc>().add(
              ReferenciaCadastroGerarId(),
            );
          },
          icon: const Icon(Icons.auto_awesome),
          label: const Text('Gerar automaticamente'),
        ),
      ],
    );
  }

  Widget _buildNomeStep(BuildContext context, ReferenciaCadastroState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _nomeController,
          decoration: const InputDecoration(
            labelText: 'Nome da referencia',
            border: OutlineInputBorder(),
          ),
          onChanged: (value) {
            context.read<ReferenciaCadastroBloc>().add(
              ReferenciaCadastroNomeAlterado(nome: value),
            );
          },
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: () {
            context.read<ReferenciaCadastroBloc>().add(
              ReferenciaCadastroGerarNome(),
            );
          },
          icon: const Icon(Icons.auto_awesome),
          label: const Text('Sugerir nome'),
        ),
        const SizedBox(height: 16),
        Text(
          'Informacoes opcionais',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _unidadeMedidaController,
          decoration: const InputDecoration(
            labelText: 'Unidade de medida',
            border: OutlineInputBorder(),
            hintText: 'Ex: unidade, metro, kg',
          ),
          onChanged: (value) {
            context.read<ReferenciaCadastroBloc>().add(
              ReferenciaCadastroUnidadeMedidaAlterada(unidadeMedida: value),
            );
          },
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _descricaoController,
          minLines: 2,
          maxLines: 4,
          decoration: const InputDecoration(
            labelText: 'Descricao',
            border: OutlineInputBorder(),
          ),
          onChanged: (value) {
            context.read<ReferenciaCadastroBloc>().add(
              ReferenciaCadastroDescricaoAlterada(descricao: value),
            );
          },
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _composicaoController,
          minLines: 2,
          maxLines: 4,
          decoration: const InputDecoration(
            labelText: 'Composicao',
            border: OutlineInputBorder(),
          ),
          onChanged: (value) {
            context.read<ReferenciaCadastroBloc>().add(
              ReferenciaCadastroComposicaoAlterada(composicao: value),
            );
          },
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _cuidadosController,
          minLines: 2,
          maxLines: 4,
          decoration: const InputDecoration(
            labelText: 'Cuidados',
            border: OutlineInputBorder(),
          ),
          onChanged: (value) {
            context.read<ReferenciaCadastroBloc>().add(
              ReferenciaCadastroCuidadosAlterados(cuidados: value),
            );
          },
        ),
      ],
    );
  }

  Widget _buildResumoStep(BuildContext context, ReferenciaCadastroState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ResumoItem(label: 'Categoria', value: state.categoria?.nome ?? '- '),
        _ResumoItem(
          label: 'Sub-categoria',
          value: state.subCategoria?.nome ?? 'Nao informado',
        ),
        _ResumoItem(label: 'ID', value: state.referenciaId?.toString() ?? '-'),
        _ResumoItem(label: 'Nome', value: state.nome ?? '-'),
        _ResumoItem(
          label: 'Unidade de medida',
          value: state.unidadeMedida.trim().isEmpty
              ? 'Nao informada'
              : state.unidadeMedida,
        ),
        _ResumoItem(
          label: 'Descricao',
          value: state.descricao.trim().isEmpty
              ? 'Nao informada'
              : state.descricao,
        ),
        _ResumoItem(
          label: 'Composicao',
          value: state.composicao.trim().isEmpty
              ? 'Nao informada'
              : state.composicao,
        ),
        _ResumoItem(
          label: 'Cuidados',
          value: state.cuidados.trim().isEmpty
              ? 'Nao informados'
              : state.cuidados,
        ),
      ],
    );
  }

  Widget _buildEmptyList(String message) {
    return Center(
      child: Text(message, style: TextStyle(color: Colors.grey[600])),
    );
  }

  Widget _buildActions(BuildContext context, ReferenciaCadastroState state) {
    if (state.step == ReferenciaCadastroStep.resumo) {
      return Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () {
                context.read<ReferenciaCadastroBloc>().add(
                  ReferenciaCadastroReiniciar(),
                );
              },
              child: const Text('Criar nova referencia'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(true);
                Navigator.of(context).pushNamed(
                  '/referencia',
                  arguments: {'idReferencia': state.referenciaId},
                );
              },
              child: const Text('Ir para pagina da referencia'),
            ),
          ),
        ],
      );
    }

    return Row(
      children: [
        TextButton(
          onPressed: state.step == ReferenciaCadastroStep.categoria
              ? null
              : () {
                  context.read<ReferenciaCadastroBloc>().add(
                    ReferenciaCadastroVoltar(),
                  );
                },
          child: const Text('Voltar'),
        ),
        const Spacer(),
        ElevatedButton(
          onPressed: () {
            context.read<ReferenciaCadastroBloc>().add(
              ReferenciaCadastroProximo(),
            );
          },
          child: const Text('Continuar'),
        ),
      ],
    );
  }
}

class _ResumoItem extends StatelessWidget {
  final String label;
  final String value;

  const _ResumoItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
