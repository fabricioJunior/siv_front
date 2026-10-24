import 'package:comercial/presentation/blocs/pagamentos_realizados_bloc/pagamentos_realizados_bloc.dart';
import 'package:comercial/presentation/pagamento/pagamento_contexto.dart';
import 'package:comercial/presentation/pagamento/pagamento_resumo.dart';
import 'package:core/bloc.dart';
import 'package:core/presentation.dart';
import 'package:core/seletores.dart';
import 'package:core/tema.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Etapa de pagamento em tela cheia, reutilizável por Venda, Romaneio,
/// Pedido e Consignação · acerto (o que muda é o [PagamentoContexto]).
///
/// Quem monta a tela de origem é dono do `BlocProvider<PagamentosRealizadosBloc>`
/// (`contexto.criarBloc()`), para o Esc preservar o estado. [onConfirmado]
/// recebe o `Map` de saída e deve, se o resultado não puder ser usado,
/// disparar `PagamentosRealizadosReaberto` no bloc.
class PagamentoEtapa extends StatefulWidget {
  final PagamentoContexto contexto;
  final FormaPagamentoGradeWidget formaPagamentoGrade;
  final void Function(Map<String, dynamic> resultado) onConfirmado;
  final VoidCallback onVoltar;

  const PagamentoEtapa({
    super.key,
    required this.contexto,
    required this.formaPagamentoGrade,
    required this.onConfirmado,
    required this.onVoltar,
  });

  /// Mesmo formato de saída do antigo widget de pagamentos (removido); recurso
  /// desligado no contexto não sai com valor.
  static Map<String, dynamic> resultado(
    PagamentosRealizadosState state,
    PagamentoRecursos r,
  ) {
    final incluirCpf = r.cpfNota && state.incluirCpfNaNota;
    final enviarEmail = r.emailNota && state.enviarNotaPorEmail;
    return {
      'formasDePagamentoRealizadas': state.resultado,
      'desconto': state.valorDescontoAplicado,
      'descontosItens': state.descontosItensAplicado.entries
          .map((e) => {'produtoId': e.key, 'valor': e.value})
          .toList(),
      'descontosPromocao': r.promocoes
          ? state.promocaoEscolhidaPorItem.entries
              .where((e) => !e.value.ehCupom)
              .map((e) => {'produtoId': e.key, 'promocaoId': e.value.id})
              .toList()
          : const [],
      'cupons': r.cupom ? state.cuponsParaPayload : const [],
      'valorTaxaEntrega': state.valorTaxaEntregaAplicado,
      'resumoFormasDePagamento': state.linhas
          .where((l) => l.formaDePagamento != null)
          .map((l) => {'nome': l.formaDePagamento!.nome, 'valor': l.valor})
          .toList(),
      'valorTotalRecebido': state.valorLiquido,
      'valorTroco': state.valorTroco,
      'incluirCpfNaNota': incluirCpf,
      'cpfNaNota': incluirCpf ? state.cpfNaNota : '',
      'pontuarFidelidade': r.pontuarFidelidade &&
          state.clienteElegivelFidelidade &&
          state.pontuarFidelidade,
      'enviarNotaPorEmail': enviarEmail,
      'emailNota': enviarEmail
          ? (state.exigeEmailNota
              ? state.emailNota.trim()
              : (state.emailClienteCadastrado ?? ''))
          : '',
    };
  }

  @override
  State<PagamentoEtapa> createState() => _PagamentoEtapaState();
}

class _PagamentoEtapaState extends State<PagamentoEtapa> {
  static const _larguraDesktop = 900.0;

  final _descontoGeral = ValueNotifier(false);
  final _focoValor = FocusNode();
  final _foco = FocusNode();
  final _focoGrade = FocusNode();
  bool _online = false;
  String? _linhaAtivaId;

  PagamentoContexto get _c => widget.contexto;

  // A etapa entra na página sem rota própria (a leitura segue montada por
  // baixo, com o foco no campo de código): toma o foco ao montar para
  // F9/Esc/F4 valerem de cara; ao sair, o foco volta ao campo anterior.
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _foco.requestFocus();
    });
  }

  @override
  void dispose() {
    _descontoGeral.dispose();
    _focoValor.dispose();
    _focoGrade.dispose();
    _foco.dispose();
    super.dispose();
  }

  PagamentoRealizadoLinha _ativa(PagamentosRealizadosState s) => s.linhas
      .firstWhere((l) => l.id == _linhaAtivaId, orElse: () => s.linhas.last);

  String? get _tipoOperacao => switch (_c.tipoOperacao) {
        PagamentoTipoOperacao.manual => 'manual',
        PagamentoTipoOperacao.online => 'online',
        PagamentoTipoOperacao.escolher => _online ? 'online' : 'manual',
      };

  void _escolherForma(PagamentosRealizadosState s, SelectData forma) {
    final bloc = context.read<PagamentosRealizadosBloc>();
    final linha = _ativa(s);
    bloc.add(
      PagamentosRealizadosFormaAlterada(
        linhaId: linha.id,
        formaDePagamento: forma,
      ),
    );
    if (linha.valorTexto.trim().isEmpty) {
      final outras = s.linhas
          .where((l) => l.id != linha.id)
          .fold<double>(0, (soma, l) => soma + l.valor);
      final falta = s.valorTotalAPagar - outras;
      if (falta > 0.004) {
        bloc.add(
          PagamentosRealizadosValorAlterado(
            linhaId: linha.id,
            valorTexto: falta.toStringAsFixed(2).replaceAll('.', ','),
          ),
        );
      }
    }
    _focarGrade();
  }

  // Letras e setas só chegam à grade com o foco nela; o valor vem preenchido,
  // então o foco volta à grade e F2 leva ao campo de valor.
  void _focarGrade() =>
      (_focoGrade.context != null ? _focoGrade : _foco).requestFocus();

  void _alternarValorGrade() =>
      _focoValor.hasFocus ? _focarGrade() : _focoValor.requestFocus();

  void _confirmar() {
    final bloc = context.read<PagamentosRealizadosBloc>();
    if (bloc.state.step == PagamentosRealizadosStep.editando) {
      bloc.add(const PagamentosRealizadosFinalizacaoSolicitada());
    }
  }

  void _dividir() {
    setState(() => _linhaAtivaId = null);
    context
        .read<PagamentosRealizadosBloc>()
        .add(const PagamentosRealizadosLinhaAdicionada());
  }

  void _abrirFolha(
      String titulo, Widget Function(PagamentosRealizadosState) corpo) {
    final bloc = context.read<PagamentosRealizadosBloc>();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => BlocProvider.value(
        value: bloc,
        child: BlocBuilder<PagamentosRealizadosBloc, PagamentosRealizadosState>(
          builder: (context, state) => SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                16,
                16,
                16,
                16 + MediaQuery.viewInsetsOf(context).bottom,
              ),
              child: corpo(state),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cores = context.sivColors;

    return BlocConsumer<PagamentosRealizadosBloc, PagamentosRealizadosState>(
      listenWhen: (a, b) =>
          a.step != b.step && b.step == PagamentosRealizadosStep.concluido,
      listener: (context, state) {
        UsoFormasPagamento.registrar(
          state.linhas.map((l) => l.formaDePagamento?.id).whereType<int>(),
        );
        widget.onConfirmado(PagamentoEtapa.resultado(state, _c.recursos));
      },
      builder: (context, state) {
        final Widget corpo;
        if (state.step == PagamentosRealizadosStep.inicial ||
            state.step == PagamentosRealizadosStep.carregando) {
          corpo = const Center(child: CircularProgressIndicator.adaptive());
        } else if (state.step == PagamentosRealizadosStep.falha) {
          corpo = Center(
            child: Text(
              state.erro ?? 'Falha ao carregar o pagamento.',
              style: context.sivTextos.corpo.copyWith(color: cores.vinho),
            ),
          );
        } else {
          corpo = LayoutBuilder(
            builder: (context, c) => c.maxWidth >= _larguraDesktop
                ? _desktop(state)
                : _mobile(state),
          );
        }

        return CallbackShortcuts(
          bindings: {
            const SingleActivator(LogicalKeyboardKey.escape): widget.onVoltar,
            const SingleActivator(LogicalKeyboardKey.f9): _confirmar,
            const SingleActivator(LogicalKeyboardKey.f2): _alternarValorGrade,
            if (_c.recursos.descontoGeral && !_c.descontosTravados)
              const SingleActivator(LogicalKeyboardKey.f4): () =>
                  _descontoGeral.value = !_descontoGeral.value,
          },
          child: Focus(
            focusNode: _foco,
            child: Material(
              color: cores.papel,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _Cabecalho(contexto: _c, onVoltar: widget.onVoltar),
                  Expanded(child: corpo),
                  if (state.step == PagamentosRealizadosStep.editando)
                    _Rodape(
                      contexto: _c,
                      rotulo: _online && _c.rotuloConfirmarOnline != null
                          ? _c.rotuloConfirmarOnline!
                          : _c.rotuloConfirmar,
                      state: state,
                      ativaTemForma: _ativa(state).formaDePagamento != null,
                      onDividir: _dividir,
                      onConfirmar: _confirmar,
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _desktop(PagamentosRealizadosState state) {
    return Padding(
      padding: const EdgeInsets.all(SivDimensoes.gapCards),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 480,
            child: SivCard(
              child: SingleChildScrollView(
                child: PagamentoResumo(
                  state: state,
                  contexto: _c,
                  descontoGeralAberto: _descontoGeral,
                ),
              ),
            ),
          ),
          const SizedBox(width: SivDimensoes.gapCards),
          Expanded(
            child: SingleChildScrollView(child: _recebimento(state)),
          ),
        ],
      ),
    );
  }

  Widget _mobile(PagamentosRealizadosState state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _recebimento(state, compacto: true),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _abrirFolha(
                    'Itens e descontos',
                    (s) => PagamentoResumo(
                      state: s,
                      contexto: _c,
                      descontoGeralAberto: _descontoGeral,
                    ),
                  ),
                  child: const Text('Itens e descontos'),
                ),
              ),
              if (_temNota) ...[
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _abrirFolha(
                      'Nota',
                      (s) => _NotaBloco(state: s, recursos: _c.recursos),
                    ),
                    child: const Text('Nota'),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  bool get _temNota =>
      _c.recursos.cpfNota ||
      _c.recursos.emailNota ||
      _c.recursos.pontuarFidelidade;

  Widget _recebimento(PagamentosRealizadosState state,
      {bool compacto = false}) {
    final textos = context.sivTextos;
    final restricao = state.formasPagamentoPermitidasIds;
    final ativa = _ativa(state);
    final saldo = _c.recursos.creditoCliente &&
            state.pessoaId != null &&
            !state.clienteGenerico
        ? state.saldoCreditoDevolucao
        : 0.0;
    final temDinheiro = state.linhas.any((l) => l.ehDinheiro);
    final trocoSemDinheiro =
        !temDinheiro && state.valorTotalBruto - state.valorTotalAPagar > 0.01;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_c.tipoOperacao == PagamentoTipoOperacao.escolher) ...[
          Row(
            children: [
              Expanded(
                child: ChoiceButton(
                  rotulo: 'NO ATO DA ENTREGA',
                  selecionado: !_online,
                  onTap: () => setState(() => _online = false),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ChoiceButton(
                  rotulo: 'ONLINE · LINK / QR',
                  selecionado: _online,
                  onTap: () => setState(() => _online = true),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
        ],
        _Faixa(state: state, contexto: _c, compacto: compacto),
        const SizedBox(height: 16),
        if (restricao != null) ...[
          SivAvisoAtencao(
            restricao.isEmpty
                ? 'As promoções aplicadas não têm forma de pagamento em comum.'
                : 'Promoção aplicada restringe as formas de pagamento aceitas.',
          ),
          const SizedBox(height: 8),
        ],
        SivCard(
          child: widget.formaPagamentoGrade(
            FormaPagamentoGradeData(
              selecionada: ativa.formaDePagamento,
              tipoOperacao: _tipoOperacao,
              idsPermitidos: restricao,
              saldoCliente: saldo,
              foco: _focoGrade,
              onEscolhida: (forma) => _escolherForma(state, forma),
            ),
          ),
        ),
        const SizedBox(height: 16),
        for (var i = 0; i < state.linhas.length; i++)
          _LinhaPagamento(
            key: ValueKey(state.linhas[i].id),
            indice: i + 1,
            linha: state.linhas[i],
            ativa: state.linhas[i].id == ativa.id,
            foco: state.linhas[i].id == ativa.id ? _focoValor : null,
            podeRemover: state.linhas.length > 1,
            aviso: state.linhas[i].id == ativa.id && trocoSemDinheiro
                ? 'Só dinheiro gera troco. Ajuste o valor desta linha.'
                : null,
            onTap: () => setState(() => _linhaAtivaId = state.linhas[i].id),
          ),
        Text('F2 alterna valor e formas · F4 desconto · F9 confirma · Esc volta',
            style: context.sivTextos.apoio),
        if (_temNota) ...[
          const SizedBox(height: 16),
          if (!compacto)
            SivCard(child: _NotaBloco(state: state, recursos: _c.recursos)),
        ],
        const SizedBox(height: 4),
        if (state.linhas.isNotEmpty && compacto) Text('', style: textos.apoio),
      ],
    );
  }
}

class _Cabecalho extends StatelessWidget {
  final PagamentoContexto contexto;
  final VoidCallback onVoltar;

  const _Cabecalho({required this.contexto, required this.onVoltar});

  @override
  Widget build(BuildContext context) {
    final cores = context.sivColors;
    final textos = context.sivTextos;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: cores.superficie,
        border: Border(bottom: BorderSide(color: cores.hairline)),
      ),
      child: Row(
        children: [
          TextButton.icon(
            onPressed: onVoltar,
            icon: const Icon(Icons.arrow_back, size: 18),
            label: Text('${contexto.rotuloVoltar}  ESC'),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              contexto.titulo.toUpperCase(),
              overflow: TextOverflow.ellipsis,
              style: textos.secao,
            ),
          ),
          if (contexto.subtitulo != null)
            Flexible(
              child: Text(
                contexto.subtitulo!,
                overflow: TextOverflow.ellipsis,
                style: textos.apoio,
              ),
            ),
        ],
      ),
    );
  }
}

/// A PAGAR · RECEBIDO · FALTA RECEBER / TROCO EM DINHEIRO (+ ADIANTADO).
class _Faixa extends StatelessWidget {
  final PagamentosRealizadosState state;
  final PagamentoContexto contexto;
  final bool compacto;

  const _Faixa({
    required this.state,
    required this.contexto,
    required this.compacto,
  });

  @override
  Widget build(BuildContext context) {
    final cores = context.sivColors;
    final troco = state.valorTroco > 0.004;
    final adiantado = contexto.abatimentoTotal;

    final celulas = <Widget>[
      if (!compacto && adiantado > 0)
        _Celula('ADIANTADO', '−${_num(adiantado)}'),
      _Celula('A PAGAR', _num(state.valorTotalAPagar)),
      if (!compacto) _Celula('RECEBIDO', _num(state.valorTotalBruto)),
      _Celula(
        troco ? 'TROCO EM DINHEIRO' : 'FALTA RECEBER',
        troco
            ? pagamentoMoeda(state.valorTroco)
            : pagamentoMoeda(state.valorRestante),
        escura: troco || !compacto,
      ),
    ];

    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            color: cores.superficie,
            border: Border.all(color: cores.hairline),
          ),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [for (final c in celulas) Expanded(child: c)],
            ),
          ),
        ),
        ...sivCantosBlueprint(cores.aco),
      ],
    );
  }

  static String _num(double v) => v.toStringAsFixed(2).replaceAll('.', ',');
}

class _Celula extends StatelessWidget {
  final String rotulo;
  final String valor;
  final bool escura;

  const _Celula(this.rotulo, this.valor, {this.escura = false});

  @override
  Widget build(BuildContext context) {
    final cores = context.sivColors;
    final textos = context.sivTextos;
    final cor = escura ? cores.textoSobreEscuroTitulo : cores.textoPrincipal;

    return Container(
      color: escura ? cores.acoEscuro : null,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            rotulo,
            style: textos.rotulo.copyWith(
              color: escura ? cores.textoSobreEscuroApoio : null,
            ),
          ),
          const SizedBox(height: 4),
          Text(valor, style: textos.valor.copyWith(fontSize: 24, color: cor)),
        ],
      ),
    );
  }
}

class _LinhaPagamento extends StatefulWidget {
  final int indice;
  final PagamentoRealizadoLinha linha;
  final bool ativa;
  final FocusNode? foco;
  final bool podeRemover;
  final String? aviso;
  final VoidCallback onTap;

  const _LinhaPagamento({
    super.key,
    required this.indice,
    required this.linha,
    required this.ativa,
    required this.foco,
    required this.podeRemover,
    required this.aviso,
    required this.onTap,
  });

  @override
  State<_LinhaPagamento> createState() => _LinhaPagamentoState();
}

class _LinhaPagamentoState extends State<_LinhaPagamento> {
  late final _controller = TextEditingController(text: widget.linha.valorTexto);

  @override
  void didUpdateWidget(covariant _LinhaPagamento old) {
    super.didUpdateWidget(old);
    if (widget.linha.valorTexto != _controller.text) {
      _controller.text = widget.linha.valorTexto;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cores = context.sivColors;
    final textos = context.sivTextos;
    final bloc = context.read<PagamentosRealizadosBloc>();
    final forma = widget.linha.formaDePagamento;

    return InkWell(
      onTap: widget.onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: cores.superficie,
          border: Border.all(
            color: widget.ativa ? cores.aco : cores.hairline,
            width: widget.ativa ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Text(widget.indice.toString().padLeft(2, '0'),
                    style: textos.codigo),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    forma?.nome ?? 'Escolha a forma acima',
                    overflow: TextOverflow.ellipsis,
                    style: forma == null ? textos.apoio : textos.corpo,
                  ),
                ),
                SizedBox(
                  width: 130,
                  child: TextField(
                    controller: _controller,
                    focusNode: widget.foco,
                    textAlign: TextAlign.end,
                    inputFormatters: [pagamentoDecimalFormatter],
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      isDense: true,
                      hintText: '0,00',
                    ),
                    onChanged: (v) => bloc.add(
                      PagamentosRealizadosValorAlterado(
                        linhaId: widget.linha.id,
                        valorTexto: v,
                      ),
                    ),
                  ),
                ),
                if (widget.podeRemover)
                  IconButton(
                    tooltip: 'Remover forma de pagamento',
                    icon: const Icon(Icons.delete_outline, size: 20),
                    onPressed: () => bloc.add(
                      PagamentosRealizadosLinhaRemovida(
                          linhaId: widget.linha.id),
                    ),
                  ),
              ],
            ),
            if (widget.aviso != null) ...[
              const SizedBox(height: 6),
              SivAvisoAtencao(widget.aviso!),
            ],
          ],
        ),
      ),
    );
  }
}

class _NotaBloco extends StatefulWidget {
  final PagamentosRealizadosState state;
  final PagamentoRecursos recursos;

  const _NotaBloco({required this.state, required this.recursos});

  @override
  State<_NotaBloco> createState() => _NotaBlocoState();
}

class _NotaBlocoState extends State<_NotaBloco> {
  late final _cpf = TextEditingController(text: widget.state.cpfNaNota);
  late final _email = TextEditingController(text: widget.state.emailNota);

  @override
  void didUpdateWidget(covariant _NotaBloco old) {
    super.didUpdateWidget(old);
    if (widget.state.cpfNaNota != _cpf.text &&
        widget.state.cpfNaNota != old.state.cpfNaNota) {
      _cpf.text = widget.state.cpfNaNota;
    }
    if (widget.state.emailNota != _email.text &&
        widget.state.emailNota != old.state.emailNota) {
      _email.text = widget.state.emailNota;
    }
  }

  @override
  void dispose() {
    _cpf.dispose();
    _email.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textos = context.sivTextos;
    final bloc = context.read<PagamentosRealizadosBloc>();
    final s = widget.state;
    final r = widget.recursos;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('NOTA FISCAL', style: textos.rotulo),
        if (r.cpfNota) ...[
          _Marca(
            valor: !s.clienteGenerico && s.incluirCpfNaNota,
            rotulo: 'Incluir CPF do cliente na nota fiscal',
            apoio: s.clienteGenerico
                ? 'Não disponível para cliente não cadastrado.'
                : null,
            onChanged: s.clienteGenerico
                ? null
                : (v) => bloc.add(
                      PagamentosRealizadosIncluirCpfAlterado(
                        incluirCpfNaNota: v,
                      ),
                    ),
          ),
          if (!s.clienteGenerico && s.incluirCpfNaNota)
            CPFInput(
              controller: _cpf,
              obrigatorio: false,
              onChanged: (v) =>
                  bloc.add(PagamentosRealizadosCpfAlterado(cpfNaNota: v)),
            ),
        ],
        if (r.emailNota && s.permiteNotaFiscalEmail) ...[
          _Marca(
            valor: s.enviarNotaPorEmail,
            rotulo: 'Enviar nota fiscal por e-mail',
            onChanged: (v) => bloc.add(
              PagamentosRealizadosEnviarNotaPorEmailAlterado(
                enviarNotaPorEmail: v,
              ),
            ),
          ),
          if (s.exigeEmailNota)
            TextField(
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                isDense: true,
                hintText: 'E-mail do cliente',
              ),
              onChanged: (v) =>
                  bloc.add(PagamentosRealizadosEmailNotaAlterado(emailNota: v)),
            ),
        ],
        if (r.pontuarFidelidade)
          _Marca(
            valor: s.pontuarFidelidade,
            rotulo: 'Pontuar fidelidade',
            apoio: s.clienteElegivelFidelidade
                ? null
                : s.carregandoElegibilidadeFidelidade
                    ? 'Consultando elegibilidade do cliente...'
                    : s.erroElegibilidadeFidelidade
                        ? 'Erro ao consultar elegibilidade -- tente novamente.'
                        : 'Cliente sem cadastro no portal de pontos.',
            onChanged: s.clienteElegivelFidelidade
                ? (v) => bloc.add(
                      PagamentosRealizadosPontuarFidelidadeAlterado(
                        pontuarFidelidade: v,
                      ),
                    )
                : null,
          ),
      ],
    );
  }
}

class _Marca extends StatelessWidget {
  final bool valor;
  final String rotulo;
  final String? apoio;
  final ValueChanged<bool>? onChanged;

  const _Marca({
    required this.valor,
    required this.rotulo,
    this.apoio,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final textos = context.sivTextos;
    return InkWell(
      onTap: onChanged == null ? null : () => onChanged!(!valor),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Checkbox(
              value: valor,
              onChanged:
                  onChanged == null ? null : (v) => onChanged!(v ?? false),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(rotulo, style: textos.corpo),
                  if (apoio != null) Text(apoio!, style: textos.apoio),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Rodape extends StatelessWidget {
  final PagamentoContexto contexto;
  final String rotulo;
  final PagamentosRealizadosState state;
  final bool ativaTemForma;
  final VoidCallback onDividir;
  final VoidCallback onConfirmar;

  const _Rodape({
    required this.contexto,
    required this.rotulo,
    required this.state,
    required this.ativaTemForma,
    required this.onDividir,
    required this.onConfirmar,
  });

  @override
  Widget build(BuildContext context) {
    final cores = context.sivColors;
    final textos = context.sivTextos;
    final mobile = MediaQuery.sizeOf(context).width < 900;

    final mensagem = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Erro aparece uma vez, junto do botão que o causou.
        if (state.erro != null)
          Text(state.erro!, style: textos.apoio.copyWith(color: cores.vinho)),
        if (contexto.avisoConfirmar != null)
          Text(contexto.avisoConfirmar!, style: textos.apoio),
      ],
    );
    final dividir = TextButton(
      // A forma escolhida já vem com o valor que falta, então o restante é 0
      // aqui; a divisão é reduzir o valor desta linha e escolher a outra forma.
      onPressed: ativaTemForma ? onDividir : null,
      child: const Text('+ Dividir em outra forma'),
    );
    final primario = SizedBox(
      height: 48,
      child: FilledButton(
        onPressed: onConfirmar,
        child: Text('$rotulo · F9'),
      ),
    );

    return Container(
      padding: EdgeInsets.fromLTRB(16, 10, 16, mobile ? 22 : 10),
      decoration: BoxDecoration(
        color: cores.superficie,
        border: Border(top: BorderSide(color: cores.hairline)),
      ),
      child: mobile
          ? Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                mensagem,
                dividir,
                SizedBox(height: 52, child: primario)
              ],
            )
          : Row(
              children: [
                Expanded(child: mensagem),
                dividir,
                const SizedBox(width: 12),
                primario,
              ],
            ),
    );
  }
}
