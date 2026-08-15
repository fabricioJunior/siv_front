import 'package:comercial/presentation/blocs/ecommerce_configuracao_bloc/ecommerce_configuracao_bloc.dart';
import 'package:core/bloc.dart';
import 'package:core/injecoes.dart';
import 'package:core/seletores.dart';
import 'package:core/sessao.dart';
import 'package:empresas/presentation/widgets/empresa_seletor.dart';
import 'package:empresas/presentation/widgets/terminal_seletor.dart';
import 'package:financeiro/domain/models/forma_de_pagamento.dart';
import 'package:financeiro/presentation/widgets/formas_de_pagamento_seletor.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:precos/presentation/widgets/tabelas_de_preco_seletor.dart';

// Página de configuração do e-commerce (não é modal -- tem mais campos que o padrão XModal do
// projeto). Segue o mesmo template de rascunho-no-state do TabelaDePrecoModal: cada onChanged
// reemite os campos juntos via EcommerceConfiguracaoEditou, e o botão final decide create/update
// olhando state.id.
class EcommerceConfiguracaoPage extends StatefulWidget {
  final int? empresaId;
  final int? ecommerceId;

  const EcommerceConfiguracaoPage({super.key, this.empresaId, this.ecommerceId});

  @override
  State<EcommerceConfiguracaoPage> createState() =>
      _EcommerceConfiguracaoPageState();
}

class _EcommerceConfiguracaoPageState
    extends State<EcommerceConfiguracaoPage> {
  final _formKey = GlobalKey<FormState>();
  final _tituloController = TextEditingController();
  final _subtituloController = TextEditingController();
  final _descricaoController = TextEditingController();
  final _iconeController = TextEditingController();

  late final int _empresaId;

  @override
  void initState() {
    super.initState();
    _empresaId =
        widget.empresaId ?? sl<IAcessoGlobalSessao>().empresaIdDaSessao ?? 0;
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _subtituloController.dispose();
    _descricaoController.dispose();
    _iconeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<EcommerceConfiguracaoBloc>(
      create: (context) => sl<EcommerceConfiguracaoBloc>()
        ..add(
          EcommerceConfiguracaoIniciou(
            empresaId: _empresaId,
            ecommerceId: widget.ecommerceId,
          ),
        ),
      child: Scaffold(
        appBar: AppBar(title: const Text('Configuração do e-commerce')),
        body: BlocListener<EcommerceConfiguracaoBloc, EcommerceConfiguracaoState>(
          listener: (context, state) {
            if (state.step == EcommerceConfiguracaoStep.criado ||
                state.step == EcommerceConfiguracaoStep.salvo) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Configuração salva.')),
              );
            }
            if (state.step == EcommerceConfiguracaoStep.falha &&
                state.erro != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.erro!)),
              );
            }
          },
          child: BlocBuilder<EcommerceConfiguracaoBloc, EcommerceConfiguracaoState>(
            builder: (context, state) {
              if (state.step == EcommerceConfiguracaoStep.carregando ||
                  state.step == EcommerceConfiguracaoStep.inicial) {
                return const Center(child: CircularProgressIndicator.adaptive());
              }

              if (state.titulo != null && _tituloController.text.isEmpty) {
                _tituloController.text = state.titulo!;
              }
              if (state.subtitulo != null && _subtituloController.text.isEmpty) {
                _subtituloController.text = state.subtitulo!;
              }
              if (state.descricao != null && _descricaoController.text.isEmpty) {
                _descricaoController.text = state.descricao!;
              }
              if (state.icone != null && _iconeController.text.isEmpty) {
                _iconeController.text = state.icone!;
              }

              return Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    if (state.id != null) ...[
                      _CardIntegracao(ecommerceId: state.id!),
                      const SizedBox(height: 16),
                    ],
                    const Text('Título'),
                    TextFormField(
                      controller: _tituloController,
                      validator: (value) => (value == null || value.trim().isEmpty)
                          ? 'Informe o título'
                          : null,
                      onChanged: (value) => _emitirEdicao(context, state),
                    ),
                    const SizedBox(height: 12),
                    const Text('Subtítulo'),
                    TextFormField(
                      controller: _subtituloController,
                      onChanged: (value) => _emitirEdicao(context, state),
                    ),
                    const SizedBox(height: 12),
                    const Text('Descrição'),
                    TextFormField(
                      controller: _descricaoController,
                      maxLines: 3,
                      onChanged: (value) => _emitirEdicao(context, state),
                    ),
                    const SizedBox(height: 12),
                    // Não há uploader de imagem reutilizável no projeto -- fallback simples de URL
                    // até existir uma tela/serviço de upload dedicado.
                    const Text('Ícone (URL)'),
                    TextFormField(
                      controller: _iconeController,
                      decoration: const InputDecoration(
                        hintText: 'https://...',
                      ),
                      onChanged: (value) => _emitirEdicao(context, state),
                    ),
                    const SizedBox(height: 16),
                    EmpresaSeletor(
                      titulo: 'Empresa de estoque',
                      itemsSelecionadosInicial:
                          _idInicial(state.empresaEstoqueId),
                      onEmpresaChanged: (selecionadas) => _emitirEdicao(
                        context,
                        state,
                        empresaEstoqueId:
                            selecionadas.isEmpty ? null : selecionadas.first.id,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TabelasDePrecoSeletor(
                      itemsSelecionadosInicial:
                          _idInicial(state.tabelaDePrecoId),
                      onTabelaDePrecoChanged: (selecionadas) => _emitirEdicao(
                        context,
                        state,
                        tabelaDePrecoId:
                            selecionadas.isEmpty ? null : selecionadas.first.id,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TerminalSeletor(
                      empresaId: _empresaId,
                      tipoFiltro: 'ecommerce',
                      itemsSelecionadosInicial: _idInicial(state.terminalId),
                      onTerminalChanged: (selecionadas) => _emitirEdicao(
                        context,
                        state,
                        terminalId:
                            selecionadas.isEmpty ? null : selecionadas.first.id,
                      ),
                    ),
                    const SizedBox(height: 16),
                    FormasDePagamentoSeletor(
                      modo: FormasDePagamentoSeletorModo.multipla,
                      tipoOperacaoFiltro: TipoOperacaoFormaPagamento.online,
                      itemsSelecionadosInicial: state.formasDePagamentoIds
                          .map((id) => SelectData(id: id, nome: '', data: const {}))
                          .toList(),
                      onFormaDePagamentoChanged: (selecionadas) => _emitirEdicao(
                        context,
                        state,
                        formasDePagamentoIds: selecionadas
                            .map((forma) => forma.id)
                            .whereType<int>()
                            .toList(),
                      ),
                    ),
                    const SizedBox(height: 24),
                    FilledButton.icon(
                      onPressed: () {
                        if (_formKey.currentState?.validate() ?? false) {
                          context
                              .read<EcommerceConfiguracaoBloc>()
                              .add(const EcommerceConfiguracaoSalvou());
                        }
                      },
                      icon: const Icon(Icons.check),
                      label: const Text('Salvar'),
                    ),
                    if (state.id != null) ...[
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        onPressed: () => Navigator.of(context).pushNamed(
                          '/ecommerce_referencias',
                          arguments: {'ecommerceId': state.id},
                        ),
                        icon: const Icon(Icons.shopping_bag_outlined),
                        label: const Text('Produtos no site'),
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        onPressed: () =>
                            Navigator.of(context).pushNamed('/promocoes'),
                        icon: const Icon(Icons.local_offer_outlined),
                        label: const Text(
                          'Promoções (marque "Exclusiva do e-commerce" para ofertas só do site)',
                        ),
                      ),
                    ],
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  // Seletores só usam o id de itemsSelecionadosInicial pra marcar seleção na lista que eles
  // próprios carregam -- não precisa buscar o objeto completo aqui.
  List<SelectData> _idInicial(int? id) =>
      id == null ? const [] : [SelectData(id: id, nome: '', data: const {})];

  void _emitirEdicao(
    BuildContext context,
    EcommerceConfiguracaoState state, {
    int? empresaEstoqueId,
    int? tabelaDePrecoId,
    int? terminalId,
    List<int>? formasDePagamentoIds,
  }) {
    context.read<EcommerceConfiguracaoBloc>().add(
          EcommerceConfiguracaoEditou(
            titulo: _tituloController.text,
            subtitulo: _subtituloController.text,
            descricao: _descricaoController.text,
            icone: _iconeController.text,
            empresaEstoqueId: empresaEstoqueId ?? state.empresaEstoqueId,
            tabelaDePrecoId: tabelaDePrecoId ?? state.tabelaDePrecoId,
            terminalId: terminalId ?? state.terminalId,
            formasDePagamentoIds:
                formasDePagamentoIds ?? state.formasDePagamentoIds,
          ),
        );
  }
}

// Card com os dados que quem integra o site externo precisa: o id real do e-commerce (não
// confundir com empresaId) e o endpoint público do catálogo já montado com esse id.
class _CardIntegracao extends StatelessWidget {
  final int ecommerceId;

  const _CardIntegracao({required this.ecommerceId});

  String get _endpoint =>
      '/v1/e-commerce/$ecommerceId/catalogos/referencias?page=1&limit=24';

  void _copiar(BuildContext context, String texto, String rotulo) {
    Clipboard.setData(ClipboardData(text: texto));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$rotulo copiado.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.integration_instructions_outlined, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Dados para integração',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ],
            ),
            const SizedBox(height: 8),
            _linha(
              context,
              label: 'ID do e-commerce (use este, não o da empresa)',
              valor: '$ecommerceId',
            ),
            const SizedBox(height: 4),
            _linha(
              context,
              label: 'Endpoint do catálogo público',
              valor: _endpoint,
            ),
          ],
        ),
      ),
    );
  }

  Widget _linha(
    BuildContext context, {
    required String label,
    required String valor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: Theme.of(context).textTheme.labelSmall),
              SelectableText(
                valor,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(fontFamily: 'monospace'),
              ),
            ],
          ),
        ),
        IconButton(
          icon: const Icon(Icons.copy, size: 18),
          tooltip: 'Copiar',
          onPressed: () => _copiar(context, valor, label),
        ),
      ],
    );
  }
}
