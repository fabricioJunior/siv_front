import 'package:comercial/models.dart';
import 'package:comercial/presentation/blocs/creditos_devolucao_bloc/creditos_devolucao_bloc.dart';
import 'package:comercial/presentation/widgets/adicionar_credito_modal.dart';
import 'package:comercial/presentation/widgets/credito_form_comum.dart';
import 'package:comercial/presentation/widgets/expirar_credito_dialogo.dart';
import 'package:comercial/presentation/widgets/remover_credito_modal.dart';
import 'package:comercial/presentation/widgets/transferir_credito_dialogo.dart'
    show formatarMoedaBr;
import 'package:core/bloc.dart';
import 'package:core/injecoes/injecoes.dart';
import 'package:core/presentation.dart';
import 'package:core/tema.dart';
import 'package:flutter/material.dart';
import 'package:pessoas/presentation/widgets/cliente_aba_comum.dart';
import 'package:pessoas/presentation/widgets/cliente_abas.dart';

enum _Segmento { creditos, extrato }

class _LinhaExtrato {
  final CreditoDevolucaoMovimentacao mov;
  final double saldo;
  const _LinhaExtrato(this.mov, this.saldo);
}

String _plural(int n, String um, String varios) => n == 1 ? um : varios;

String _dataCompleta(DateTime d) => '${formatarDiaMes(d)}/${d.year}';

int _diasAte(DateTime d) {
  final h = DateTime.now();
  return DateTime(d.year, d.month, d.day)
      .difference(DateTime(h.year, h.month, h.day))
      .inDays;
}

const _rotulosMotivo = {
  'cortesia': 'Cortesia',
  'ajuste': 'Ajuste de saldo',
  'devolucao_sem_romaneio': 'Devolução sem romaneio',
  'outro': 'Outro',
  'lancado_errado': 'Lançado errado',
  'duplicidade': 'Duplicidade',
  'acordo_cliente': 'Acordo com cliente',
  'venceu_sem_uso': 'Venceu sem uso',
  'expirado_manual': 'Expirado manualmente',
  'usado_em_venda': 'Usado em venda',
  'romaneio_cancelado': 'Romaneio cancelado',
};

String _motivo(String? m) {
  if (m == null || m.isEmpty) return '';
  return _rotulosMotivo[m] ?? m.replaceAll('_', ' ');
}

String _tituloCredito(CreditoDevolucao c, {bool curto = false}) {
  final rom = c.romaneioId == null ? '' : 'Romaneio #${c.romaneioId}';
  return switch (c.origem) {
    'devolucao' => curto && rom.isNotEmpty
        ? rom
        : ['Devolução', if (rom.isNotEmpty) rom].join(' · '),
    'avulso' => ['Avulso', if (_motivo(c.motivo).isNotEmpty) _motivo(c.motivo)]
        .join(' · '),
    'transferencia' => ['Transferência', if (rom.isNotEmpty) rom].join(' · '),
    _ => c.codigo,
  };
}

String _subtituloCredito(CreditoDevolucao c) {
  final partes = <String>[c.codigo, formatarData(c.data)];
  if (c.situacao != SituacaoCreditoDevolucao.disponivel) {
    final fim = _motivo(c.motivoEncerramento);
    partes.add(switch (c.situacao) {
      SituacaoCreditoDevolucao.usado => 'usado na venda',
      SituacaoCreditoDevolucao.expirado => 'venceu sem uso',
      _ => fim.isEmpty ? 'removido' : fim.toLowerCase(),
    });
  } else if (c.origem == 'avulso' && c.operadorNome != null) {
    partes.add('por ${c.operadorNome}');
  } else if (c.empresaNome != null) {
    partes.add(c.empresaNome!);
  }
  return partes.join(' · ');
}

/// Aba Crédito de devolução (sem Scaffold; vai dentro da aba do cliente).
/// "Transferir do não cadastrado" fica no cabeçalho da tela do cliente;
/// "Adicionar crédito" é registrado lá só com a permissão PESFM005.
class ClienteCreditoAba extends StatefulWidget {
  final int pessoaId;
  final String nome;

  const ClienteCreditoAba({super.key, required this.pessoaId, this.nome = ''});

  @override
  State<ClienteCreditoAba> createState() => _ClienteCreditoAbaState();
}

class _ClienteCreditoAbaState extends State<ClienteCreditoAba> {
  late final CreditosDevolucaoBloc _bloc;
  ClienteAcoes? _acoes;
  var _segmento = _Segmento.creditos;
  var _verEncerrados = false;

  @override
  void initState() {
    super.initState();
    _bloc = sl<CreditosDevolucaoBloc>()
      ..add(CreditosDevolucaoCarregou(widget.pessoaId));
    if (PermissaoPorNome.acessoPermitido('PESFM005')) {
      _acoes = context
          .getInheritedWidgetOfExactType<ClienteAcoesEscopo>()
          ?.acoes
        ?..definir(ClienteAcao.adicionarCredito, _adicionar);
    }
  }

  @override
  void dispose() {
    _acoes?.definir(ClienteAcao.adicionarCredito, null);
    _bloc.close();
    super.dispose();
  }

  /// Dispara o evento e espera o fim da ação; devolve o erro (null = ok).
  Future<String?> _executar(CreditosDevolucaoEvent evento) async {
    _bloc.add(evento);
    final s = await _bloc.stream.firstWhere((s) => !s.executando);
    return s.erroAcao;
  }

  void _adicionar() {
    final s = _bloc.state;
    mostrarAdicionarCredito(
      context,
      nome: widget.nome,
      saldoAtual: s.resumo.saldoDisponivel,
      validadeDiasPadrao: s.config?.validadeDiasPadrao,
      empresas: s.empresas,
      empresaIdInicial: s.empresaIdSessao,
      aoConfirmar: _executar,
    );
  }

  void _expirar(CreditoDevolucao c) => mostrarExpirarCredito(
        context,
        credito: c,
        titulo: _tituloCredito(c),
        aoConfirmar: _executar,
      );

  void _remover(CreditoDevolucao c) => mostrarRemoverCredito(
        context,
        credito: c,
        titulo: _tituloCredito(c),
        aoConfirmar: _executar,
      );

  @override
  Widget build(BuildContext context) {
    final textos = context.sivTextos;
    final cores = context.sivColors;
    return BlocProvider<CreditosDevolucaoBloc>.value(
      value: _bloc,
      child: BlocConsumer<CreditosDevolucaoBloc, CreditosDevolucaoState>(
        listenWhen: (a, b) => a.acoesConcluidas != b.acoesConcluidas,
        listener: (context, s) => ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Crédito atualizado. Saldo: ${formatarMoedaBr(s.saldoAposAcao ?? s.resumo.saldoDisponivel)}',
            ),
          ),
        ),
        builder: (context, s) {
          if (s.status == CreditosDevolucaoStatus.carregando) {
            return const Center(child: CircularProgressIndicator.adaptive());
          }
          if (s.status == CreditosDevolucaoStatus.erro) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(s.erro ?? '',
                      style: textos.apoio.copyWith(color: cores.vinho)),
                  TextButton.icon(
                    icon: const Icon(Icons.refresh),
                    label: const Text('Tentar novamente'),
                    onPressed: () =>
                        _bloc.add(CreditosDevolucaoCarregou(widget.pessoaId)),
                  ),
                ],
              ),
            );
          }
          final mobile = MediaQuery.sizeOf(context).width <
              SivDimensoes.breakpointMenuDrawer;
          return RefreshIndicator(
            onRefresh: () =>
                _executar(CreditosDevolucaoCarregou(widget.pessoaId)),
            child: ListView(
              padding: EdgeInsets.symmetric(
                horizontal:
                    mobile ? 16 : SivDimensoes.paddingBarraTituloHorizontal,
                vertical: mobile ? 16 : 24,
              ),
              children: [
                _Resumo(resumo: s.resumo, mobile: mobile),
                const SizedBox(height: 16),
                _Cabecalho(
                  mobile: mobile,
                  segmento: _segmento,
                  aoMudar: (v) => setState(() => _segmento = v),
                  disponiveis: s.creditos.where((c) => c.temSaldo).length,
                  encerrados: s.creditos.where((c) => !c.temSaldo).length,
                ),
                const SizedBox(height: 16),
                if (_segmento == _Segmento.creditos)
                  _Creditos(
                    creditos: s.creditos,
                    avisoDias: s.avisoDias,
                    mobile: mobile,
                    verEncerrados: _verEncerrados,
                    aoAlternarEncerrados: () =>
                        setState(() => _verEncerrados = !_verEncerrados),
                    aoExpirar: _expirar,
                    aoRemover: _remover,
                    aoVerExtrato: () =>
                        setState(() => _segmento = _Segmento.extrato),
                  )
                else
                  _Extrato(linhas: _linhasExtrato(s.extrato), mobile: mobile),
              ],
            ),
          );
        },
      ),
    );
  }

  List<_LinhaExtrato> _linhasExtrato(List<CreditoDevolucaoMovimentacao> movs) {
    final ordenadas = [...movs]..sort((a, b) => a.data.compareTo(b.data));
    var acumulado = 0.0;
    final linhas = <_LinhaExtrato>[];
    for (final m in ordenadas) {
      if (!m.cancelado) acumulado += m.valorAssinado;
      linhas.add(_LinhaExtrato(m, acumulado));
    }
    return linhas.reversed.toList();
  }
}

class _Resumo extends StatelessWidget {
  final ResumoCreditoDevolucao resumo;
  final bool mobile;

  const _Resumo({required this.resumo, required this.mobile});

  @override
  Widget build(BuildContext context) {
    final cores = context.sivColors;
    final textos = context.sivTextos;
    final r = resumo;
    final vence = r.venceEm30Dias > 0 && r.proximoVencimento != null;
    final dias = vence ? _diasAte(r.proximoVencimento!) : 0;
    final subSaldo = '${r.quantidadeDisponiveis} '
        '${_plural(r.quantidadeDisponiveis, 'crédito', 'créditos')}';

    if (mobile) {
      return SivMolduraBlueprint(
        fundo: cores.superficie,
        padding: 16,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('SALDO DISPONÍVEL',
                style: textos.rotulo.copyWith(color: cores.textoApoio)),
            const SizedBox(height: 4),
            Text(formatarMoedaBr(r.saldoDisponivel),
                style: textos.valor.copyWith(fontSize: 30)),
            if (vence)
              Text(
                '${formatarMoedaBr(r.venceEm30Dias)} vencem em $dias '
                '${_plural(dias, 'dia', 'dias')}',
                style: textos.apoio.copyWith(color: cores.atencao),
              ),
          ],
        ),
      );
    }

    Widget celula(String rotulo, String valor, String sub, int flex,
        {double tamanho = 22, Color? cor}) {
      return Expanded(
        flex: flex,
        child: Container(
          color: cores.superficie,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(rotulo,
                  style: textos.rotulo.copyWith(color: cores.textoApoio)),
              const SizedBox(height: 4),
              Text(valor,
                  style: textos.valor.copyWith(fontSize: tamanho, color: cor)),
              Text(sub,
                  style: textos.apoio.copyWith(color: cor ?? cores.textoApoio)),
            ],
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(1),
      decoration: BoxDecoration(
        color: cores.hairline,
        border: Border.all(color: cores.hairline),
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            celula('SALDO DISPONÍVEL', formatarMoedaBr(r.saldoDisponivel),
                'em $subSaldo', 13,
                tamanho: 30),
            const SizedBox(width: 1),
            celula(
              'VENCE EM 30 DIAS',
              formatarMoedaBr(r.venceEm30Dias),
              vence
                  ? 'próximo vencimento: ${formatarDiaMes(r.proximoVencimento!)}'
                  : 'nenhum vencimento próximo',
              10,
              cor: vence ? cores.atencao : null,
            ),
            const SizedBox(width: 1),
            celula(
              'USADO · 12 MESES',
              formatarMoedaBr(r.usado12Meses),
              '${r.vendasComUso12Meses} '
                  '${_plural(r.vendasComUso12Meses, 'venda', 'vendas')}',
              10,
            ),
            const SizedBox(width: 1),
            celula(
              'EXPIRADO · 12 MESES',
              formatarMoedaBr(r.expirado12Meses),
              '${r.creditosExpirados12Meses} '
                  '${_plural(r.creditosExpirados12Meses, 'crédito', 'créditos')}',
              10,
            ),
          ],
        ),
      ),
    );
  }
}

class _Cabecalho extends StatelessWidget {
  final bool mobile;
  final _Segmento segmento;
  final ValueChanged<_Segmento> aoMudar;
  final int disponiveis;
  final int encerrados;

  const _Cabecalho({
    required this.mobile,
    required this.segmento,
    required this.aoMudar,
    required this.disponiveis,
    required this.encerrados,
  });

  @override
  Widget build(BuildContext context) {
    final cores = context.sivColors;
    final seg = SegmentedButton<_Segmento>(
      showSelectedIcon: false,
      segments: const [
        ButtonSegment(value: _Segmento.creditos, label: Text('Créditos')),
        ButtonSegment(value: _Segmento.extrato, label: Text('Extrato')),
      ],
      selected: {segmento},
      onSelectionChanged: (s) => aoMudar(s.first),
    );
    if (mobile) {
      return SizedBox(width: double.infinity, child: seg);
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        seg,
        if (segmento == _Segmento.creditos)
          Row(
            children: [
              ClienteTag('Disponíveis · $disponiveis',
                  cor: cores.acoProfundo,
                  fundo: cores.aco.withValues(alpha: 0.15)),
              const SizedBox(width: 8),
              ClienteTag('Encerrados · $encerrados'),
            ],
          ),
      ],
    );
  }
}

class _Creditos extends StatelessWidget {
  final List<CreditoDevolucao> creditos;
  final int avisoDias;
  final bool mobile;
  final bool verEncerrados;
  final VoidCallback aoAlternarEncerrados;
  final void Function(CreditoDevolucao) aoExpirar;
  final void Function(CreditoDevolucao) aoRemover;
  final VoidCallback aoVerExtrato;

  const _Creditos({
    required this.creditos,
    required this.avisoDias,
    required this.mobile,
    required this.verEncerrados,
    required this.aoAlternarEncerrados,
    required this.aoExpirar,
    required this.aoRemover,
    required this.aoVerExtrato,
  });

  @override
  Widget build(BuildContext context) {
    final cores = context.sivColors;
    final textos = context.sivTextos;
    if (creditos.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Text(
            'Este cliente ainda não tem crédito de devolução.',
            style: textos.apoio.copyWith(color: cores.textoApoio),
          ),
        ),
      );
    }
    final disponiveis = creditos.where((c) => c.temSaldo).toList();
    final encerrados = creditos.where((c) => !c.temSaldo).toList();

    Widget lista(List<CreditoDevolucao> itens) => mobile
        ? _ListaMobile(
            itens: itens,
            avisoDias: avisoDias,
            aoExpirar: aoExpirar,
            aoRemover: aoRemover,
            aoVerExtrato: aoVerExtrato,
          )
        : _TabelaCreditos(
            itens: itens,
            avisoDias: avisoDias,
            aoExpirar: aoExpirar,
            aoRemover: aoRemover,
            aoVerExtrato: aoVerExtrato,
          );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (disponiveis.isNotEmpty) lista(disponiveis),
        if (encerrados.isNotEmpty) ...[
          if (mobile)
            TextButton(
              onPressed: aoAlternarEncerrados,
              child: Text(verEncerrados
                  ? 'Ocultar encerrados'
                  : 'Ver ${encerrados.length} '
                      '${_plural(encerrados.length, 'encerrado', 'encerrados')}'),
            ),
          if (!mobile || verEncerrados) ...[
            if (!mobile)
              Padding(
                padding: const EdgeInsets.fromLTRB(4, 20, 4, 8),
                child: Text('ENCERRADOS',
                    style: textos.rotulo.copyWith(color: cores.textoApoio)),
              ),
            lista(encerrados),
          ],
        ],
      ],
    );
  }
}

/// Tag de situação: âmbar = vence em até [avisoDias]; vinho = removido.
Widget _tagSituacao(BuildContext context, CreditoDevolucao c, int avisoDias) {
  final cores = context.sivColors;
  switch (c.situacao) {
    case SituacaoCreditoDevolucao.usado:
      return const ClienteTag('Usado');
    case SituacaoCreditoDevolucao.expirado:
      return const ClienteTag('Expirado');
    case SituacaoCreditoDevolucao.removido:
      return ClienteTag('Removido',
          cor: cores.vinho, fundo: cores.vinho.withValues(alpha: 0.1));
    case SituacaoCreditoDevolucao.disponivel:
      final dias = c.validade == null ? null : _diasAte(c.validade!);
      if (dias != null && dias <= avisoDias) {
        return ClienteTag(
          dias <= 0
              ? 'Vence hoje'
              : 'Vence em $dias ${_plural(dias, 'dia', 'dias')}',
          cor: cores.atencao,
          fundo: cores.atencaoFundo,
        );
      }
      return ClienteTag('Disponível',
          cor: cores.acoProfundo, fundo: cores.aco.withValues(alpha: 0.15));
  }
}

bool _vencendo(CreditoDevolucao c, int avisoDias) =>
    c.temSaldo && c.validade != null && _diasAte(c.validade!) <= avisoDias;

class _TabelaCreditos extends StatelessWidget {
  final List<CreditoDevolucao> itens;
  final int avisoDias;
  final void Function(CreditoDevolucao) aoExpirar;
  final void Function(CreditoDevolucao) aoRemover;
  final VoidCallback aoVerExtrato;

  const _TabelaCreditos({
    required this.itens,
    required this.avisoDias,
    required this.aoExpirar,
    required this.aoRemover,
    required this.aoVerExtrato,
  });

  @override
  Widget build(BuildContext context) {
    final cores = context.sivColors;
    final textos = context.sivTextos;
    return SivTabela(
      colunas: const [
        SivTabelaColuna(titulo: 'CRÉDITO', flex: 6),
        SivTabelaColuna(titulo: 'VALIDADE', flex: 2),
        SivTabelaColuna.numerica(titulo: 'ORIGINAL', flex: 2),
        SivTabelaColuna.numerica(titulo: 'RESTANTE', flex: 2),
        SivTabelaColuna.numerica(titulo: 'SITUAÇÃO', flex: 3),
        SivTabelaColuna(titulo: '', flex: 1),
      ],
      quantidadeLinhas: itens.length,
      linhaBuilder: (context, i) {
        final c = itens[i];
        final vencendo = _vencendo(c, avisoDias);
        final celulas = <Widget>[
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(_tituloCredito(c),
                  style: textos.secao.copyWith(fontSize: 15)),
              Text(_subtituloCredito(c),
                  style: textos.apoio.copyWith(color: cores.textoApoio)),
            ],
          ),
          Text(
            c.validade == null ? '—' : formatarData(c.validade),
            style: textos.corpo.copyWith(
              color: vencendo ? cores.atencao : null,
              fontWeight: vencendo ? FontWeight.w600 : null,
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: Text(formatarMoedaBr(c.valorOriginal),
                style: textos.apoio.copyWith(color: cores.textoApoio)),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: Text(formatarMoedaBr(c.valorRestante),
                style: textos.valor.copyWith(fontSize: 16)),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: _tagSituacao(context, c, avisoDias),
          ),
          c.temSaldo
              ? Align(
                  alignment: Alignment.centerRight,
                  child: _MenuCredito(
                    credito: c,
                    mobile: false,
                    titulo: _tituloCredito(c, curto: true),
                    aoExpirar: () => aoExpirar(c),
                    aoRemover: () => aoRemover(c),
                    aoVerExtrato: aoVerExtrato,
                  ),
                )
              : const SizedBox.shrink(),
        ];
        return [
          for (final w in celulas)
            c.temSaldo ? w : Opacity(opacity: 0.6, child: w),
        ];
      },
    );
  }
}

class _ListaMobile extends StatelessWidget {
  final List<CreditoDevolucao> itens;
  final int avisoDias;
  final void Function(CreditoDevolucao) aoExpirar;
  final void Function(CreditoDevolucao) aoRemover;
  final VoidCallback aoVerExtrato;

  const _ListaMobile({
    required this.itens,
    required this.avisoDias,
    required this.aoExpirar,
    required this.aoRemover,
    required this.aoVerExtrato,
  });

  @override
  Widget build(BuildContext context) {
    final cores = context.sivColors;
    final textos = context.sivTextos;
    return Container(
      decoration: BoxDecoration(
        color: cores.superficie,
        border: Border.all(color: cores.hairline),
        borderRadius: BorderRadius.circular(SivDimensoes.raio),
      ),
      child: Column(
        children: [
          for (var i = 0; i < itens.length; i++)
            Builder(builder: (context) {
              final c = itens[i];
              final vencendo = _vencendo(c, avisoDias);
              final sub = c.temSaldo
                  ? [
                      c.validade == null
                          ? 'sem validade'
                          : 'vence ${formatarDiaMes(c.validade!)}',
                      if (c.valorOriginal != c.valorRestante)
                        'de ${formatarMoedaBr(c.valorOriginal)}',
                    ].join(' · ')
                  : _subtituloCredito(c);
              final linha = Container(
                padding: const EdgeInsets.only(left: 12),
                decoration: BoxDecoration(
                  color: vencendo ? cores.selecaoFundo : null,
                  border: i == 0
                      ? null
                      : Border(top: BorderSide(color: cores.hairline)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(_tituloCredito(c, curto: true),
                                style: textos.secao.copyWith(fontSize: 15)),
                            Text(
                              sub,
                              style: textos.apoio.copyWith(
                                color:
                                    vencendo ? cores.atencao : cores.textoApoio,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Text(formatarMoedaBr(c.valorRestante),
                        style: textos.valor.copyWith(fontSize: 16)),
                    c.temSaldo
                        ? _MenuCredito(
                            credito: c,
                            mobile: true,
                            titulo: _tituloCredito(c, curto: true),
                            aoExpirar: () => aoExpirar(c),
                            aoRemover: () => aoRemover(c),
                            aoVerExtrato: aoVerExtrato,
                          )
                        : const SizedBox(width: 44, height: 44),
                  ],
                ),
              );
              return c.temSaldo ? linha : Opacity(opacity: 0.6, child: linha);
            }),
        ],
      ),
    );
  }
}

/// Menu ⋯ de um crédito com saldo: popup no desktop, bottom sheet no mobile.
/// Expirar/Remover exigem PESFM006 (sem permissão não aparecem).
class _MenuCredito extends StatelessWidget {
  final CreditoDevolucao credito;
  final bool mobile;
  final String titulo;
  final VoidCallback aoExpirar;
  final VoidCallback aoRemover;
  final VoidCallback aoVerExtrato;

  const _MenuCredito({
    required this.credito,
    required this.mobile,
    required this.titulo,
    required this.aoExpirar,
    required this.aoRemover,
    required this.aoVerExtrato,
  });

  @override
  Widget build(BuildContext context) {
    final cores = context.sivColors;
    final textos = context.sivTextos;
    final podeAlterar = PermissaoPorNome.acessoPermitido('PESFM006');
    final itens = <(String, String?, Color?, VoidCallback)>[
      if (podeAlterar)
        (
          'Expirar agora…',
          'Tira ${formatarMoedaBr(credito.valorRestante)} do saldo hoje',
          null,
          aoExpirar,
        ),
      if (podeAlterar)
        (
          'Remover crédito…',
          'Lançado errado ou acordo',
          cores.vinho,
          aoRemover
        ),
      ('Ver no extrato', null, null, aoVerExtrato),
    ];

    Widget texto((String, String?, Color?, VoidCallback) i) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(i.$1, style: textos.corpo.copyWith(color: i.$3)),
            if (i.$2 != null)
              Text(i.$2!,
                  style: textos.apoio.copyWith(color: cores.textoApoio)),
          ],
        );

    if (!mobile) {
      return PopupMenuButton<int>(
        tooltip: 'Ações',
        padding: EdgeInsets.zero,
        icon: Icon(Icons.more_horiz, size: 20, color: cores.textoApoio),
        onSelected: (k) => itens[k].$4(),
        itemBuilder: (_) => [
          for (var k = 0; k < itens.length; k++)
            PopupMenuItem(value: k, child: texto(itens[k])),
        ],
      );
    }
    return SizedBox(
      width: SivDimensoes.alvoToqueMinimo,
      height: SivDimensoes.alvoToqueMinimo,
      child: IconButton(
        tooltip: 'Ações',
        icon: Icon(Icons.more_horiz, size: 20, color: cores.textoApoio),
        onPressed: () => showModalBottomSheet<void>(
          context: context,
          showDragHandle: true,
          builder: (sheet) => SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          '$titulo · ${formatarMoedaBr(credito.valorRestante)}',
                          style: textos.secao),
                      Text(
                        'restantes de ${formatarMoedaBr(credito.valorOriginal)}'
                        '${credito.validade == null ? '' : ' · vence ${_dataCompleta(credito.validade!)}'}',
                        style: textos.apoio.copyWith(color: cores.textoApoio),
                      ),
                    ],
                  ),
                ),
                for (final i in itens)
                  InkWell(
                    onTap: () {
                      Navigator.of(sheet).pop();
                      i.$4();
                    },
                    child: Container(
                      constraints: const BoxConstraints(minHeight: 56),
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      decoration: BoxDecoration(
                        border: Border(top: BorderSide(color: cores.hairline)),
                      ),
                      child: texto(i),
                    ),
                  ),
                TextButton(
                  onPressed: () => Navigator.of(sheet).pop(),
                  child: const Text('Cancelar'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

String _movimento(CreditoDevolucaoMovimentacao m) {
  final origem = switch (m.origem) {
    'devolucao' => 'Devolução',
    'avulso' => 'Avulso',
    'transferencia' => 'Transferência',
    'uso_venda' => 'Uso em venda',
    'remocao' => 'Removido',
    'expiracao' => 'Expirado',
    _ => null,
  };
  if (origem == null) return '${m.tipoDocumento} • ${m.tipoMovimento}';
  final motivo = _motivo(m.motivo);
  return motivo.isEmpty ? origem : '$origem · $motivo';
}

class _Extrato extends StatelessWidget {
  final List<_LinhaExtrato> linhas;
  final bool mobile;
  const _Extrato({required this.linhas, required this.mobile});

  @override
  Widget build(BuildContext context) {
    final textos = context.sivTextos;
    final cores = context.sivColors;
    if (linhas.isEmpty) {
      return Center(
        child: Text(
          'Este cliente ainda não tem crédito de devolução.',
          style: textos.apoio.copyWith(color: cores.textoApoio),
        ),
      );
    }
    return SivTabela(
      colunas: [
        const SivTabelaColuna(titulo: 'DATA', flex: 2),
        const SivTabelaColuna(titulo: 'MOVIMENTO', flex: 4),
        const SivTabelaColuna(titulo: 'CRÉDITO', flex: 2),
        if (!mobile) const SivTabelaColuna(titulo: 'OPERADOR', flex: 2),
        const SivTabelaColuna.numerica(titulo: 'VALOR'),
        const SivTabelaColuna.numerica(titulo: 'SALDO'),
      ],
      quantidadeLinhas: linhas.length,
      rodape: '${linhas.length} movimentação(ões)',
      linhaBuilder: (_, i) {
        final l = linhas[i];
        final m = l.mov;
        final estilo = textos.corpo.copyWith(
          color: m.cancelado ? cores.vinho : null,
          decoration: m.cancelado ? TextDecoration.lineThrough : null,
        );
        final doc = m.romaneioId != null
            ? ' · Romaneio ${m.romaneioId}'
            : m.faturaId != null
                ? ' · Fatura ${m.faturaId}'
                : '';
        final v = m.valorAssinado;
        return [
          Text(formatarDataHora(m.data), style: estilo),
          Text('${_movimento(m)}$doc', style: estilo),
          Text(m.creditoId == null ? '—' : 'C-${m.creditoId}', style: estilo),
          if (!mobile)
            Text(
              m.operadorNome ?? (m.origem == 'expiracao' ? 'Automático' : '—'),
              style: estilo,
            ),
          Text(
            '${v < 0 ? '−' : '+'} ${formatarMoedaBr(v.abs())}',
            style: estilo.copyWith(
              fontWeight: v < 0 ? FontWeight.w400 : FontWeight.w700,
            ),
          ),
          Text(formatarMoedaBr(l.saldo), style: estilo),
        ];
      },
    );
  }
}
