import 'package:core/bloc.dart';
import 'package:core/injecoes.dart';
import 'package:core/tema.dart';
import 'package:flutter/material.dart';
import 'package:promocoes/models.dart';
import 'package:promocoes/presentation.dart';
import 'package:promocoes/presentation/widgets/campo_data.dart';
import 'package:promocoes/presentation/widgets/canais_chips.dart';
import 'package:promocoes/presentation/widgets/form_promocional_layout.dart';

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
  final _regrasController = TextEditingController();
  final _limiteUnidadesVendidasController = TextEditingController();
  final _limiteUsosPorClienteController = TextEditingController();

  @override
  void dispose() {
    _nomeController.dispose();
    _descricaoController.dispose();
    _regrasController.dispose();
    _limiteUnidadesVendidasController.dispose();
    _limiteUsosPorClienteController.dispose();
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
        child: Form(
          key: _formKey,
          child: BlocBuilder<PromocaoBloc, PromocaoState>(
            builder: (context, state) {
              final carregando = state.step == PromocaoStep.carregando;
              if (!carregando) _sincronizarControllers(state);

              return FormPromocionalLayout(
                titulo:
                    widget.idPromocao == null ? 'Nova promoção' : 'Editar promoção',
                rotuloSalvar: 'Salvar promoção',
                larguraModal: 620,
                salvando: state.step == PromocaoStep.salvando,
                onSalvar: () {
                  if (_formKey.currentState?.validate() ?? false) {
                    context.read<PromocaoBloc>().add(PromocaoSalvou());
                  }
                },
                corpo: carregando
                    ? const Padding(
                        padding: EdgeInsets.all(32),
                        child: Center(
                          child: CircularProgressIndicator.adaptive(),
                        ),
                      )
                    : _corpo(context, state),
              );
            },
          ),
        ),
      ),
    );
  }

  bool _maisOpcoesPreenchidas(PromocaoState s) =>
      (s.descricao ?? '').isNotEmpty ||
      (s.regras ?? '').isNotEmpty ||
      s.limiteUsosPorCliente != null ||
      s.periodoLimiteCliente != null ||
      s.restringirFormasPagamento ||
      s.formasPagamento.isNotEmpty ||
      s.somenteAniversariante;

  Widget _corpo(BuildContext context, PromocaoState state) {
    const gap = SizedBox(height: 16);
    final duasColunas =
        MediaQuery.sizeOf(context).width >= SivDimensoes.breakpointMenuDrawer;
    final inicio = CampoData(
      rotulo: 'Início',
      data: state.dataInicio,
      onSelecionado: (d) => _onCampoAlterado(context, dataInicio: d),
    );
    final fim = CampoData(
      rotulo: 'Fim',
      data: state.dataFim,
      onSelecionado: (d) => _onCampoAlterado(context, dataFim: d),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RotuloCampo(
          rotulo: 'Nome',
          filho: TextFormField(
            controller: _nomeController,
            validator: (value) => (value == null || value.trim().isEmpty)
                ? 'Informe o nome'
                : null,
            onChanged: (value) => _onCampoAlterado(context, nome: value),
          ),
        ),
        gap,
        RegraDescontoFormWidget(
          tipoDesconto: state.tipoDesconto,
          valorPercentual: state.valorPercentual,
          valorDescontoMaximo: state.valorDescontoMaximo,
          valorFixo: state.valorFixo,
          valorMinimoCompra: state.valorMinimoCompra,
          quantidadeMinima: state.quantidadeMinima,
          precoFixo: state.precoFixo,
          ocultarCamposDeValor: state.tipoEscopo == TipoEscopo.faixaQuantidade,
          onTipoDescontoChanged: (tipo) =>
              _onCampoAlterado(context, tipoDesconto: tipo),
          onValorPercentualChanged: (valor) =>
              _onCampoAlterado(context, valorPercentual: valor),
          onValorDescontoMaximoChanged: (valor) =>
              _onCampoAlterado(context, valorDescontoMaximo: valor),
          onValorFixoChanged: (valor) =>
              _onCampoAlterado(context, valorFixo: valor),
          onValorMinimoCompraChanged: (valor) =>
              _onCampoAlterado(context, valorMinimoCompra: valor),
          onQuantidadeMinimaChanged: (valor) =>
              _onCampoAlterado(context, quantidadeMinima: valor),
          onPrecoFixoChanged: (valor) =>
              _onCampoAlterado(context, precoFixo: valor),
        ),
        gap,
        RotuloCampo(
          rotulo: 'Escopo',
          filho: SegmentoOpcoes<TipoEscopo>(
            opcoes: const {
              TipoEscopo.geral: 'Todo o catálogo',
              TipoEscopo.categorias: 'Categoria',
              TipoEscopo.referencias: 'Produto',
              TipoEscopo.comboKit: 'Combo/Kit',
              TipoEscopo.comboLevePague: 'Leve e pague',
              TipoEscopo.faixaQuantidade: 'Faixas progressivas',
            },
            selecionado: state.tipoEscopo,
            onChanged: (tipo) => context.read<PromocaoBloc>().add(
                  PromocaoCampoAlterado(tipoEscopo: tipo, limparEscopo: true),
                ),
          ),
        ),
        if (state.tipoEscopo != TipoEscopo.geral) ...[
          gap,
          EscopoSelecionavelWidget(
            key: ValueKey('escopo-${state.tipoEscopo}'),
            tipoEscopo: state.tipoEscopo,
            referenciaIdsIniciais: state.referenciaIds ?? const [],
            categoriasIniciais: state.categorias ?? const [],
            excecaoReferenciaIdsIniciais: state.excecaoReferenciaIds ?? const [],
            comboKitInicial: state.comboKit ?? const [],
            quantidadeLevaInicial: state.quantidadeLeva,
            quantidadePagaInicial: state.quantidadePaga,
            faixasInicial: state.faixas ?? const [],
            onReferenciaIdsChanged: (ids) =>
                _onCampoAlterado(context, referenciaIds: ids),
            onCategoriasChanged: (categorias) =>
                _onCampoAlterado(context, categorias: categorias),
            onExcecaoReferenciaIdsChanged: (ids) =>
                _onCampoAlterado(context, excecaoReferenciaIds: ids),
            onComboKitChanged: (itens) =>
                _onCampoAlterado(context, comboKit: itens),
            onQuantidadeLevaChanged: (valor) =>
                _onCampoAlterado(context, quantidadeLeva: valor),
            onQuantidadePagaChanged: (valor) =>
                _onCampoAlterado(context, quantidadePaga: valor),
            onFaixasChanged: (faixas) =>
                _onCampoAlterado(context, faixas: faixas),
          ),
        ],
        gap,
        if (duasColunas)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: inicio),
              const SizedBox(width: 12),
              Expanded(child: fim),
            ],
          )
        else ...[
          inicio,
          gap,
          fim,
        ],
        gap,
        RotuloCampo(
          rotulo: 'Limite de unidades vendidas (opcional)',
          filho: TextFormField(
            controller: _limiteUnidadesVendidasController,
            keyboardType: TextInputType.number,
            onChanged: (value) => _onCampoAlterado(
              context,
              limiteUnidadesVendidas: int.tryParse(value),
            ),
          ),
        ),
        gap,
        Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            tilePadding: EdgeInsets.zero,
            childrenPadding: EdgeInsets.zero,
            expandedCrossAxisAlignment: CrossAxisAlignment.start,
            initiallyExpanded: _maisOpcoesPreenchidas(state),
            title: Text('Mais opções', style: context.sivTextos.secao),
            children: [
              RotuloCampo(
                rotulo: 'Descrição (opcional)',
                filho: TextFormField(
                  controller: _descricaoController,
                  onChanged: (value) =>
                      _onCampoAlterado(context, descricao: value),
                ),
              ),
              gap,
              RotuloCampo(
                rotulo: 'Regras da promoção (opcional)',
                filho: TextFormField(
                  controller: _regrasController,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    helperText: 'Condições de troca/regras da ação promocional. '
                        'Exibido pro cliente no checkout do e-commerce.',
                    helperMaxLines: 2,
                  ),
                  onChanged: (value) =>
                      _onCampoAlterado(context, regras: value),
                ),
              ),
              gap,
              RotuloCampo(
                rotulo: 'Limite de usos por cliente (opcional)',
                filho: TextFormField(
                  controller: _limiteUsosPorClienteController,
                  decoration: const InputDecoration(
                    helperText:
                        'Quantas vezes cada cliente pode usar esta promoção no período selecionado. Vazio = sem limite por cliente. Só se aplica a vendas com cliente identificado.',
                    helperMaxLines: 3,
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) => _onCampoAlterado(
                    context,
                    limiteUsosPorCliente: int.tryParse(value),
                  ),
                ),
              ),
              if (state.limiteUsosPorCliente != null) ...[
                gap,
                RotuloCampo(
                  rotulo: 'Período do limite',
                  filho: DropdownButtonFormField<PeriodoLimiteCliente>(
                    initialValue: state.periodoLimiteCliente,
                    items: const [
                      DropdownMenuItem(
                        value: PeriodoLimiteCliente.mes,
                        child: Text('Por mês'),
                      ),
                      DropdownMenuItem(
                        value: PeriodoLimiteCliente.ano,
                        child: Text('Por ano'),
                      ),
                    ],
                    onChanged: (periodo) => _onCampoAlterado(
                      context,
                      periodoLimiteCliente: periodo,
                    ),
                    validator: (_) => state.periodoLimiteCliente == null
                        ? 'Selecione o período'
                        : null,
                  ),
                ),
              ],
              gap,
              FormasPagamentoFormWidget(
                restringirFormasPagamento: state.restringirFormasPagamento,
                formasPagamento: state.formasPagamento,
                formasDisponiveis: state.formasDePagamentoDisponiveis,
                tipoDesconto: state.tipoDesconto,
                onRestringirChanged: (valor) => _onCampoAlterado(
                  context,
                  restringirFormasPagamento: valor,
                ),
                onFormasPagamentoChanged: (formas) =>
                    _onCampoAlterado(context, formasPagamento: formas),
              ),
              SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                title: const Text('Somente aniversariante'),
                value: state.somenteAniversariante,
                onChanged: (value) =>
                    _onCampoAlterado(context, somenteAniversariante: value),
              ),
            ],
          ),
        ),
        gap,
        CanaisChips(
          canal: state.canal,
          onChanged: (canal) => _onCampoAlterado(context, canal: canal),
        ),
        SwitchListTile.adaptive(
          contentPadding: EdgeInsets.zero,
          title: const Text('Ativa'),
          value: state.ativa,
          onChanged: (value) => _onCampoAlterado(context, ativa: value),
        ),
      ],
    );
  }

  void _sincronizarControllers(PromocaoState state) {
    final nome = state.nome ?? '';
    final descricao = state.descricao ?? '';
    final regras = state.regras ?? '';
    final limite = state.limiteUnidadesVendidas?.toString() ?? '';
    final limitePorCliente = state.limiteUsosPorCliente?.toString() ?? '';

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

    if (_regrasController.text != regras) {
      _regrasController.value = TextEditingValue(
        text: regras,
        selection: TextSelection.collapsed(offset: regras.length),
      );
    }

    if (_limiteUnidadesVendidasController.text != limite) {
      _limiteUnidadesVendidasController.value = TextEditingValue(
        text: limite,
        selection: TextSelection.collapsed(offset: limite.length),
      );
    }

    if (_limiteUsosPorClienteController.text != limitePorCliente) {
      _limiteUsosPorClienteController.value = TextEditingValue(
        text: limitePorCliente,
        selection: TextSelection.collapsed(offset: limitePorCliente.length),
      );
    }
  }

  void _onCampoAlterado(
    BuildContext context, {
    String? nome,
    String? descricao,
    String? regras,
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
    List<PromocaoCategoria>? categorias,
    List<int>? excecaoReferenciaIds,
    List<ItemComboKit>? comboKit,
    int? quantidadeLeva,
    int? quantidadePaga,
    List<PromocaoFaixa>? faixas,
    int? limiteUnidadesVendidas,
    int? limiteUsosPorCliente,
    PeriodoLimiteCliente? periodoLimiteCliente,
    bool? somenteAniversariante,
    PromocaoCanal? canal,
    bool? ativa,
    bool? restringirFormasPagamento,
    List<PromocaoFormaPagamento>? formasPagamento,
  }) {
    context.read<PromocaoBloc>().add(
          PromocaoCampoAlterado(
            nome: nome,
            descricao: descricao,
            regras: regras,
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
            categorias: categorias,
            excecaoReferenciaIds: excecaoReferenciaIds,
            comboKit: comboKit,
            quantidadeLeva: quantidadeLeva,
            quantidadePaga: quantidadePaga,
            faixas: faixas,
            limiteUnidadesVendidas: limiteUnidadesVendidas,
            limiteUsosPorCliente: limiteUsosPorCliente,
            periodoLimiteCliente: periodoLimiteCliente,
            somenteAniversariante: somenteAniversariante,
            canal: canal,
            ativa: ativa,
            restringirFormasPagamento: restringirFormasPagamento,
            formasPagamento: formasPagamento,
          ),
        );
  }
}
