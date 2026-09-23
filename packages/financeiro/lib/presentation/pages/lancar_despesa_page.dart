import 'package:core/bloc.dart';
import 'package:core/injecoes.dart';
import 'package:core/sessao.dart';
import 'package:core/tema.dart';
import 'package:financeiro/domain/models/origem_pagamento_despesa.dart';
import 'package:financeiro/domain/utils/proxima_data_vencimento_cartao.dart';
import 'package:financeiro/presentation.dart';
import 'package:financeiro/presentation/utils/formatadores.dart';
import 'package:financeiro/presentation/utils/nomes_dos_meses.dart';
import 'package:financeiro/presentation/widgets/card_blueprint.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

const _breakpointLargo = 1000.0;

/// Abre o lançamento de despesa: painel lateral em telas largas, página
/// cheia (rota `/lancar_despesa`) em telas estreitas. Retorna `true` quando
/// uma despesa foi criada.
Future<bool?> abrirLancarDespesa(
  BuildContext context, {
  int? caixaId,
  DateTime? dataInicial,
}) async {
  final largo = MediaQuery.sizeOf(context).width >= _breakpointLargo;
  if (!largo) {
    // pushNamed<bool> quebra aqui: o onGenerateRoute do app sempre cria
    // MaterialPageRoute<dynamic>, e o cast interno do Flutter pra Route<bool?>
    // falha. pushNamed<Object?> (implícito, sem type arg) casa com o tipo
    // real da rota; o valor devolvido ainda é bool (ou null), só convertido
    // depois.
    final resultado = await Navigator.of(context).pushNamed(
      '/lancar_despesa',
      arguments: {'caixaId': caixaId, 'dataPagamento': dataInicial},
    );
    return resultado as bool?;
  }

  return showGeneralDialog<bool>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Lançar despesa',
    barrierColor: const Color(0x5D22323F),
    transitionDuration: const Duration(milliseconds: 200),
    pageBuilder: (dialogContext, _, __) => Align(
      alignment: Alignment.centerRight,
      child: Material(
        color: Colors.transparent,
        child: SizedBox(
          width: 560,
          height: double.infinity,
          child: _LancarDespesaPainel(caixaId: caixaId, dataInicial: dataInicial),
        ),
      ),
    ),
  );
}

class _LancarDespesaPainel extends StatelessWidget {
  final int? caixaId;
  final DateTime? dataInicial;

  const _LancarDespesaPainel({this.caixaId, this.dataInicial});

  @override
  Widget build(BuildContext context) {
    final empresaId = sl<IAcessoGlobalSessao>().empresaIdDaSessao ?? 0;
    final cores = context.sivColors;
    final textos = context.sivTextos;

    return BlocProvider<LancarDespesaBloc>(
      create: (_) => sl<LancarDespesaBloc>()
        ..add(
          LancarDespesaIniciou(
            empresaId: empresaId,
            caixaId: caixaId,
            dataInicial: dataInicial,
          ),
        ),
      child: _LancarDespesaListener(
        child: Container(
          color: cores.superficie,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(28, 22, 20, 22),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Lançar despesa', style: textos.titulo.copyWith(fontSize: 24)),
                          const SizedBox(height: 2),
                          Text('Vale do Ceará', style: textos.apoio),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(false),
                    ),
                  ],
                ),
              ),
              Divider(height: 1, color: cores.hairline),
              const Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 28, vertical: 22),
                  child: LancarDespesaForm(),
                ),
              ),
              Divider(height: 1, color: cores.hairline),
              Padding(
                padding: const EdgeInsets.fromLTRB(28, 16, 28, 16),
                child: BlocBuilder<LancarDespesaBloc, LancarDespesaState>(
                  builder: (context, state) => Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: const Text('Cancelar'),
                      ),
                      const SizedBox(width: 10),
                      FilledButton(
                        onPressed: _salvando(state)
                            ? null
                            : () => context.read<LancarDespesaBloc>().add(LancarDespesaSalvou()),
                        child: Text(_ctaLabel(state)),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Página cheia usada em telas estreitas (rota `/lancar_despesa`) e pela
/// tela de Caixa (`caixaId`), que continua navegando pra essa rota.
class LancarDespesaPage extends StatelessWidget {
  final int? caixaId;
  final DateTime? dataInicial;

  const LancarDespesaPage({super.key, this.caixaId, this.dataInicial});

  @override
  Widget build(BuildContext context) {
    final empresaId = sl<IAcessoGlobalSessao>().empresaIdDaSessao ?? 0;
    final cores = context.sivColors;

    return BlocProvider<LancarDespesaBloc>(
      create: (_) => sl<LancarDespesaBloc>()
        ..add(
          LancarDespesaIniciou(
            empresaId: empresaId,
            caixaId: caixaId,
            dataInicial: dataInicial,
          ),
        ),
      child: _LancarDespesaListener(
        child: Scaffold(
          backgroundColor: cores.superficie,
          appBar: AppBar(
            title: const Text('Lançar despesa'),
            leading: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.of(context).pop(false),
            ),
          ),
          body: SafeArea(
            child: BlocBuilder<LancarDespesaBloc, LancarDespesaState>(
              builder: (context, state) {
                if (state.step == LancarDespesaStep.carregando ||
                    state.step == LancarDespesaStep.inicial) {
                  return const Center(child: CircularProgressIndicator.adaptive());
                }
                return const SingleChildScrollView(
                  padding: EdgeInsets.all(18),
                  child: LancarDespesaForm(),
                );
              },
            ),
          ),
          bottomNavigationBar: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: BlocBuilder<LancarDespesaBloc, LancarDespesaState>(
                builder: (context, state) => SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _salvando(state)
                        ? null
                        : () => context.read<LancarDespesaBloc>().add(LancarDespesaSalvou()),
                    child: Text(_ctaLabel(state)),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LancarDespesaListener extends StatelessWidget {
  final Widget child;

  const _LancarDespesaListener({required this.child});

  @override
  Widget build(BuildContext context) {
    return BlocListener<LancarDespesaBloc, LancarDespesaState>(
      listenWhen: (previous, current) => previous.step != current.step,
      listener: (context, state) {
        if (state.step == LancarDespesaStep.validacaoInvalida ||
            state.step == LancarDespesaStep.falha) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.erro ?? 'Falha ao lançar despesa.')),
          );
        }
        if (state.step == LancarDespesaStep.criada) {
          Navigator.of(context).pop(true);
        }
      },
      child: child,
    );
  }
}

bool _salvando(LancarDespesaState state) =>
    state.step == LancarDespesaStep.salvando || state.step == LancarDespesaStep.carregando;

String _ctaLabel(LancarDespesaState state) {
  switch (state.modo) {
    case ModoLancamentoDespesa.avulsa:
      return 'Lançar despesa';
    case ModoLancamentoDespesa.parcelada:
      final n = state.parcelas;
      return n != null && n > 1 ? 'Lançar $n parcelas' : 'Lançar despesa';
    case ModoLancamentoDespesa.recorrente:
      return 'Criar recorrência';
  }
}

/// Campos do lançamento, sem `Scaffold` -- reusado no painel lateral (telas
/// largas) e na página cheia (telas estreitas).
class LancarDespesaForm extends StatefulWidget {
  const LancarDespesaForm({super.key});

  @override
  State<LancarDespesaForm> createState() => _LancarDespesaFormState();
}

class _LancarDespesaFormState extends State<LancarDespesaForm> {
  final _descricaoController = TextEditingController();
  final _valorController = TextEditingController();
  final _diaVencimentoController = TextEditingController();
  final _parcelasController = TextEditingController();

  @override
  void dispose() {
    _descricaoController.dispose();
    _valorController.dispose();
    _diaVencimentoController.dispose();
    _parcelasController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LancarDespesaBloc, LancarDespesaState>(
      builder: (context, state) {
        if (state.step == LancarDespesaStep.carregando || state.step == LancarDespesaStep.inicial) {
          return const Center(child: CircularProgressIndicator.adaptive());
        }
        _sincronizarControllers(state);
        final bloc = context.read<LancarDespesaBloc>();
        final largo = MediaQuery.sizeOf(context).width >= _breakpointLargo;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SeletorModo(modo: state.modo, largo: largo, onSelecionado: (m) => bloc.add(LancarDespesaCampoAlterado(modo: m))),
            const SizedBox(height: 16),
            _Rotulo('DESCRIÇÃO'),
            TextField(
              controller: _descricaoController,
              onChanged: (v) => bloc.add(LancarDespesaCampoAlterado(descricao: v)),
            ),
            const SizedBox(height: 12),
            if (largo)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _campoValor(context, state, bloc)),
                  const SizedBox(width: 12),
                  Expanded(child: _campoCategoria(context, state, bloc)),
                ],
              )
            else ...[
              _campoValor(context, state, bloc),
              const SizedBox(height: 12),
              _campoCategoria(context, state, bloc),
            ],
            const SizedBox(height: 12),
            _Rotulo('ORIGEM DE PAGAMENTO'),
            _SeletorOrigem(
              origens: state.origens,
              selecionadaId: state.origemPagamentoId,
              largo: largo,
              onSelecionada: (id) => bloc.add(LancarDespesaCampoAlterado(origemPagamentoId: id)),
            ),
            const SizedBox(height: 16),
            if (state.modo == ModoLancamentoDespesa.avulsa) _blocoAvulsa(context, state, bloc),
            if (state.modo == ModoLancamentoDespesa.parcelada) _blocoParcelada(context, state, bloc),
            if (state.modo == ModoLancamentoDespesa.recorrente) _blocoRecorrente(context, state, bloc),
          ],
        );
      },
    );
  }

  Widget _campoValor(BuildContext context, LancarDespesaState state, LancarDespesaBloc bloc) {
    final textos = context.sivTextos;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Rotulo(state.modo == ModoLancamentoDespesa.parcelada ? 'VALOR DE CADA PARCELA' : 'VALOR'),
        TextField(
          controller: _valorController,
          style: textos.corpo.copyWith(fontFamily: textos.secao.fontFamily, fontSize: 17),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*[.,]?\d*$'))],
          onChanged: (v) => bloc.add(LancarDespesaCampoAlterado(valor: double.tryParse(v.replaceAll(',', '.')))),
        ),
      ],
    );
  }

  Widget _campoCategoria(BuildContext context, LancarDespesaState state, LancarDespesaBloc bloc) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Rotulo('CATEGORIA'),
        DropdownButtonFormField<int>(
          initialValue: state.categoriaId,
          isExpanded: true,
          items: state.categoriasAtivas
              .map(
                (c) => DropdownMenuItem(
                  value: c.id,
                  child: Text(c.nome, maxLines: 1, overflow: TextOverflow.ellipsis),
                ),
              )
              .toList(),
          onChanged: (v) => bloc.add(LancarDespesaCampoAlterado(categoriaId: v)),
        ),
      ],
    );
  }

  Widget _blocoAvulsa(BuildContext context, LancarDespesaState state, LancarDespesaBloc bloc) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Rotulo('DATA DE PAGAMENTO'),
        _CampoData(
          data: state.dataPagamento,
          onSelecionada: (d) => bloc.add(LancarDespesaCampoAlterado(dataPagamento: d)),
        ),
        if (state.origemEhCredito && state.dataPagamento != null) ...[
          const SizedBox(height: 10),
          _notaCartao(context, state),
        ],
      ],
    );
  }

  Widget _notaCartao(BuildContext context, LancarDespesaState state) {
    final cores = context.sivColors;
    final textos = context.sivTextos;
    final origem = state.origemSelecionada;
    final data = state.dataPagamento!;
    final texto = state.pulouPorFechamento
        ? 'Data ajustada para o vencimento da próxima fatura: a fatura de '
            '${nomesDosMeses[DateTime.now().month - 1].toLowerCase()} já fechou '
            '(fecha ${origem?.prazoFechamentoDias} dias antes do dia ${origem?.diaVencimento}), '
            'então esta compra vence em ${_dataCurta(data)}.'
        : 'Data ajustada para o vencimento da fatura: dia ${_dataCurta(data)}.';
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: cores.selecaoFundo, borderRadius: BorderRadius.circular(SivDimensoes.raio)),
      child: Text(texto, style: textos.apoio.copyWith(color: cores.acoAtivo)),
    );
  }

  Widget _blocoParcelada(BuildContext context, LancarDespesaState state, LancarDespesaBloc bloc) {
    final textos = context.sivTextos;
    final total = state.parcelas ?? 0;
    final valorParcela = state.valor ?? 0;
    final preview = state.previewParcelas;
    final mostrar = preview.length > 12
        ? [...preview.take(3), null, preview.last]
        : preview;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            SizedBox(
              width: 140,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Rotulo('Nº DE PARCELAS'),
                  TextField(
                    controller: _parcelasController,
                    style: textos.corpo.copyWith(fontFamily: textos.secao.fontFamily, fontSize: 17),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    onChanged: (v) => bloc.add(LancarDespesaCampoAlterado(parcelas: int.tryParse(v))),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Text(
                  total > 1
                      ? 'Total ${formatarReais(total * valorParcela)} em $total× de ${formatarReais(valorParcela)}'
                      : '',
                  style: textos.apoio,
                ),
              ),
            ),
          ],
        ),
        if (preview.isNotEmpty) ...[
          const SizedBox(height: 12),
          CardBlueprint(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                for (final item in mostrar)
                  item == null
                      ? Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Text('…', style: textos.apoio),
                        )
                      : _LinhaParcelaPreview(numero: item.$1, data: item.$2, valor: valorParcela),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _blocoRecorrente(BuildContext context, LancarDespesaState state, LancarDespesaBloc bloc) {
    final cores = context.sivColors;
    final textos = context.sivTextos;
    final dia = state.diaVencimento;
    final proximas = dia == null
        ? ''
        : List.generate(3, (i) => vencimentoNoMes(DateTime(DateTime.now().year, DateTime.now().month, dia), i))
            .map(_dataCurta)
            .join(' · ');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            SizedBox(
              width: 140,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Rotulo('DIA DE VENCIMENTO'),
                  TextField(
                    controller: _diaVencimentoController,
                    style: textos.corpo.copyWith(fontFamily: textos.secao.fontFamily, fontSize: 17),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    onChanged: (v) => bloc.add(LancarDespesaCampoAlterado(diaVencimento: int.tryParse(v))),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            if (proximas.isNotEmpty)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Text('Próximas: $proximas …', style: textos.apoio),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: cores.selecaoFundo, borderRadius: BorderRadius.circular(SivDimensoes.raio)),
          child: Text.rich(
            TextSpan(
              style: textos.apoio.copyWith(color: cores.acoAtivo),
              children: const [
                TextSpan(text: 'Aparece todo mês no calendário como '),
                TextSpan(text: 'prevista', style: TextStyle(fontWeight: FontWeight.bold)),
                TextSpan(text: '. Só vira lançamento quando for paga, cancelada ou editada naquele mês.'),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _sincronizarControllers(LancarDespesaState state) {
    _sync(_descricaoController, state.descricao ?? '');
    // Compara o valor numérico, não a string: reformatar a cada rebuild (ex:
    // "1" -> "1.0") sobrescreve o que o usuário está digitando no meio do
    // toque.
    final valorDigitado = double.tryParse(_valorController.text.replaceAll(',', '.'));
    if (valorDigitado != state.valor) {
      _sync(_valorController, state.valor?.toString() ?? '');
    }
    _sync(_diaVencimentoController, state.diaVencimento?.toString() ?? '');
    _sync(
      _parcelasController,
      (state.modo == ModoLancamentoDespesa.parcelada ? state.parcelas : null)?.toString() ?? '',
    );
  }

  void _sync(TextEditingController controller, String valor) {
    if (controller.text != valor) {
      controller.value = TextEditingValue(text: valor, selection: TextSelection.collapsed(offset: valor.length));
    }
  }
}

String _dataCurta(DateTime data) =>
    '${data.day.toString().padLeft(2, '0')}/${data.month.toString().padLeft(2, '0')}';

class _LinhaParcelaPreview extends StatelessWidget {
  final int numero;
  final DateTime data;
  final double valor;

  const _LinhaParcelaPreview({required this.numero, required this.data, required this.valor});

  @override
  Widget build(BuildContext context) {
    final cores = context.sivColors;
    final textos = context.sivTextos;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: cores.hairline))),
      child: Row(
        children: [
          SizedBox(width: 60, child: Text('$numero', style: textos.apoio)),
          Expanded(
            child: Text(
              '${data.day.toString().padLeft(2, '0')}/${data.month.toString().padLeft(2, '0')}/${data.year}',
              style: textos.corpo.copyWith(fontSize: 13),
            ),
          ),
          Text(formatarReais(valor), style: textos.secao.copyWith(fontSize: 15)),
        ],
      ),
    );
  }
}

class _Rotulo extends StatelessWidget {
  final String texto;

  const _Rotulo(this.texto);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Text(texto, style: context.sivTextos.rotulo),
    );
  }
}

class _SeletorModo extends StatelessWidget {
  final ModoLancamentoDespesa modo;
  final bool largo;
  final ValueChanged<ModoLancamentoDespesa> onSelecionado;

  const _SeletorModo({required this.modo, required this.largo, required this.onSelecionado});

  static const _opcoes = [
    (ModoLancamentoDespesa.avulsa, 'AVULSA', 'pagamento único'),
    (ModoLancamentoDespesa.parcelada, 'PARCELADA', 'N parcelas iguais'),
    (ModoLancamentoDespesa.recorrente, 'RECORRENTE', 'todo mês'),
  ];

  @override
  Widget build(BuildContext context) {
    final cores = context.sivColors;
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: cores.hairline),
        borderRadius: BorderRadius.circular(SivDimensoes.raio),
      ),
      child: Row(
        children: [
          for (final opcao in _opcoes)
            Expanded(
              child: _OpcaoModo(
                selecionado: modo == opcao.$1,
                label: opcao.$2,
                hint: largo ? opcao.$3 : null,
                onTap: () => onSelecionado(opcao.$1),
              ),
            ),
        ],
      ),
    );
  }
}

class _OpcaoModo extends StatelessWidget {
  final bool selecionado;
  final String label;
  final String? hint;
  final VoidCallback onTap;

  const _OpcaoModo({required this.selecionado, required this.label, this.hint, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cores = context.sivColors;
    final textos = context.sivTextos;
    return InkWell(
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minHeight: SivDimensoes.alvoToqueMinimo),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        color: selecionado ? cores.acoAtivo : Colors.transparent,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: textos.secao.copyWith(
                fontSize: 15,
                color: selecionado ? Colors.white : cores.textoPrincipal,
              ),
            ),
            if (hint != null)
              Text(
                hint!,
                style: textos.apoio.copyWith(
                  fontSize: 11.5,
                  color: selecionado ? Colors.white.withValues(alpha: 0.75) : cores.textoApoio,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _SeletorOrigem extends StatelessWidget {
  final List<OrigemPagamentoDespesa> origens;
  final int? selecionadaId;
  final bool largo;
  final ValueChanged<int?> onSelecionada;

  const _SeletorOrigem({
    required this.origens,
    required this.selecionadaId,
    required this.largo,
    required this.onSelecionada,
  });

  String _sub(OrigemPagamentoDespesa origem) => origem.tipo.diaVencimentoObrigatorio
      ? '${origem.tipo.label} · vence dia ${origem.diaVencimento}'
      : origem.tipo.label;

  @override
  Widget build(BuildContext context) {
    if (!largo || origens.length > 6) {
      return DropdownButtonFormField<int>(
        initialValue: selecionadaId,
        isExpanded: true,
        items: origens
            .map(
              (o) => DropdownMenuItem(
                value: o.id,
                child: Text(
                  '${o.nome} · ${_sub(o)}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            )
            .toList(),
        onChanged: onSelecionada,
      );
    }

    final cores = context.sivColors;
    final textos = context.sivTextos;
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      childAspectRatio: 3.4,
      children: [
        for (final origem in origens)
          InkWell(
            onTap: () => onSelecionada(origem.id),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: origem.id == selecionadaId ? cores.selecaoFundo : cores.superficie,
                border: Border.all(color: origem.id == selecionadaId ? cores.aco : cores.hairline),
                borderRadius: BorderRadius.circular(SivDimensoes.raio),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    origem.nome,
                    style: textos.corpo.copyWith(fontSize: 13.5),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    _sub(origem),
                    style: textos.apoio.copyWith(fontSize: 11.5),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _CampoData extends StatelessWidget {
  final DateTime? data;
  final ValueChanged<DateTime> onSelecionada;

  const _CampoData({required this.data, required this.onSelecionada});

  @override
  Widget build(BuildContext context) {
    final texto = data == null
        ? 'Selecione a data'
        : '${data!.day.toString().padLeft(2, '0')}/${data!.month.toString().padLeft(2, '0')}/${data!.year}';

    return InkWell(
      onTap: () async {
        final selecionada = await showDatePicker(
          context: context,
          initialDate: data ?? DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
        );
        if (selecionada != null) onSelecionada(selecionada);
      },
      child: InputDecorator(
        decoration: const InputDecoration(suffixIcon: Icon(Icons.calendar_today, size: 16)),
        child: Text(texto),
      ),
    );
  }
}
