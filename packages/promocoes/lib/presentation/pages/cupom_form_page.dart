import 'package:core/bloc.dart';
import 'package:core/injecoes.dart';
import 'package:core/tema.dart';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:promocoes/models.dart';
import 'package:promocoes/presentation.dart';
import 'package:promocoes/presentation/widgets/campo_data.dart';
import 'package:promocoes/presentation/widgets/form_promocional_layout.dart';

/// 8 caracteres pronunciaveis (consoante/vogal alternadas), sem 0/O/1/I.
String gerarCodigoCupom([Random? r]) {
  const consoantes = 'BCDFGHJKLMNPQRSTVWXZ';
  const vogais = 'AEU';
  final rnd = r ?? Random();
  return List.generate(8, (i) {
    final base = i.isEven ? consoantes : vogais;
    return base[rnd.nextInt(base.length)];
  }).join();
}

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
        child: BlocBuilder<CupomBloc, CupomState>(
          builder: (context, state) {
            final carregando = state.step == CupomStep.carregando;
            final salvando = state.step == CupomStep.salvando || carregando;
            if (!carregando) _sincronizarControllers(state);

            return Form(
              key: _formKey,
              child: FormPromocionalLayout(
                titulo: widget.idCupom == null ? 'Novo cupom' : 'Editar cupom',
                rotuloSalvar: 'Salvar cupom',
                salvando: salvando,
                onSalvar: () {
                  if (_formKey.currentState?.validate() ?? false) {
                    context.read<CupomBloc>().add(CupomSalvou());
                  }
                },
                corpo: carregando
                    ? const Center(
                        child: Padding(
                          padding: EdgeInsets.all(24),
                          child: CircularProgressIndicator.adaptive(),
                        ),
                      )
                    : _corpo(context, state),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _corpo(BuildContext context, CupomState state) {
    const gap = SizedBox(height: 16);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RotuloCampo(
          rotulo: 'Código',
          filho: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: TextFormField(
                  controller: _codigoController,
                  style: context.sivTextos.codigo,
                  textCapitalization: TextCapitalization.characters,
                  inputFormatters: [UpperCaseTextFormatter()],
                  validator: (value) => (value == null || value.trim().isEmpty)
                      ? 'Informe o código'
                      : null,
                  onChanged: (value) => _onCampoAlterado(context, codigo: value),
                ),
              ),
              const SizedBox(width: 8),
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(0, SivDimensoes.alvoToqueMinimo),
                ),
                onPressed: () =>
                    _onCampoAlterado(context, codigo: gerarCodigoCupom()),
                child: const Text('Gerar código'),
              ),
            ],
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
              TipoEscopo.geral: 'Geral',
              TipoEscopo.referencias: 'Referências',
              TipoEscopo.comboKit: 'Combo/Kit',
              TipoEscopo.comboLevePague: 'Leve e pague',
            },
            selecionado: state.tipoEscopo,
            onChanged: (tipo) => context.read<CupomBloc>().add(
                  CupomCampoAlterado(tipoEscopo: tipo, limparEscopo: true),
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
          onQuantidadeLevaChanged: (valor) =>
              _onCampoAlterado(context, quantidadeLeva: valor),
          onQuantidadePagaChanged: (valor) =>
              _onCampoAlterado(context, quantidadePaga: valor),
          // Cupom nao oferece o escopo faixaQuantidade.
          onFaixasChanged: (_) {},
        ),
        gap,
        RotuloCampo(
          rotulo: 'Limite de usos (opcional)',
          filho: TextFormField(
            controller: _limiteUsosController,
            keyboardType: TextInputType.number,
            onChanged: (value) =>
                _onCampoAlterado(context, limiteUsos: int.tryParse(value)),
          ),
        ),
        gap,
        Row(
          children: [
            Expanded(
              child: CampoData(
                rotulo: 'Início',
                data: state.dataInicio,
                onSelecionado: (data) =>
                    _onCampoAlterado(context, dataInicio: data),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: CampoData(
                rotulo: 'Fim',
                data: state.dataFim,
                onSelecionado: (data) => _onCampoAlterado(context, dataFim: data),
              ),
            ),
          ],
        ),
        gap,
        Row(
          children: [
            Expanded(
              child: Text('Ativo', style: context.sivTextos.corpo),
            ),
            Switch.adaptive(
              value: state.ativa,
              onChanged: (value) => _onCampoAlterado(context, ativa: value),
            ),
          ],
        ),
      ],
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
