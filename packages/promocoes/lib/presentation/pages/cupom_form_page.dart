import 'package:core/bloc.dart';
import 'package:core/injecoes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:promocoes/models.dart';
import 'package:promocoes/presentation.dart';

class CupomFormPage extends StatefulWidget {
  final int? idCupom;

  const CupomFormPage({super.key, this.idCupom});

  @override
  State<CupomFormPage> createState() => _CupomFormPageState();
}

class _CupomFormPageState extends State<CupomFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _codigoController = TextEditingController();
  final _limiteUsosController = TextEditingController();

  @override
  void dispose() {
    _codigoController.dispose();
    _limiteUsosController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<CupomBloc>(
      create: (_) =>
          sl<CupomBloc>()..add(CupomIniciou(idCupom: widget.idCupom)),
      child: BlocListener<CupomBloc, CupomState>(
        listenWhen: (previous, current) => previous.step != current.step,
        listener: (context, state) {
          if (state.step == CupomStep.validacaoInvalida ||
              state.step == CupomStep.falha) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.erro ?? 'Falha ao salvar cupom.')),
            );
          }

          if (state.step == CupomStep.criado || state.step == CupomStep.salvo) {
            Navigator.of(context).pop(true);
          }
        },
        child: Scaffold(
          appBar: AppBar(
            title: Text(widget.idCupom == null ? 'Novo cupom' : 'Editar cupom'),
          ),
          floatingActionButton: BlocBuilder<CupomBloc, CupomState>(
            builder: (context, state) {
              final salvando = state.step == CupomStep.salvando ||
                  state.step == CupomStep.carregando;

              return FloatingActionButton(
                onPressed: salvando
                    ? null
                    : () {
                        if (_formKey.currentState?.validate() ?? false) {
                          context.read<CupomBloc>().add(CupomSalvou());
                        }
                      },
                child: salvando
                    ? const CircularProgressIndicator.adaptive()
                    : const Icon(Icons.check),
              );
            },
          ),
          body: BlocBuilder<CupomBloc, CupomState>(
            builder: (context, state) {
              if (state.step == CupomStep.carregando) {
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
                          controller: _codigoController,
                          decoration: const InputDecoration(labelText: 'Código'),
                          textCapitalization: TextCapitalization.characters,
                          inputFormatters: [UpperCaseTextFormatter()],
                          validator: (value) => (value == null || value.trim().isEmpty)
                              ? 'Informe o código'
                              : null,
                          onChanged: (value) =>
                              _onCampoAlterado(context, codigo: value),
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
                              .read<CupomBloc>()
                              .add(
                                CupomCampoAlterado(
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
                          controller: _limiteUsosController,
                          decoration: const InputDecoration(
                            labelText: 'Limite de usos (opcional)',
                          ),
                          keyboardType: TextInputType.number,
                          onChanged: (value) => _onCampoAlterado(
                            context,
                            limiteUsos: int.tryParse(value),
                          ),
                        ),
                        const SizedBox(height: 8),
                        SwitchListTile.adaptive(
                          contentPadding: EdgeInsets.zero,
                          title: const Text('Ativo'),
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

  void _sincronizarControllers(CupomState state) {
    final codigo = state.codigo ?? '';
    final limite = state.limiteUsos?.toString() ?? '';

    if (_codigoController.text != codigo) {
      _codigoController.value = TextEditingValue(
        text: codigo,
        selection: TextSelection.collapsed(offset: codigo.length),
      );
    }

    if (_limiteUsosController.text != limite) {
      _limiteUsosController.value = TextEditingValue(
        text: limite,
        selection: TextSelection.collapsed(offset: limite.length),
      );
    }
  }

  void _onCampoAlterado(
    BuildContext context, {
    String? codigo,
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
    int? limiteUsos,
    bool? ativa,
  }) {
    context.read<CupomBloc>().add(
          CupomCampoAlterado(
            codigo: codigo,
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
            limiteUsos: limiteUsos,
            ativa: ativa,
          ),
        );
  }
}

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return newValue.copyWith(text: newValue.text.toUpperCase());
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
