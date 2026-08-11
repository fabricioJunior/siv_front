import 'package:comercial/presentation/blocs/ecommerce_configuracao_bloc/ecommerce_configuracao_bloc.dart';
import 'package:core/bloc.dart';
import 'package:core/injecoes.dart';
import 'package:core/sessao.dart';
import 'package:empresas/presentation/widgets/empresa_seletor.dart';
import 'package:empresas/presentation/widgets/terminal_seletor.dart';
import 'package:financeiro/domain/models/forma_de_pagamento.dart';
import 'package:financeiro/presentation/widgets/formas_de_pagamento_seletor.dart';
import 'package:flutter/material.dart';
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
                      itemsSelecionadosInicial: const [],
                      onEmpresaChanged: (selecionadas) => _emitirEdicao(
                        context,
                        state,
                        empresaEstoqueId:
                            selecionadas.isEmpty ? null : selecionadas.first.id,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TabelasDePrecoSeletor(
                      itemsSelecionadosInicial: const [],
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
                      itemsSelecionadosInicial: const [],
                      onTerminalChanged: (selecionadas) => _emitirEdicao(
                        context,
                        state,
                        terminalId:
                            selecionadas.isEmpty ? null : selecionadas.first.id,
                      ),
                    ),
                    const SizedBox(height: 16),
                    FormasDePagamentoSeletor(
                      tipoOperacaoFiltro: TipoOperacaoFormaPagamento.online,
                      itemsSelecionadosInicial: const [],
                      onFormaDePagamentoChanged: (selecionadas) => _emitirEdicao(
                        context,
                        state,
                        formaDePagamentoId:
                            selecionadas.isEmpty ? null : selecionadas.first.id,
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

  void _emitirEdicao(
    BuildContext context,
    EcommerceConfiguracaoState state, {
    int? empresaEstoqueId,
    int? tabelaDePrecoId,
    int? terminalId,
    int? formaDePagamentoId,
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
            formaDePagamentoId: formaDePagamentoId ?? state.formaDePagamentoId,
          ),
        );
  }
}
