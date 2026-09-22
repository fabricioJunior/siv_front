import 'package:core/bloc.dart';
import 'package:core/injecoes.dart';
import 'package:core/presentation.dart';
import 'package:core/sessao.dart';
import 'package:core/tema.dart';
import 'package:financeiro/models.dart';
import 'package:financeiro/presentation.dart';
import 'package:flutter/material.dart';

import 'abertura_de_caixa_page.dart';
import 'fechamento_de_caixa_page.dart';

const _corEntrada = Color(0xFF2F6A3A);

class FluxoDeCaixaPage extends StatefulWidget {
  final int? empresaId;
  final int? terminalId;

  const FluxoDeCaixaPage({
    super.key,
    required this.empresaId,
    required this.terminalId,
  });

  @override
  State<FluxoDeCaixaPage> createState() => _FluxoDeCaixaPageState();
}

class _FluxoDeCaixaPageState extends State<FluxoDeCaixaPage> {
  final _documentoController = TextEditingController();
  // Conjunto vazio == "todos" (sem filtro), igual ao dropdown anterior.
  final Set<TipoDocumentoExtratoCaixa> _filtrosTipoDocumento = {};
  final Set<TipoHistoricoExtratoCaixa> _filtrosTipoHistorico = {};

  @override
  void dispose() {
    _documentoController.dispose();
    super.dispose();
  }

  List<ExtratoCaixa> _aplicarFiltros(List<ExtratoCaixa> extratos) {
    return extratos.where((item) {
      if (_filtrosTipoDocumento.isNotEmpty &&
          !_filtrosTipoDocumento.contains(item.tipoDocumento)) {
        return false;
      }
      if (_filtrosTipoHistorico.isNotEmpty &&
          !_filtrosTipoHistorico.contains(item.tipoHistorico)) {
        return false;
      }
      return true;
    }).toList(growable: false);
  }

  Future<void> _abrirSelecaoMultipla<T>({
    required String titulo,
    required List<T> opcoes,
    required Set<T> selecionados,
    required String Function(T) rotulo,
    required void Function(Set<T>) onConfirmar,
  }) async {
    final selecaoTemporaria = Set<T>.of(selecionados);

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            return AlertDialog(
              title: Text(titulo),
              content: SizedBox(
                width: 360,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (final opcao in opcoes)
                        CheckboxListTile(
                          contentPadding: EdgeInsets.zero,
                          controlAffinity: ListTileControlAffinity.leading,
                          dense: true,
                          value: selecaoTemporaria.contains(opcao),
                          title: Text(rotulo(opcao)),
                          onChanged: (marcado) {
                            setDialogState(() {
                              if (marcado ?? false) {
                                selecaoTemporaria.add(opcao);
                              } else {
                                selecaoTemporaria.remove(opcao);
                              }
                            });
                          },
                        ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    setDialogState(selecaoTemporaria.clear);
                  },
                  child: const Text('Limpar'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Cancelar'),
                ),
                FilledButton(
                  onPressed: () {
                    onConfirmar(selecaoTemporaria);
                    Navigator.of(dialogContext).pop();
                  },
                  child: const Text('Aplicar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _irParaSuprimentos(BuildContext context, int caixaId) async {
    await Navigator.of(context).pushNamed(
      '/suprimentos',
      arguments: {'caixaId': caixaId},
    );
    if (!context.mounted) return;
    context.read<FluxoDeCaixaBloc>().add(FluxoDeCaixaIniciou(caixaId: caixaId));
  }

  Future<void> _irParaSangrias(BuildContext context, int caixaId) async {
    await Navigator.of(context).pushNamed(
      '/sangrias',
      arguments: {'caixaId': caixaId},
    );
    if (!context.mounted) return;
    context.read<FluxoDeCaixaBloc>().add(FluxoDeCaixaIniciou(caixaId: caixaId));
  }

  Future<void> _irParaLancarDespesa(BuildContext context, int caixaId) async {
    await Navigator.of(context).pushNamed(
      '/lancar_despesa',
      arguments: {'caixaId': caixaId},
    );
    if (!context.mounted) return;
    context.read<FluxoDeCaixaBloc>().add(FluxoDeCaixaIniciou(caixaId: caixaId));
  }

  Future<void> _irParaContagem(BuildContext context, int caixaId) async {
    await Navigator.of(context).pushNamed(
      '/contagem_do_caixa',
      arguments: {'caixaId': caixaId},
    );
    if (!context.mounted) return;
    context.read<FluxoDeCaixaBloc>().add(FluxoDeCaixaIniciou(caixaId: caixaId));
  }

  Future<void> _fecharCaixa(BuildContext context, int caixaId) async {
    final confirmouFechamento = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => FechamentoDeCaixaPage(caixaId: caixaId)),
    );
    if (!context.mounted || confirmouFechamento != true) return;

    final bloc = context.read<FluxoDeCaixaBloc>();
    bloc.add(FluxoDeCaixaFechouCaixa(caixaId: caixaId));

    final resultado = await bloc.stream.firstWhere(
      (s) => s is FluxoDeCaixaFecharSucesso || s is FluxoDeCaixaFecharFalha,
    );
    if (!context.mounted) return;

    if (resultado is FluxoDeCaixaFecharSucesso) {
      await Navigator.of(context).pushNamed(
        '/recibo_fechamento_caixa',
        arguments: {'caixaId': caixaId},
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final empresaId = widget.empresaId;
    final terminalId = widget.terminalId;
    final sessao = sl<IAcessoGlobalSessao>();

    return BlocProvider<FluxoDeCaixaBloc>(
      create: (_) {
        final bloc = sl<FluxoDeCaixaBloc>();

        if (empresaId != null && terminalId != null) {
          bloc.add(
            FluxoDeCaixaRecuperouCaixaAberto(
              empresaId: empresaId,
              terminalId: terminalId,
            ),
          );
        }
        return bloc;
      },
      child: BlocConsumer<FluxoDeCaixaBloc, FluxoDeCaixaState>(
        listenWhen: (previous, current) =>
            previous.caixaId != current.caixaId ||
            previous.caixa?.terminalId != current.caixa?.terminalId,
        listener: (_, state) {
          if (terminalId == null) {
            return;
          }

          sessao.atualizarCaixaIdDaSessao(
            terminalId: terminalId,
            caixaId:
                state.caixa?.terminalId == terminalId ? state.caixaId : null,
          );
        },
        builder: (context, state) {
          final carregando = state is FluxoDeCaixaCarregarEmProgresso ||
              state is FluxoDeCaixaAbrirEmProgresso ||
              state is FluxoDeCaixaFecharEmProgresso;
          final recuperandoCaixaAberto =
              state is FluxoDeCaixaCarregarEmProgresso &&
                  state.caixa == null &&
                  state.caixaId == null;

          final caixaAberto = state.caixa?.situacao == SituacaoCaixa.aberto ||
              (state.caixa?.situacao == SituacaoCaixa.contagem);

          final carregandoAbertura = state is FluxoDeCaixaAbrirEmProgresso;
          final erroRecuperacaoCaixa =
              state is FluxoDeCaixaCarregarFalha && state.caixa == null
                  ? 'Falha ao recuperar o caixa aberto. Tente novamente.'
                  : null;
          final erroAbertura = state is FluxoDeCaixaAbrirFalha
              ? 'Falha ao abrir o caixa. Tente novamente.'
              : null;

          if (recuperandoCaixaAberto) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 12),
                  Text('Verificando caixa aberto...'),
                ],
              ),
            );
          }

          if (!caixaAberto) {
            return AberturaDeCaixaPage(
              empresaId: widget.empresaId,
              terminalId: widget.terminalId,
              empresaNome: sessao.empresaNomeDaSessao,
              terminalNome: sessao.terminalNomeDaSessao,
              carregando: carregandoAbertura,
              erro: erroAbertura ?? erroRecuperacaoCaixa,
              onAbrir: () {
                context.read<FluxoDeCaixaBloc>().add(
                      FluxoDeCaixaAbriuCaixa(
                        empresaId: widget.empresaId!,
                        terminalId: widget.terminalId!,
                      ),
                    );
              },
            );
          }

          final caixaId = state.caixaId;
          final extratosFiltrados = _aplicarFiltros(state.extratos);
          final mobile = MediaQuery.sizeOf(context).width <
              SivDimensoes.breakpointMenuDrawer;

          final acoes = _AcoesFluxoCaixa(
            habilitado: !carregando && caixaId != null,
            onSuprimentos: caixaId == null
                ? null
                : () => _irParaSuprimentos(context, caixaId),
            onSangrias:
                caixaId == null ? null : () => _irParaSangrias(context, caixaId),
            onLancarDespesa: caixaId == null
                ? null
                : () => _irParaLancarDespesa(context, caixaId),
            onContagem:
                caixaId == null ? null : () => _irParaContagem(context, caixaId),
            onFecharCaixa:
                caixaId == null ? null : () => _fecharCaixa(context, caixaId),
          );

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _CabecalhoCaixa(
                caixa: state.caixa!,
                habilitado: !carregando,
                onAtualizar: caixaId == null
                    ? null
                    : () => context
                        .read<FluxoDeCaixaBloc>()
                        .add(FluxoDeCaixaIniciou(caixaId: caixaId)),
              ),
              const SizedBox(height: SivDimensoes.gapCards),
              if (mobile) ...[
                _ResumoMovimentacoesExtrato(
                  totalEntradas: state.totalEntradas,
                  totalSaidas: state.totalSaidas,
                  saldo: state.saldo,
                ),
                const SizedBox(height: SivDimensoes.gapCards),
                _FiltrosExtrato(
                  documentoController: _documentoController,
                  filtrosTipoDocumento: _filtrosTipoDocumento,
                  filtrosTipoHistorico: _filtrosTipoHistorico,
                  onFiltrarDocumento: (value) => context
                      .read<FluxoDeCaixaBloc>()
                      .add(FluxoDeCaixaFiltrouDocumento(documento: value)),
                  onAbrirSelecaoMultipla: _abrirSelecaoMultipla,
                  onFormaDePagamentoAlterada: (selecionados) => setState(() {
                    _filtrosTipoDocumento
                      ..clear()
                      ..addAll(selecionados);
                  }),
                  onTipoLancamentoAlterado: (selecionados) => setState(() {
                    _filtrosTipoHistorico
                      ..clear()
                      ..addAll(selecionados);
                  }),
                ),
                const SizedBox(height: SivDimensoes.gapCards),
                ..._avisos(context, state, carregando),
              ],
              Expanded(
                child: mobile
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          acoes,
                          const SizedBox(height: SivDimensoes.gapCards),
                          Expanded(
                            child: _ExtratoLista(
                              extratos: extratosFiltrados,
                              temExtratos: state.extratos.isNotEmpty,
                              mobile: true,
                            ),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton.icon(
                              onPressed: acoes.onFecharCaixa,
                              icon: const Icon(Icons.lock_outline),
                              label: const Text('FECHAR CAIXA'),
                            ),
                          ),
                        ],
                      )
                    : Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                _ResumoMovimentacoesExtrato(
                                  totalEntradas: state.totalEntradas,
                                  totalSaidas: state.totalSaidas,
                                  saldo: state.saldo,
                                ),
                                const SizedBox(height: SivDimensoes.gapCards),
                                _FiltrosExtrato(
                                  documentoController: _documentoController,
                                  filtrosTipoDocumento: _filtrosTipoDocumento,
                                  filtrosTipoHistorico: _filtrosTipoHistorico,
                                  onFiltrarDocumento: (value) => context
                                      .read<FluxoDeCaixaBloc>()
                                      .add(FluxoDeCaixaFiltrouDocumento(
                                          documento: value)),
                                  onAbrirSelecaoMultipla:
                                      _abrirSelecaoMultipla,
                                  onFormaDePagamentoAlterada:
                                      (selecionados) => setState(() {
                                    _filtrosTipoDocumento
                                      ..clear()
                                      ..addAll(selecionados);
                                  }),
                                  onTipoLancamentoAlterado: (selecionados) =>
                                      setState(() {
                                    _filtrosTipoHistorico
                                      ..clear()
                                      ..addAll(selecionados);
                                  }),
                                ),
                                const SizedBox(height: SivDimensoes.gapCards),
                                ..._avisos(context, state, carregando),
                                Expanded(
                                  child: _ExtratoLista(
                                    extratos: extratosFiltrados,
                                    temExtratos: state.extratos.isNotEmpty,
                                    mobile: false,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: SivDimensoes.gapCards),
                          _SidebarAcoes(acoes: acoes),
                        ],
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

List<Widget> _avisos(
  BuildContext context,
  FluxoDeCaixaState state,
  bool carregando,
) {
  return [
    if (carregando)
      const Padding(
        padding: EdgeInsets.only(bottom: 12),
        child: LinearProgressIndicator(),
      ),
    if (state is FluxoDeCaixaCarregarFalha ||
        state is FluxoDeCaixaAbrirFalha ||
        state is FluxoDeCaixaFecharFalha)
      Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Text(
          'Falha ao processar fluxo de caixa.',
          style: context.sivTextos.corpo
              .copyWith(color: context.sivColors.vinho),
        ),
      ),
  ];
}

class _SidebarAcoes extends StatelessWidget {
  final Widget acoes;

  const _SidebarAcoes({required this.acoes});

  @override
  Widget build(BuildContext context) {
    final cores = context.sivColors;

    return Container(
      width: 260,
      padding: const EdgeInsets.all(SivDimensoes.gapCards),
      decoration: BoxDecoration(
        color: cores.superficieRecuada,
        border: Border(left: BorderSide(color: cores.hairline)),
      ),
      child: acoes,
    );
  }
}

class _FiltrosExtrato extends StatelessWidget {
  final TextEditingController documentoController;
  final Set<TipoDocumentoExtratoCaixa> filtrosTipoDocumento;
  final Set<TipoHistoricoExtratoCaixa> filtrosTipoHistorico;
  final ValueChanged<String> onFiltrarDocumento;
  final Future<void> Function<T>({
    required String titulo,
    required List<T> opcoes,
    required Set<T> selecionados,
    required String Function(T) rotulo,
    required void Function(Set<T>) onConfirmar,
  }) onAbrirSelecaoMultipla;
  final void Function(Set<TipoDocumentoExtratoCaixa>)
      onFormaDePagamentoAlterada;
  final void Function(Set<TipoHistoricoExtratoCaixa>) onTipoLancamentoAlterado;

  const _FiltrosExtrato({
    required this.documentoController,
    required this.filtrosTipoDocumento,
    required this.filtrosTipoHistorico,
    required this.onFiltrarDocumento,
    required this.onAbrirSelecaoMultipla,
    required this.onFormaDePagamentoAlterada,
    required this.onTipoLancamentoAlterado,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: documentoController,
            decoration: const InputDecoration(
              hintText: 'Filtrar por documento…',
              prefixIcon: Icon(Icons.search_outlined),
            ),
            onSubmitted: onFiltrarDocumento,
          ),
        ),
        const SizedBox(width: 8),
        OutlinedButton.icon(
          onPressed: () => onAbrirSelecaoMultipla<TipoDocumentoExtratoCaixa>(
            titulo: 'Tipo da forma de pagamento',
            opcoes: TipoDocumentoExtratoCaixa.values,
            selecionados: filtrosTipoDocumento,
            rotulo: _rotuloTipoDocumento,
            onConfirmar: onFormaDePagamentoAlterada,
          ),
          icon: const Icon(Icons.filter_alt_outlined, size: 18),
          label: Text(
            filtrosTipoDocumento.isEmpty
                ? 'Forma de pagamento'
                : 'Forma de pagamento (${filtrosTipoDocumento.length})',
          ),
        ),
        const SizedBox(width: 8),
        OutlinedButton.icon(
          onPressed: () => onAbrirSelecaoMultipla<TipoHistoricoExtratoCaixa>(
            titulo: 'Tipo de lançamento',
            opcoes: TipoHistoricoExtratoCaixa.values,
            selecionados: filtrosTipoHistorico,
            rotulo: _rotuloHistorico,
            onConfirmar: onTipoLancamentoAlterado,
          ),
          icon: const Icon(Icons.filter_alt_outlined, size: 18),
          label: Text(
            filtrosTipoHistorico.isEmpty
                ? 'Tipo de lançamento'
                : 'Tipo de lançamento (${filtrosTipoHistorico.length})',
          ),
        ),
      ],
    );
  }
}

class _CabecalhoCaixa extends StatelessWidget {
  final Caixa caixa;
  final bool habilitado;
  final VoidCallback? onAtualizar;

  const _CabecalhoCaixa({
    required this.caixa,
    required this.habilitado,
    required this.onAtualizar,
  });

  @override
  Widget build(BuildContext context) {
    final cores = context.sivColors;
    final textos = context.sivTextos;
    final (rotulo, corTag) = switch (caixa.situacao) {
      SituacaoCaixa.aberto => ('ABERTO', cores.acoProfundo),
      SituacaoCaixa.contagem => ('EM CONTAGEM', cores.atencao),
      SituacaoCaixa.fechado => ('FECHADO', cores.textoApoio),
    };

    return Row(
      children: [
        Text('Caixa #${caixa.id}', style: textos.secao.copyWith(fontSize: 21)),
        const SizedBox(width: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: cores.selecaoFundo,
            borderRadius: BorderRadius.circular(SivDimensoes.raio),
          ),
          child: Text(
            rotulo,
            style: textos.rotulo.copyWith(color: corTag, fontSize: 10.5),
          ),
        ),
        const Spacer(),
        OutlinedButton.icon(
          onPressed: habilitado ? onAtualizar : null,
          icon: const Icon(Icons.refresh, size: 16),
          label: const Text('Atualizar extrato'),
        ),
      ],
    );
  }
}

class _ResumoMovimentacoesExtrato extends StatelessWidget {
  final double totalEntradas;
  final double totalSaidas;
  final double saldo;

  const _ResumoMovimentacoesExtrato({
    required this.totalEntradas,
    required this.totalSaidas,
    required this.saldo,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _CartaoValor(
            titulo: 'ENTRADAS',
            valor: _formatarMoeda(totalEntradas),
            cor: _corEntrada,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _CartaoValor(
            titulo: 'SAÍDAS',
            valor: _formatarMoeda(totalSaidas),
            cor: context.sivColors.vinho,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _CartaoValor(
            titulo: 'SALDO DO PERÍODO',
            valor: _formatarMoeda(saldo),
            cor: context.sivColors.acoAtivo,
            destaque: true,
          ),
        ),
      ],
    );
  }
}

class _CartaoValor extends StatelessWidget {
  final String titulo;
  final String valor;
  final Color cor;
  final bool destaque;

  const _CartaoValor({
    required this.titulo,
    required this.valor,
    required this.cor,
    this.destaque = false,
  });

  @override
  Widget build(BuildContext context) {
    final cores = context.sivColors;
    final textos = context.sivTextos;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: destaque ? cores.selecaoFundo : cores.superficie,
        border: Border.all(color: destaque ? cores.aco : cores.hairline),
        borderRadius: BorderRadius.circular(SivDimensoes.raio),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(titulo, style: textos.rotulo.copyWith(color: cor, fontSize: 10.5)),
          const SizedBox(height: 3),
          Text(
            valor,
            style: textos.secao.copyWith(color: cor, fontSize: 22),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _AcoesFluxoCaixa extends StatelessWidget {
  final bool habilitado;
  final VoidCallback? onSuprimentos;
  final VoidCallback? onSangrias;
  final VoidCallback? onLancarDespesa;
  final VoidCallback? onContagem;
  final VoidCallback? onFecharCaixa;

  const _AcoesFluxoCaixa({
    required this.habilitado,
    required this.onSuprimentos,
    required this.onSangrias,
    required this.onLancarDespesa,
    required this.onContagem,
    required this.onFecharCaixa,
  });

  @override
  Widget build(BuildContext context) {
    final mobile = MediaQuery.sizeOf(context).width <
        SivDimensoes.breakpointMenuDrawer;

    final botoes = [
      _BotaoAcao(
        icon: Icons.savings_outlined,
        label: 'Suprimentos',
        onPressed: habilitado ? onSuprimentos : null,
        vertical: mobile,
      ),
      _BotaoAcao(
        icon: Icons.money_off_csred_outlined,
        label: 'Sangrias',
        onPressed: habilitado ? onSangrias : null,
        vertical: mobile,
      ),
      _BotaoAcao(
        icon: Icons.request_quote_outlined,
        label: 'Lançar despesa',
        onPressed: habilitado ? onLancarDespesa : null,
        vertical: mobile,
      ),
      _BotaoAcao(
        icon: Icons.calculate_outlined,
        label: 'Contagem do caixa',
        onPressed: habilitado ? onContagem : null,
        vertical: mobile,
      ),
    ];

    if (mobile) {
      return Row(
        children: [
          for (final botao in botoes) ...[
            Expanded(child: botao),
            if (botao != botoes.last) const SizedBox(width: 7),
          ],
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final botao in botoes) ...[
          botao,
          const SizedBox(height: 10),
        ],
        const Spacer(),
        FilledButton.icon(
          onPressed: onFecharCaixa,
          icon: const Icon(Icons.lock_outline),
          label: const Text('FECHAR CAIXA'),
        ),
      ],
    );
  }
}

class _BotaoAcao extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onPressed;
  final bool vertical;

  const _BotaoAcao({
    required this.icon,
    required this.label,
    required this.onPressed,
    required this.vertical,
  });

  @override
  Widget build(BuildContext context) {
    if (vertical) {
      return OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(fontSize: 11),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 18),
        label: Text(label),
      ),
    );
  }
}

class _ExtratoLista extends StatelessWidget {
  final List<ExtratoCaixa> extratos;
  final bool temExtratos;
  final bool mobile;

  const _ExtratoLista({
    required this.extratos,
    required this.temExtratos,
    required this.mobile,
  });

  @override
  Widget build(BuildContext context) {
    if (extratos.isEmpty) {
      return Center(
        child: Text(
          temExtratos
              ? 'Nenhum lançamento encontrado para os filtros selecionados.'
              : 'Nenhum lançamento no extrato.',
          textAlign: TextAlign.center,
          style: context.sivTextos.corpo,
        ),
      );
    }

    if (mobile) {
      return ListView.separated(
        itemCount: extratos.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, index) => _ExtratoCardMobile(item: extratos[index]),
      );
    }

    return SingleChildScrollView(
      child: SivTabela(
        colunas: const [
          SivTabelaColuna(titulo: 'LANÇAMENTO', flex: 3),
          SivTabelaColuna(titulo: 'FORMA', flex: 1),
          SivTabelaColuna(titulo: 'DOCUMENTO', flex: 2),
          SivTabelaColuna.numerica(titulo: 'VALOR', flex: 1),
        ],
        quantidadeLinhas: extratos.length,
        linhaBuilder: (context, indice) => _linhaExtrato(context, extratos[indice]),
      ),
    );
  }

  List<Widget> _linhaExtrato(BuildContext context, ExtratoCaixa item) {
    final textos = context.sivTextos;
    final cores = context.sivColors;
    final isDebito = item.tipoMovimento == TipoMovimentoExtratoCaixa.debito;
    final cor = isDebito ? cores.vinho : _corEntrada;

    return [
      Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: '${_rotuloHistorico(item.tipoHistorico)}\n',
              style: textos.corpo.copyWith(fontWeight: FontWeight.w600),
            ),
            TextSpan(
              text: _formatarDataHora(item.criadoEm),
              style: textos.apoio.copyWith(color: cores.textoApoio),
            ),
          ],
        ),
      ),
      Text(_rotuloTipoDocumento(item.tipoDocumento), style: textos.corpo.copyWith(fontSize: 13)),
      Text(
        'Doc. ${item.documento}',
        style: textos.apoio.copyWith(color: cores.textoApoio),
      ),
      Text(
        '${isDebito ? '-' : '+'} ${_formatarMoeda(item.valor)}',
        textAlign: TextAlign.right,
        style: textos.corpo.copyWith(color: cor, fontWeight: FontWeight.w700),
      ),
    ];
  }
}

class _ExtratoCardMobile extends StatelessWidget {
  final ExtratoCaixa item;

  const _ExtratoCardMobile({required this.item});

  @override
  Widget build(BuildContext context) {
    final cores = context.sivColors;
    final textos = context.sivTextos;
    final isDebito = item.tipoMovimento == TipoMovimentoExtratoCaixa.debito;
    final cor = isDebito ? cores.vinho : _corEntrada;

    return SivCard(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  _rotuloHistorico(item.tipoHistorico),
                  style: textos.corpo.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
              Text(
                '${isDebito ? '-' : '+'}${item.valor.toStringAsFixed(2).replaceAll('.', ',')}',
                style: textos.corpo.copyWith(color: cor, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            '${_rotuloTipoDocumento(item.tipoDocumento)} · ${_formatarDataHora(item.criadoEm)}',
            style: textos.apoio.copyWith(color: cores.textoApoio),
          ),
          if (item.cancelado) ...[
            const SizedBox(height: 4),
            Text(
              'Lançamento cancelado${item.motivoCancelamento?.trim().isNotEmpty == true ? ': ${item.motivoCancelamento!.trim()}' : ''}',
              style: textos.apoio.copyWith(color: cores.vinho, fontWeight: FontWeight.w600),
            ),
          ],
        ],
      ),
    );
  }
}

String _rotuloTipoDocumento(TipoDocumentoExtratoCaixa tipo) {
  switch (tipo) {
    case TipoDocumentoExtratoCaixa.dinheiro:
      return 'Dinheiro';
    case TipoDocumentoExtratoCaixa.pix:
      return 'Pix';
    case TipoDocumentoExtratoCaixa.cartao:
      return 'Cartao';
    case TipoDocumentoExtratoCaixa.cheque:
      return 'Cheque';
    case TipoDocumentoExtratoCaixa.fatura:
      return 'Fatura';
    case TipoDocumentoExtratoCaixa.troco:
      return 'Troco';
    case TipoDocumentoExtratoCaixa.voucher:
      return 'Voucher';
    case TipoDocumentoExtratoCaixa.tedDoc:
      return 'TED/DOC';
    case TipoDocumentoExtratoCaixa.adiantamento:
      return 'Adiantamento';
    case TipoDocumentoExtratoCaixa.creditoDeDevolucao:
      return 'Credito de devolucao';
  }
}

String _rotuloHistorico(TipoHistoricoExtratoCaixa tipo) {
  switch (tipo) {
    case TipoHistoricoExtratoCaixa.aberturaDeCaixa:
      return 'Abertura de caixa';
    case TipoHistoricoExtratoCaixa.suprimento:
      return 'Suprimento';
    case TipoHistoricoExtratoCaixa.sangria:
      return 'Sangria';
    case TipoHistoricoExtratoCaixa.lancamentoDeDespesa:
      return 'Lançamento de despesa';
    case TipoHistoricoExtratoCaixa.venda:
      return 'Venda';
    case TipoHistoricoExtratoCaixa.devolucao:
      return 'Devolução';
    case TipoHistoricoExtratoCaixa.troco:
      return 'Troco';
    case TipoHistoricoExtratoCaixa.adiantamento:
      return 'Adiantamento';
    case TipoHistoricoExtratoCaixa.fechamentoDeCaixa:
      return 'Fechamento de caixa';
    case TipoHistoricoExtratoCaixa.outros:
      return 'Outros';
  }
}

String _formatarDataHora(DateTime data) {
  final local = data.toLocal();
  final dia = local.day.toString().padLeft(2, '0');
  final mes = local.month.toString().padLeft(2, '0');
  final ano = local.year.toString();
  final hora = local.hour.toString().padLeft(2, '0');
  final minuto = local.minute.toString().padLeft(2, '0');
  return '$dia/$mes/$ano $hora:$minuto';
}

String _formatarMoeda(double valor) {
  return 'R\$ ${valor.toStringAsFixed(2).replaceAll('.', ',')}';
}
