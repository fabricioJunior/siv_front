import 'package:core/bloc.dart';
import 'package:core/injecoes.dart';
import 'package:flutter/material.dart';
import 'package:promocoes/models.dart';
import 'package:promocoes/presentation.dart';

class PromocaoFormPage extends StatefulWidget {
  final int? idPromocao;

  const PromocaoFormPage({super.key, this.idPromocao});

  @override
  State<PromocaoFormPage> createState() => _PromocaoFormPageState();
}

class _PromocaoFormPageState extends State<PromocaoFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _descricaoController = TextEditingController();
  final _limiteUnidadesVendidasController = TextEditingController();

  @override
  void dispose() {
    _nomeController.dispose();
    _descricaoController.dispose();
    _limiteUnidadesVendidasController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<PromocaoBloc>(
      create: (_) => sl<PromocaoBloc>()
        ..add(PromocaoIniciou(idPromocao: widget.idPromocao)),
      child: BlocListener<PromocaoBloc, PromocaoState>(
        listenWhen: (previous, current) => previous.step != current.step,
        listener: (context, state) {
          if (state.step == PromocaoStep.validacaoInvalida ||
              state.step == PromocaoStep.falha) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.erro ?? 'Falha ao salvar promoção.')),
            );
          }

          if (state.step == PromocaoStep.criado ||
              state.step == PromocaoStep.salvo) {
            Navigator.of(context).pop(true);
          }
        },
        child: Scaffold(
          appBar: AppBar(
            title: Text(
              widget.idPromocao == null ? 'Nova promoção' : 'Editar promoção',
            ),
          ),
          floatingActionButton: BlocBuilder<PromocaoBloc, PromocaoState>(
            builder: (context, state) {
              final salvando = state.step == PromocaoStep.salvando ||
                  state.step == PromocaoStep.carregando;

              return FloatingActionButton(
                onPressed: salvando
                    ? null
                    : () {
                        if (_formKey.currentState?.validate() ?? false) {
                          context.read<PromocaoBloc>().add(PromocaoSalvou());
                        }
                      },
                child: salvando
                    ? const CircularProgressIndicator.adaptive()
                    : const Icon(Icons.check),
              );
            },
          ),
          body: BlocBuilder<PromocaoBloc, PromocaoState>(
            builder: (context, state) {
              if (state.step == PromocaoStep.carregando) {
                return const Center(child: CircularProgressIndicator.adaptive());
              }

              _sincronizarControllers(state);

              return SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Configuração básica',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _nomeController,
                          decoration: const InputDecoration(labelText: 'Nome'),
                          validator: (value) => (value == null || value.trim().isEmpty)
                              ? 'Informe o nome'
                              : null,
                          onChanged: (value) =>
                              _onCampoAlterado(context, nome: value),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _descricaoController,
                          decoration: const InputDecoration(
                            labelText: 'Descrição (opcional)',
                          ),
                          onChanged: (value) =>
                              _onCampoAlterado(context, descricao: value),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _SeletorData(
                                titulo: 'Início',
                                data: state.dataInicio,
                                onSelecionado: (data) =>
                                    _onCampoAlterado(context, dataInicio: data),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _SeletorData(
                                titulo: 'Fim',
                                data: state.dataFim,
                                onSelecionado: (data) =>
                                    _onCampoAlterado(context, dataFim: data),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        RegraDescontoFormWidget(
                          tipoDesconto: state.tipoDesconto,
                          valorPercentual: state.valorPercentual,
                          valorDescontoMaximo: state.valorDescontoMaximo,
                          valorFixo: state.valorFixo,
                          valorMinimoCompra: state.valorMinimoCompra,
                          quantidadeMinima: state.quantidadeMinima,
                          precoFixo: state.precoFixo,
                          onTipoDescontoChanged: (tipo) =>
                              _onCampoAlterado(context, tipoDesconto: tipo),
                          onValorPercentualChanged: (valor) => _onCampoAlterado(
                            context,
                            valorPercentual: valor,
                          ),
                          onValorDescontoMaximoChanged: (valor) =>
                              _onCampoAlterado(
                            context,
                            valorDescontoMaximo: valor,
                          ),
                          onValorFixoChanged: (valor) =>
                              _onCampoAlterado(context, valorFixo: valor),
                          onValorMinimoCompraChanged: (valor) =>
                              _onCampoAlterado(context, valorMinimoCompra: valor),
                          onQuantidadeMinimaChanged: (valor) =>
                              _onCampoAlterado(context, quantidadeMinima: valor),
                          onPrecoFixoChanged: (valor) =>
                              _onCampoAlterado(context, precoFixo: valor),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Escopo',
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        const SizedBox(height: 8),
                        SegmentedButton<TipoEscopo>(
                          segments: const [
                            ButtonSegment(
                              value: TipoEscopo.geral,
                              label: Text('Geral'),
                            ),
                            ButtonSegment(
                              value: TipoEscopo.referencias,
                              label: Text('Referências'),
                            ),
                            ButtonSegment(
                              value: TipoEscopo.comboKit,
                              label: Text('Combo/Kit'),
                            ),
                            ButtonSegment(
                              value: TipoEscopo.comboLevePague,
                              label: Text('Leve e pague'),
                            ),
                          ],
                          selected: {state.tipoEscopo},
                          onSelectionChanged: (selecionados) => context
                              .read<PromocaoBloc>()
                              .add(
                                PromocaoCampoAlterado(
                                  tipoEscopo: selecionados.first,
                                  limparEscopo: true,
                                ),
                              ),
                        ),
                        const SizedBox(height: 12),
                        EscopoSelecionavelWidget(
                          key: ValueKey('escopo-${state.tipoEscopo}'),
                          tipoEscopo: state.tipoEscopo,
                          referenciaIdsIniciais: state.referenciaIds ?? const [],
                          comboKitInicial: state.comboKit ?? const [],
                          quantidadeLevaInicial: state.quantidadeLeva,
                          quantidadePagaInicial: state.quantidadePaga,
                          onReferenciaIdsChanged: (ids) =>
                              _onCampoAlterado(context, referenciaIds: ids),
                          onComboKitChanged: (itens) =>
                              _onCampoAlterado(context, comboKit: itens),
                          onQuantidadeLevaChanged: (valor) => _onCampoAlterado(
                            context,
                            quantidadeLeva: valor,
                          ),
                          onQuantidadePagaChanged: (valor) => _onCampoAlterado(
                            context,
                            quantidadePaga: valor,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Limites',
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _limiteUnidadesVendidasController,
                          decoration: const InputDecoration(
                            labelText: 'Limite de unidades vendidas (opcional)',
                          ),
                          keyboardType: TextInputType.number,
                          onChanged: (value) => _onCampoAlterado(
                            context,
                            limiteUnidadesVendidas: int.tryParse(value),
                          ),
                        ),
                        const SizedBox(height: 20),
                        FormasPagamentoFormWidget(
                          restringirFormasPagamento:
                              state.restringirFormasPagamento,
                          formasPagamento: state.formasPagamento,
                          formasDisponiveis:
                              state.formasDePagamentoDisponiveis,
                          tipoDesconto: state.tipoDesconto,
                          onRestringirChanged: (valor) => _onCampoAlterado(
                            context,
                            restringirFormasPagamento: valor,
                          ),
                          onFormasPagamentoChanged: (formas) =>
                              _onCampoAlterado(context, formasPagamento: formas),
                        ),
                        const SizedBox(height: 8),
                        SwitchListTile.adaptive(
                          contentPadding: EdgeInsets.zero,
                          title: const Text('Somente aniversariante'),
                          value: state.somenteAniversariante,
                          onChanged: (value) => _onCampoAlterado(
                            context,
                            somenteAniversariante: value,
                          ),
                        ),
                        SwitchListTile.adaptive(
                          contentPadding: EdgeInsets.zero,
                          title: const Text('Ativa'),
                          value: state.ativa,
                          onChanged: (value) =>
                              _onCampoAlterado(context, ativa: value),
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

  void _sincronizarControllers(PromocaoState state) {
    final nome = state.nome ?? '';
    final descricao = state.descricao ?? '';
    final limite = state.limiteUnidadesVendidas?.toString() ?? '';

    if (_nomeController.text != nome) {
      _nomeController.value = TextEditingValue(
        text: nome,
        selection: TextSelection.collapsed(offset: nome.length),
      );
    }

    if (_descricaoController.text != descricao) {
      _descricaoController.value = TextEditingValue(
        text: descricao,
        selection: TextSelection.collapsed(offset: descricao.length),
      );
    }

    if (_limiteUnidadesVendidasController.text != limite) {
      _limiteUnidadesVendidasController.value = TextEditingValue(
        text: limite,
        selection: TextSelection.collapsed(offset: limite.length),
      );
    }
  }

  void _onCampoAlterado(
    BuildContext context, {
    String? nome,
    String? descricao,
    DateTime? dataInicio,
    DateTime? dataFim,
    TipoDesconto? tipoDesconto,
    double? valorPercentual,
    double? valorDescontoMaximo,
    double? valorFixo,
    double? valorMinimoCompra,
    int? quantidadeMinima,
    double? precoFixo,
    List<int>? referenciaIds,
    List<ItemComboKit>? comboKit,
    int? quantidadeLeva,
    int? quantidadePaga,
    int? limiteUnidadesVendidas,
    bool? somenteAniversariante,
    bool? ativa,
    bool? restringirFormasPagamento,
    List<PromocaoFormaPagamento>? formasPagamento,
  }) {
    context.read<PromocaoBloc>().add(
          PromocaoCampoAlterado(
            nome: nome,
            descricao: descricao,
            dataInicio: dataInicio,
            dataFim: dataFim,
            tipoDesconto: tipoDesconto,
            valorPercentual: valorPercentual,
            valorDescontoMaximo: valorDescontoMaximo,
            valorFixo: valorFixo,
            valorMinimoCompra: valorMinimoCompra,
            quantidadeMinima: quantidadeMinima,
            precoFixo: precoFixo,
            referenciaIds: referenciaIds,
            comboKit: comboKit,
            quantidadeLeva: quantidadeLeva,
            quantidadePaga: quantidadePaga,
            limiteUnidadesVendidas: limiteUnidadesVendidas,
            somenteAniversariante: somenteAniversariante,
            ativa: ativa,
            restringirFormasPagamento: restringirFormasPagamento,
            formasPagamento: formasPagamento,
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
