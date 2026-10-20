import 'package:core/bloc.dart';
import 'package:core/presentation.dart';
import 'package:core/tema.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pessoas/models.dart';

import '../bloc/pontos_bloc/pontos_bloc.dart';
import 'cliente_aba_comum.dart';
import 'cliente_abas.dart';

String _pts(num v) => v.abs().toStringAsFixed(0).replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (_) => '.',
    );

/// Valor com sinal do ponto (débito negativo), sem depender de cor.
double _assinado(Ponto p) => switch (p.tipo) {
      TipoDePonto.debito => -p.valor.abs(),
      TipoDePonto.credito => p.valor.abs(),
      null => p.valor,
    };

/// Aba Pontos (3c). Exige PontosBloc acima na árvore.
class ClientePontosAba extends StatefulWidget {
  final int idPessoa;

  const ClientePontosAba({super.key, required this.idPessoa});

  @override
  State<ClientePontosAba> createState() => _ClientePontosAbaState();
}

class _ClientePontosAbaState extends State<ClientePontosAba> {
  late final ClienteAcoes _acoes;

  @override
  void initState() {
    super.initState();
    _acoes = context
        .getInheritedWidgetOfExactType<ClienteAcoesEscopo>()!
        .acoes
      ..definir(ClienteAcao.resgatarPontos, _resgatar)
      ..definir(ClienteAcao.lancarPontos, _lancar);
  }

  @override
  void dispose() {
    _acoes
      ..definir(ClienteAcao.resgatarPontos, null)
      ..definir(ClienteAcao.lancarPontos, null);
    super.dispose();
  }

  bool get _ocupado {
    final s = context.read<PontosBloc>().state;
    return s is PontosCarregarEmProgresso ||
        s is PontosCriarPontoEmProgresso ||
        s is PontosResgatarEmProgresso;
  }

  Future<void> _lancar() async {
    if (_ocupado) return;
    final bloc = context.read<PontosBloc>();
    final r = await _PontosModal.show(context, resgate: false);
    if (r != null) {
      bloc.add(PontosCriouNovoPonto(
          valor: r.valor.toDouble(), descricao: r.descricao));
    }
  }

  Future<void> _resgatar() async {
    if (_ocupado) return;
    final bloc = context.read<PontosBloc>();
    final r = await _PontosModal.show(context, resgate: true);
    if (r != null) {
      bloc.add(PontosResgatou(valor: r.valor, descricao: r.descricao));
    }
  }

  Future<void> _cancelar(Ponto p) async {
    final bloc = context.read<PontosBloc>();
    final sinal = _assinado(p) < 0 ? '−' : '+';
    final ok = await confirmarCliente(
      context,
      titulo: 'Cancelar lançamento',
      texto: 'O lançamento de $sinal ${_pts(p.valor)} pts '
          '("${p.descricao}") sai do saldo e continua na lista, riscado.',
      confirmar: 'Cancelar lançamento',
    );
    if (ok) bloc.add(PontosCancelouPonto(idPonto: p.id));
  }

  @override
  Widget build(BuildContext context) {
    final mobile =
        MediaQuery.sizeOf(context).width < SivDimensoes.breakpointMenuDrawer;
    return BlocConsumer<PontosBloc, PontosState>(
      // O bloc remove o cancelado da lista local; recarrega para mostrá-lo riscado.
      listenWhen: (_, s) => s is PontosExcluirPontoSucesso,
      listener: (context, s) => context
          .read<PontosBloc>()
          .add(PontosIniciou(idPessoa: widget.idPessoa)),
      builder: (context, state) {
        if (state is PontosCarregarFalha) {
          return const Center(child: Text('Falha ao carregar pontos.'));
        }
        if (state is PontosCarregarEmProgresso ||
            state is PontosCriarPontoEmProgresso) {
          return const Center(child: CircularProgressIndicator.adaptive());
        }
        final pontos = [...?state.pontos]..sort((a, b) =>
            (b.dtCriacao ?? DateTime(0)).compareTo(a.dtCriacao ?? DateTime(0)));

        return SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal:
                mobile ? 16 : SivDimensoes.paddingBarraTituloHorizontal,
            vertical: mobile ? 16 : 24,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _Resumo(pontos),
              const SizedBox(height: 16),
              if (pontos.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Center(
                    child: Text('Nenhum ponto lançado até o momento.',
                        style: context.sivTextos.apoio
                            .copyWith(color: context.sivColors.textoApoio)),
                  ),
                )
              else
                _Tabela(pontos, mobile: mobile, aoCancelar: _cancelar),
            ],
          ),
        );
      },
    );
  }
}

class _Resumo extends StatelessWidget {
  final List<Ponto> pontos;

  const _Resumo(this.pontos);

  @override
  Widget build(BuildContext context) {
    final cores = context.sivColors;
    final textos = context.sivTextos;
    final desde = DateTime.now().subtract(const Duration(days: 365));
    final validos = pontos.where((p) => !p.cancelado);
    final saldo = validos.fold<double>(0, (t, p) => t + _assinado(p));
    final recentes = validos.where(
      (p) => p.dtCriacao == null || p.dtCriacao!.isAfter(desde),
    );
    double soma(bool debito) => recentes
        .where((p) => (_assinado(p) < 0) == debito)
        .fold<double>(0, (t, p) => t + p.valor.abs());

    Widget celula(String rotulo, String valor, double tamanho, int flex) =>
        Expanded(
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
                Text(valor, style: textos.valor.copyWith(fontSize: tamanho)),
              ],
            ),
          ),
        );

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
            celula('SALDO DE PONTOS', '${saldo < 0 ? '− ' : ''}${_pts(saldo)} pts',
                30, 13),
            const SizedBox(width: 1),
            celula('GANHOS · 12 MESES', '+ ${_pts(soma(false))}', 22, 10),
            const SizedBox(width: 1),
            celula('RESGATADOS · 12 MESES', '− ${_pts(soma(true))}', 22, 10),
          ],
        ),
      ),
    );
  }
}

class _Tabela extends StatelessWidget {
  final List<Ponto> pontos;
  final bool mobile;
  final void Function(Ponto) aoCancelar;

  const _Tabela(this.pontos, {required this.mobile, required this.aoCancelar});

  @override
  Widget build(BuildContext context) {
    final cores = context.sivColors;
    final textos = context.sivTextos;

    return SivTabela(
      colunas: [
        const SivTabelaColuna(titulo: 'DATA', flex: 2),
        const SivTabelaColuna(titulo: 'MOVIMENTO', flex: 2),
        const SivTabelaColuna(titulo: 'DESCRIÇÃO', flex: 4),
        if (!mobile) const SivTabelaColuna(titulo: 'TRANSAÇÃO', flex: 2),
        const SivTabelaColuna.numerica(titulo: 'PONTOS', flex: 2),
        const SivTabelaColuna(titulo: '', flex: 1),
      ],
      quantidadeLinhas: pontos.length,
      linhaBuilder: (context, i) {
        final p = pontos[i];
        final riscado = p.cancelado
            ? const TextStyle(decoration: TextDecoration.lineThrough)
            : null;
        final negativo = _assinado(p) < 0;
        final celulas = <Widget>[
          Text(formatarData(p.dtCriacao),
              style: textos.apoio.merge(riscado)),
          p.cancelado
              ? ClienteTag('Cancelado',
                  cor: cores.vinho, fundo: cores.vinho.withValues(alpha: 0.1))
              : ClienteTag(negativo
                  ? 'Resgate'
                  : p.transacaoId != null
                      ? 'Compra'
                      : 'Manual'),
          Text(p.descricao, style: textos.corpo.merge(riscado)),
          if (!mobile)
            Text(p.transacaoId?.toString() ?? '—',
                style: textos.codigo.copyWith(color: cores.textoApoio)),
          Text(
            '${negativo ? '−' : '+'} ${_pts(p.valor)}',
            style: textos.valor
                .copyWith(fontSize: 15)
                .merge(riscado),
          ),
          p.cancelado
              ? const SizedBox.shrink()
              : Align(
                  alignment: Alignment.centerRight,
                  child: ClienteMenuMais({
                    'Cancelar lançamento…': () => aoCancelar(p),
                  }),
                ),
        ];
        return [
          for (final c in celulas)
            p.cancelado ? Opacity(opacity: 0.55, child: c) : c,
        ];
      },
    );
  }
}

typedef _Lancamento = ({int valor, String descricao});

/// Lançar/resgatar pontos, no visual de 2b (SivModal).
class _PontosModal extends StatefulWidget {
  final bool resgate;
  final String nome;
  final double saldo;

  const _PontosModal(
      {required this.resgate, required this.nome, required this.saldo});

  static Future<_Lancamento?> show(BuildContext context,
      {required bool resgate}) {
    final s = context.read<PontosBloc>().state;
    final saldo = (s.pontos ?? const <Ponto>[])
        .where((p) => !p.cancelado)
        .fold<double>(0, (t, p) => t + _assinado(p));
    return showDialog<_Lancamento>(
      context: context,
      barrierColor: context.sivColors.acoEscuro.withValues(alpha: 0.35),
      builder: (_) => _PontosModal(
          resgate: resgate, nome: s.pessoa?.nome ?? '', saldo: saldo),
    );
  }

  @override
  State<_PontosModal> createState() => _PontosModalState();
}

class _PontosModalState extends State<_PontosModal> {
  final _formKey = GlobalKey<FormState>();
  final _valor = TextEditingController();
  final _descricao = TextEditingController();

  @override
  void dispose() {
    _valor.dispose();
    _descricao.dispose();
    super.dispose();
  }

  void _confirmar() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    Navigator.of(context).pop((
      valor: int.parse(_valor.text),
      descricao: _descricao.text.trim(),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final cores = context.sivColors;
    final textos = context.sivTextos;
    final resgate = widget.resgate;
    final n = int.tryParse(_valor.text) ?? 0;
    final depois = widget.saldo + (resgate ? -n : n);

    return SivModal(
      titulo: resgate ? 'Resgatar pontos' : 'Lançar pontos',
      larguraMaxima: 520,
      corpo: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.nome.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(
                  '${widget.nome} · saldo atual ${_pts(widget.saldo)} pts',
                  style: textos.apoio.copyWith(color: cores.textoApoio),
                ),
              ),
            TextFormField(
              controller: _valor,
              maxLength: 2,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(labelText: 'Quantidade'),
              validator: (v) => (v == null || v.isEmpty)
                  ? 'Informe a quantidade de pontos'
                  : null,
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _descricao,
              maxLength: 100,
              decoration: const InputDecoration(labelText: 'Motivo'),
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? 'Informe o motivo ${resgate ? 'do resgate' : 'dos pontos'}'
                  : null,
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: cores.selecaoFundo,
                borderRadius: BorderRadius.circular(SivDimensoes.raio),
              ),
              child: Row(
                children: [
                  Expanded(child: Text('Saldo depois', style: textos.apoio)),
                  Text('${_pts(widget.saldo)} → ',
                      style:
                          textos.apoio.copyWith(color: cores.textoApoio)),
                  Text('${depois < 0 ? '− ' : ''}${_pts(depois)} pts',
                      style: textos.valor.copyWith(fontSize: 17)),
                ],
              ),
            ),
          ],
        ),
      ),
      acoes: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _confirmar,
          child: Text(n > 0
              ? '${resgate ? 'Resgatar' : 'Lançar'} $n pts'
              : (resgate ? 'Resgatar pontos' : 'Lançar pontos')),
        ),
      ],
    );
  }
}
