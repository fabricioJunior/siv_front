import 'package:core/bloc.dart';
import 'package:core/tema.dart';
import 'package:financeiro/models.dart';
import 'package:financeiro/presentation.dart';
import 'package:financeiro/presentation/utils/formatadores.dart';
import 'package:financeiro/presentation/utils/nomes_dos_meses.dart';
import 'package:financeiro/presentation/widgets/card_blueprint.dart';
import 'package:financeiro/presentation/widgets/despesa_status_mark.dart';
import 'package:flutter/material.dart';

const _breakpointLargo = 1000.0;

class CalendarioDeDespesasBody extends StatefulWidget {
  /// Chamado depois que o calendário recarrega (mudou de mês ou uma
  /// ocorrência foi paga/cancelada/editada) -- a página usa isso pra
  /// recarregar o painel junto.
  final VoidCallback? onAlterou;

  const CalendarioDeDespesasBody({super.key, this.onAlterou});

  @override
  State<CalendarioDeDespesasBody> createState() =>
      _CalendarioDeDespesasBodyState();
}

class _CalendarioDeDespesasBodyState extends State<CalendarioDeDespesasBody> {
  int? _diaSelecionado;
  int? _mesDoDiaSelecionado;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CalendarioDeDespesasBloc, CalendarioDeDespesasState>(
      listenWhen: (previous, current) =>
          previous.step == CalendarioDeDespesasStep.carregando &&
          current.step == CalendarioDeDespesasStep.carregado,
      listener: (context, state) => widget.onAlterou?.call(),
      builder: (context, state) {
        if (state.step == CalendarioDeDespesasStep.inicial ||
            state.step == CalendarioDeDespesasStep.carregando) {
          return const Center(child: CircularProgressIndicator.adaptive());
        }

        if (state.step == CalendarioDeDespesasStep.falha) {
          return const Center(child: Text('Falha ao carregar o calendário.'));
        }

        if (state.erro != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!context.mounted) return;
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(state.erro!)));
          });
        }

        if (_mesDoDiaSelecionado != state.mes) {
          final hoje = DateTime.now();
          final ehMesAtual = state.ano == hoje.year && state.mes == hoje.month;
          _diaSelecionado = ehMesAtual ? hoje.day : 1;
          _mesDoDiaSelecionado = state.mes;
        }

        return LayoutBuilder(
          builder: (context, constraints) {
            final largo = constraints.maxWidth >= _breakpointLargo;
            return largo
                ? _CalendarioLargo(
                    state: state,
                    diaSelecionado: _diaSelecionado ?? 1,
                    onDiaSelecionado: (dia) =>
                        setState(() => _diaSelecionado = dia),
                  )
                : _CalendarioMobile(
                    state: state,
                    diaSelecionado: _diaSelecionado ?? 1,
                    onDiaSelecionado: (dia) =>
                        setState(() => _diaSelecionado = dia),
                  );
          },
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Layout largo: grade do mês + painel do dia
// ---------------------------------------------------------------------------

class _CalendarioLargo extends StatelessWidget {
  final CalendarioDeDespesasState state;
  final int diaSelecionado;
  final ValueChanged<int> onDiaSelecionado;

  const _CalendarioLargo({
    required this.state,
    required this.diaSelecionado,
    required this.onDiaSelecionado,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: Padding(
            // Esquerda 16 pra alinhar com o rótulo "PAINEL" da TabBar.
            padding: const EdgeInsets.fromLTRB(16, 14, 12, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _LegendaTotais(totais: state.totalPorEstado),
                const SizedBox(height: 14),
                Expanded(
                  child: CardBlueprint(
                    padding: EdgeInsets.zero,
                    child: _GradeMes(
                      state: state,
                      diaSelecionado: diaSelecionado,
                      onDiaSelecionado: onDiaSelecionado,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(
          width: 380,
          child: _PainelDoDia(state: state, dia: diaSelecionado),
        ),
      ],
    );
  }
}

class _LegendaTotais extends StatelessWidget {
  final Map<String, double> totais;
  final bool mostrarCancelado;

  const _LegendaTotais({required this.totais, this.mostrarCancelado = true});

  @override
  Widget build(BuildContext context) {
    final textos = context.sivTextos;
    final cores = context.sivColors;
    Widget item(Widget marca, String rotulo, double valor) => Padding(
          padding: const EdgeInsets.only(right: 22),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              marca,
              const SizedBox(width: 7),
              Text('$rotulo ',
                  style: textos.apoio.copyWith(color: cores.textoApoio)),
              Text(formatarReais(valor),
                  style: textos.apoio.copyWith(fontWeight: FontWeight.w600)),
            ],
          ),
        );

    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        item(Container(width: 10, height: 10, color: cores.acoAtivo), 'Pago',
            totais['pago'] ?? 0),
        item(
          CustomPaint(
              size: const Size(10, 10),
              painter: _MolduraLegenda(cor: cores.aco, tracejada: false)),
          'Pendente',
          totais['pendente'] ?? 0,
        ),
        item(
          CustomPaint(
              size: const Size(10, 10),
              painter: _MolduraLegenda(cor: cores.aco, tracejada: true)),
          'Prevista (recorrente não lançada)',
          totais['prevista'] ?? 0,
        ),
        if (mostrarCancelado)
          item(
            SizedBox(
                width: 10,
                child: Divider(
                    height: 1.5, thickness: 1.5, color: cores.textoApoio)),
            'Cancelado',
            totais['cancelado'] ?? 0,
          ),
      ],
    );
  }
}

class _MolduraLegenda extends CustomPainter {
  final Color cor;
  final bool tracejada;

  _MolduraLegenda({required this.cor, required this.tracejada});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = cor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawRect(
        Rect.fromLTWH(0.75, 0.75, size.width - 1.5, size.height - 1.5), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _GradeMes extends StatelessWidget {
  final CalendarioDeDespesasState state;
  final int diaSelecionado;
  final ValueChanged<int> onDiaSelecionado;
  final bool compacto;

  const _GradeMes(
      {required this.state,
      required this.diaSelecionado,
      required this.onDiaSelecionado,
      this.compacto = false});

  @override
  Widget build(BuildContext context) {
    final cores = context.sivColors;
    final textos = context.sivTextos;
    final primeiroDia = DateTime(state.ano, state.mes, 1);
    final diasNoMes = DateTime(state.ano, state.mes + 1, 0).day;
    final offset = primeiroDia.weekday % 7; // weekday: 1=seg..7=dom -> dom=0
    final totalCelulas = ((offset + diasNoMes) / 7).ceil() * 7;
    final linhas = totalCelulas ~/ 7;
    final hoje = DateTime.now();

    final cabecalho = Container(
      decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: cores.hairline))),
      child: Row(
        children: [
          for (final nome in nomesDosDiasDaSemana)
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(
                    vertical: compacto ? 6 : 10,
                    horizontal: compacto ? 2 : 10),
                child: Text(
                  compacto ? nome.substring(0, 1) : nome.substring(0, 3),
                  textAlign: compacto ? TextAlign.center : TextAlign.start,
                  style: textos.rotulo.copyWith(fontSize: 11),
                ),
              ),
            ),
        ],
      ),
    );

    final corpo = compacto
        ? Column(
            children: [
              for (var linha = 0; linha < linhas; linha++)
                Row(
                  children: [
                    for (var coluna = 0; coluna < 7; coluna++)
                      Expanded(
                        child: SizedBox(
                          height: 46,
                          child: _celula(context, linha * 7 + coluna - offset,
                              diasNoMes, hoje),
                        ),
                      ),
                  ],
                ),
            ],
          )
        : Expanded(
            child: Column(
              children: [
                for (var linha = 0; linha < linhas; linha++)
                  Expanded(
                    child: Row(
                      children: [
                        for (var coluna = 0; coluna < 7; coluna++)
                          Expanded(
                            child: _celula(context,
                                linha * 7 + coluna - offset, diasNoMes, hoje),
                          ),
                      ],
                    ),
                  ),
              ],
            ),
          );

    return compacto
        ? Column(mainAxisSize: MainAxisSize.min, children: [cabecalho, corpo])
        : Column(children: [cabecalho, corpo]);
  }

  Widget _celula(BuildContext context, int dia, int diasNoMes, DateTime hoje) {
    final cores = context.sivColors;
    final textos = context.sivTextos;

    if (dia < 1 || dia > diasNoMes) {
      return Container(
          decoration: BoxDecoration(
              border: Border.all(color: cores.hairline, width: 0.5)));
    }

    final ehHoje =
        hoje.year == state.ano && hoje.month == state.mes && hoje.day == dia;
    final selecionado = dia == diaSelecionado;
    final ocorrencias = state.porDia[dia] ?? const [];

    if (compacto) {
      final marcas = ocorrencias.take(4).toList();
      return InkWell(
        onTap: () => onDiaSelecionado(dia),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: cores.hairline, width: 0.5),
            color: selecionado ? cores.selecaoFundo : null,
          ),
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 18,
                height: 18,
                alignment: Alignment.center,
                decoration: ehHoje
                    ? BoxDecoration(
                        color: cores.acoAtivo,
                        borderRadius: BorderRadius.circular(3))
                    : null,
                child: Text(
                  '$dia',
                  style: textos.secao.copyWith(
                    fontSize: 12,
                    color: ehHoje ? Colors.white : cores.textoPrincipal,
                  ),
                ),
              ),
              if (marcas.isNotEmpty) ...[
                const SizedBox(height: 3),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 2,
                  children: [
                    for (final o in marcas)
                      DespesaStatusMark(ocorrencia: o, tamanho: 6),
                  ],
                ),
              ],
            ],
          ),
        ),
      );
    }

    final total = state.totalDoDia(dia);
    final visiveis = ocorrencias.take(2).toList();
    final resto = ocorrencias.length - visiveis.length;

    return InkWell(
      onTap: () => onDiaSelecionado(dia),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: cores.hairline, width: 0.5),
          color: selecionado ? cores.selecaoFundo : null,
        ),
        padding: const EdgeInsets.all(6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 20,
                  height: 20,
                  alignment: Alignment.center,
                  decoration: ehHoje
                      ? BoxDecoration(
                          color: cores.acoAtivo,
                          borderRadius: BorderRadius.circular(3))
                      : null,
                  child: Text(
                    '$dia',
                    style: textos.secao.copyWith(
                      fontSize: 13,
                      color: ehHoje ? Colors.white : cores.textoPrincipal,
                    ),
                  ),
                ),
                if (total > 0)
                  Text(formatarReaisCompacto(total),
                      style: textos.apoio.copyWith(fontSize: 10.5)),
              ],
            ),
            const SizedBox(height: 3),
            for (final o in visiveis)
              Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Row(
                  children: [
                    DespesaStatusMark(ocorrencia: o, tamanho: 7),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        o.descricao,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textos.apoio.copyWith(
                          fontSize: 10.5,
                          decoration: o.status == StatusDespesa.cancelado
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            if (resto > 0)
              Text('+$resto mais',
                  style: textos.apoio
                      .copyWith(fontSize: 10, color: cores.acoProfundo)),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Painel do dia (layout largo)
// ---------------------------------------------------------------------------

class _PainelDoDia extends StatelessWidget {
  final CalendarioDeDespesasState state;
  final int dia;

  const _PainelDoDia({required this.state, required this.dia});

  @override
  Widget build(BuildContext context) {
    final cores = context.sivColors;
    final textos = context.sivTextos;
    final data = DateTime(state.ano, state.mes, dia);
    final ocorrencias = state.porDia[dia] ?? const [];
    final hoje = DateTime.now();
    final ehHoje = hoje.year == data.year &&
        hoje.month == data.month &&
        hoje.day == data.day;
    final total = state.totalDoDia(dia);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: cores.superficie,
        border: Border(left: BorderSide(color: cores.hairline)),
      ),
      child: Column(
        children: [
          Divider(height: 1, color: cores.hairline),
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 20, 22, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${nomesDosDiasDaSemana[data.weekday % 7]} · ${_dataCurtaCompleta(data)}'
                  '${ehHoje ? ' · HOJE' : ''}',
                  style: textos.rotulo.copyWith(fontSize: 11),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('${ocorrencias.length} pagamentos',
                        style: textos.secao.copyWith(fontSize: 24)),
                    Text(formatarReais(total),
                        style: textos.secao
                            .copyWith(fontSize: 18, color: cores.acoAtivo)),
                  ],
                ),
              ],
            ),
          ),
          Divider(height: 1, color: cores.hairline),
          Expanded(
            child: ocorrencias.isEmpty
                ? Center(
                    child: Text('Nenhum pagamento neste dia.',
                        style: textos.apoio.copyWith(color: cores.textoApoio)),
                  )
                : ListView(
                    children: [
                      for (final o in ocorrencias)
                        _LinhaOcorrenciaPainel(ocorrencia: o)
                    ],
                  ),
          ),
          Divider(height: 1, color: cores.hairline),
          Padding(
            padding: const EdgeInsets.all(14),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () async {
                  final criada =
                      await abrirLancarDespesa(context, dataInicial: data);
                  if (criada == true && context.mounted) {
                    context.read<CalendarioDeDespesasBloc>().add(
                          CalendarioDeDespesasMesAlterado(
                              ano: state.ano, mes: state.mes),
                        );
                  }
                },
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Lançar despesa neste dia'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LinhaOcorrenciaPainel extends StatelessWidget {
  final DespesaOcorrenciaCalendario ocorrencia;

  const _LinhaOcorrenciaPainel({required this.ocorrencia});

  @override
  Widget build(BuildContext context) {
    final cores = context.sivColors;
    final textos = context.sivTextos;
    final categoria = context
        .read<CalendarioDeDespesasBloc>()
        .state
        .categoriaPorId[ocorrencia.categoriaId];
    final origem = context
        .read<CalendarioDeDespesasBloc>()
        .state
        .origemPorId[ocorrencia.origemPagamentoId];
    final cancelada = ocorrencia.status == StatusDespesa.cancelado;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
      decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: cores.hairline))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  ocorrencia.descricao,
                  style: textos.corpo.copyWith(
                    fontSize: 14,
                    decoration: cancelada ? TextDecoration.lineThrough : null,
                    color: cancelada ? cores.textoApoio : cores.textoPrincipal,
                  ),
                ),
              ),
              Text(formatarReais(ocorrencia.valor),
                  style: textos.secao.copyWith(fontSize: 18)),
            ],
          ),
          const SizedBox(height: 4),
          Text('${categoria ?? '-'} · ${origem ?? '-'}',
              style: textos.apoio.copyWith(fontSize: 12.5)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              _tagStatus(context, ocorrencia),
              if (ocorrencia.totalParcelas != null)
                DespesaTag(
                    'Parcela ${ocorrencia.numeroParcela ?? '?'}/${ocorrencia.totalParcelas}'),
              if (ocorrencia.despesaRecorrentePaiId != null &&
                  !ocorrencia.virtual)
                const DespesaTag('Recorrente', neutra: true),
            ],
          ),
          if (ocorrencia.virtual) ...[
            const SizedBox(height: 8),
            Text(
              'Ocorrência gerada pela recorrência — ainda não lançada. Pagar ou cancelar lança esta ocorrência do mês.',
              style:
                  textos.apoio.copyWith(fontSize: 12, color: cores.textoApoio),
            ),
          ],
          if (ocorrencia.status != StatusDespesa.cancelado) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                if (ocorrencia.status != StatusDespesa.pago)
                  FilledButton.icon(
                    style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 7)),
                    onPressed: () => _marcarComoPago(context, ocorrencia),
                    icon: const Icon(Icons.check, size: 14),
                    label: const Text('Marcar como pago',
                        style: TextStyle(fontSize: 12.5)),
                  ),
                const SizedBox(width: 8),
                if (ocorrencia.status != StatusDespesa.pago)
                  TextButton(
                    onPressed: () => _cancelar(context, ocorrencia),
                    child: const Text('Cancelar',
                        style: TextStyle(fontSize: 12.5)),
                  ),
                const Spacer(),
                TextButton(
                  onPressed: () => _editar(context, ocorrencia),
                  child: const Text('Editar', style: TextStyle(fontSize: 12.5)),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _tagStatus(BuildContext context, DespesaOcorrenciaCalendario o) {
    switch (o.status) {
      case StatusDespesa.pago:
        return DespesaTag('Pago em ${_dataCurta(o.dataPagamento)}');
      case StatusDespesa.pendente:
        return DespesaTag(o.virtual ? 'Prevista' : 'Pendente',
            tracejada: o.virtual);
      case StatusDespesa.cancelado:
        return const DespesaTag('Cancelado', neutra: true);
    }
  }
}

void _marcarComoPago(BuildContext context, DespesaOcorrenciaCalendario o) {
  final id = o.idParaOcorrencia;
  if (id == null) return;
  context.read<CalendarioDeDespesasBloc>().add(
        CalendarioDeDespesasOcorrenciaRegistrada(
            id: id, status: StatusDespesa.pago, dataPagamento: o.dataPagamento),
      );
}

void _cancelar(BuildContext context, DespesaOcorrenciaCalendario o) {
  final id = o.idParaOcorrencia;
  if (id == null) return;
  context.read<CalendarioDeDespesasBloc>().add(
        CalendarioDeDespesasOcorrenciaRegistrada(
            id: id, status: StatusDespesa.cancelado),
      );
}

void _editar(BuildContext context, DespesaOcorrenciaCalendario o) {
  final id = o.idParaOcorrencia;
  if (id == null) return;
  final bloc = context.read<CalendarioDeDespesasBloc>();
  showDialog<void>(
    context: context,
    builder: (dialogContext) => _EditarOcorrenciaDialog(
      mes: bloc.state.mes,
      ocorrencia: o,
      onSalvar: (valor, data) {
        bloc.add(
          CalendarioDeDespesasOcorrenciaRegistrada(
              id: id, valor: valor, dataPagamento: data),
        );
      },
    ),
  );
}

class _EditarOcorrenciaDialog extends StatefulWidget {
  final int mes;
  final DespesaOcorrenciaCalendario ocorrencia;
  final void Function(double valor, DateTime data) onSalvar;

  const _EditarOcorrenciaDialog(
      {required this.mes, required this.ocorrencia, required this.onSalvar});

  @override
  State<_EditarOcorrenciaDialog> createState() =>
      _EditarOcorrenciaDialogState();
}

class _EditarOcorrenciaDialogState extends State<_EditarOcorrenciaDialog> {
  late final TextEditingController _valorController;
  late DateTime _data;

  @override
  void initState() {
    super.initState();
    _valorController =
        TextEditingController(text: widget.ocorrencia.valor.toStringAsFixed(2));
    _data = widget.ocorrencia.dataPagamento;
  }

  @override
  void dispose() {
    _valorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Editar ocorrência de ${nomesDosMeses[widget.mes - 1]}'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _valorController,
            decoration: const InputDecoration(labelText: 'Valor'),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),
          const SizedBox(height: 12),
          InkWell(
            onTap: () async {
              final selecionada = await showDatePicker(
                context: context,
                initialDate: _data,
                firstDate: DateTime(2000),
                lastDate: DateTime(2100),
              );
              if (selecionada != null) setState(() => _data = selecionada);
            },
            child: InputDecorator(
              decoration: const InputDecoration(labelText: 'Data de pagamento'),
              child: Text(_dataCurtaCompleta(_data)),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar')),
        FilledButton(
          onPressed: () {
            final valor =
                double.tryParse(_valorController.text.replaceAll(',', '.'));
            if (valor == null || valor <= 0) return;
            widget.onSalvar(valor, _data);
            Navigator.of(context).pop();
          },
          child: const Text('Salvar'),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Layout estreito: grade mensal compacta + painel do dia empilhado
// ---------------------------------------------------------------------------

class _CalendarioMobile extends StatelessWidget {
  final CalendarioDeDespesasState state;
  final int diaSelecionado;
  final ValueChanged<int> onDiaSelecionado;

  const _CalendarioMobile(
      {required this.state,
      required this.diaSelecionado,
      required this.onDiaSelecionado});

  @override
  Widget build(BuildContext context) {
    final cores = context.sivColors;
    final textos = context.sivTextos;
    final data = DateTime(state.ano, state.mes, diaSelecionado);
    final ocorrencias = state.porDia[diaSelecionado] ?? const [];
    final hoje = DateTime.now();
    final ehHoje = hoje.year == data.year &&
        hoje.month == data.month &&
        hoje.day == data.day;
    final total = state.totalDoDia(diaSelecionado);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
      children: [
        _LegendaTotais(totais: state.totalPorEstado, mostrarCancelado: false),
        const SizedBox(height: 12),
        CardBlueprint(
          padding: EdgeInsets.zero,
          child: _GradeMes(
            state: state,
            diaSelecionado: diaSelecionado,
            onDiaSelecionado: onDiaSelecionado,
            compacto: true,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${nomesDosDiasDaSemana[data.weekday % 7]} · ${_dataCurta(data)}'
              '${ehHoje ? ' · HOJE' : ''}',
              style: textos.rotulo.copyWith(fontSize: 11),
            ),
            Text(formatarReais(total),
                style: textos.secao
                    .copyWith(fontSize: 16, color: cores.acoAtivo)),
          ],
        ),
        const SizedBox(height: 10),
        if (ocorrencias.isEmpty)
          _DiaVazioMobile(state: state, data: data)
        else
          for (final o in ocorrencias)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _CardAgendaOcorrencia(ocorrencia: o),
            ),
      ],
    );
  }
}

class _DiaVazioMobile extends StatelessWidget {
  final CalendarioDeDespesasState state;
  final DateTime data;

  const _DiaVazioMobile({required this.state, required this.data});

  @override
  Widget build(BuildContext context) {
    final textos = context.sivTextos;
    final cores = context.sivColors;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 18),
          child: Text('Nenhum pagamento neste dia.',
              style: textos.apoio.copyWith(color: cores.textoApoio)),
        ),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () async {
              final criada =
                  await abrirLancarDespesa(context, dataInicial: data);
              if (criada == true && context.mounted) {
                context.read<CalendarioDeDespesasBloc>().add(
                      CalendarioDeDespesasMesAlterado(
                          ano: state.ano, mes: state.mes),
                    );
              }
            },
            icon: const Icon(Icons.add, size: 16),
            label: const Text('Lançar despesa neste dia'),
          ),
        ),
      ],
    );
  }
}

class _CardAgendaOcorrencia extends StatelessWidget {
  final DespesaOcorrenciaCalendario ocorrencia;

  const _CardAgendaOcorrencia({required this.ocorrencia});

  @override
  Widget build(BuildContext context) {
    final textos = context.sivTextos;
    final cancelada = ocorrencia.status == StatusDespesa.cancelado;

    return InkWell(
      onTap: () => _abrirBottomSheet(context, ocorrencia),
      child: CardBlueprint(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 44),
          child: Row(
            children: [
              DespesaStatusMark(ocorrencia: ocorrencia),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      ocorrencia.descricao,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textos.corpo.copyWith(
                        fontSize: 14,
                        decoration:
                            cancelada ? TextDecoration.lineThrough : null,
                        color: cancelada
                            ? context.sivColors.textoApoio
                            : context.sivColors.textoPrincipal,
                      ),
                    ),
                    Text(
                      _subtituloAgenda(context, ocorrencia),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textos.apoio.copyWith(fontSize: 11.5),
                    ),
                  ],
                ),
              ),
              Text(formatarReais(ocorrencia.valor),
                  style: textos.secao.copyWith(fontSize: 16)),
            ],
          ),
        ),
      ),
    );
  }
}

String _subtituloAgenda(BuildContext context, DespesaOcorrenciaCalendario o) {
  final origem = context
          .read<CalendarioDeDespesasBloc>()
          .state
          .origemPorId[o.origemPagamentoId] ??
      '-';
  if (o.virtual) return '$origem · prevista';
  if (o.totalParcelas != null) {
    return '$origem · parcela ${o.numeroParcela ?? '?'}/${o.totalParcelas}';
  }
  return origem;
}

void _abrirBottomSheet(BuildContext context, DespesaOcorrenciaCalendario o) {
  final bloc = context.read<CalendarioDeDespesasBloc>();
  final categoria = bloc.state.categoriaPorId[o.categoriaId] ?? '-';
  final origem = bloc.state.origemPorId[o.origemPagamentoId] ?? '-';

  showModalBottomSheet<void>(
    context: context,
    builder: (sheetContext) {
      final textos = sheetContext.sivTextos;
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                      child: Text(o.descricao,
                          style: textos.secao.copyWith(fontSize: 20))),
                  Text(formatarReais(o.valor),
                      style: textos.secao.copyWith(fontSize: 20)),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'Vence ${_dataCurtaCompleta(o.dataPagamento)} · $categoria · $origem',
                style: textos.apoio,
              ),
              const SizedBox(height: 16),
              if (o.status != StatusDespesa.pago)
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: FilledButton.icon(
                    onPressed: () {
                      Navigator.pop(sheetContext);
                      _marcarComoPago(context, o);
                    },
                    icon: const Icon(Icons.check),
                    label: const Text('Marcar como pago'),
                  ),
                ),
              if (o.status != StatusDespesa.cancelado) ...[
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.pop(sheetContext);
                          _editar(context, o);
                        },
                        child: const Text('Editar'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextButton(
                        onPressed: () {
                          Navigator.pop(sheetContext);
                          _cancelar(context, o);
                        },
                        child: const Text('Cancelar despesa'),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      );
    },
  );
}

String _dataCurta(DateTime data) =>
    '${data.day.toString().padLeft(2, '0')}/${data.month.toString().padLeft(2, '0')}';

String _dataCurtaCompleta(DateTime data) =>
    '${data.day.toString().padLeft(2, '0')}/${data.month.toString().padLeft(2, '0')}/${data.year}';
