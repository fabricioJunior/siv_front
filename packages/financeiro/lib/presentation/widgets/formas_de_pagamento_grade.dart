import 'package:core/injecoes.dart';
import 'package:core/seletores.dart';
import 'package:core/tema.dart';
import 'package:financeiro/domain/models/forma_de_pagamento.dart';
import 'package:financeiro/use_cases.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class _TipoGrade {
  final String tecla;
  final String rotulo;
  final List<String> tipos;

  const _TipoGrade(this.tecla, this.rotulo, this.tipos);
}

const _tiposDaGrade = [
  _TipoGrade('D', 'Dinheiro', ['Dinheiro']),
  _TipoGrade('P', 'Pix', ['Pix']),
  _TipoGrade('C', 'Cartão crédito', [TiposFormaPagamento.cartaoCredito]),
  _TipoGrade('B', 'Cartão débito', [TiposFormaPagamento.cartaoDebito]),
  _TipoGrade('F', 'Fatura', ['Fatura']),
  _TipoGrade('S', 'Saldo do cliente', ['Crédito de devolução', 'Adiantamento']),
  _TipoGrade('O', 'Outros', ['Cheque', 'Voucher', 'TED/DOC']),
];

/// Seletor tipo → forma (2b): linha 1 com tipos fixos (tecla = letra), linha 2
/// com as formas cadastradas do tipo, ordenadas por uso neste terminal.
/// Troco nunca é escolhível. Tipo com 1 forma só pula a linha 2.
class FormasDePagamentoGrade extends StatefulWidget {
  final FormaPagamentoGradeData data;

  /// Injetáveis para teste; por padrão usam o use case e o contador local.
  final Future<List<FormaDePagamento>> Function()? carregarFormas;
  final Future<Map<int, int>> Function()? carregarUso;

  const FormasDePagamentoGrade({
    super.key,
    required this.data,
    this.carregarFormas,
    this.carregarUso,
  });

  @override
  State<FormasDePagamentoGrade> createState() => _FormasDePagamentoGradeState();
}

class _FormasDePagamentoGradeState extends State<FormasDePagamentoGrade> {
  List<FormaDePagamento>? _formas;
  Map<int, int> _uso = const {};
  _TipoGrade? _tipo;
  int _destaque = 0;
  String _filtro = '';
  bool _falhou = false;
  final _focoFiltro = FocusNode();

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  @override
  void dispose() {
    _focoFiltro.dispose();
    super.dispose();
  }

  Future<void> _carregar() async {
    try {
      final formas = await (widget.carregarFormas ??
          () => sl<RecuperarFormasDePagamento>().call())();
      final uso = await (widget.carregarUso ?? UsoFormasPagamento.ler)();
      if (!mounted) return;
      setState(() {
        _formas = formas;
        _uso = uso;
        _tipo = _tipoDe(widget.data.selecionada?.data['tipo']);
      });
      // O autofocus não vale com o foco já em outro nó (a etapa que a hospeda).
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) widget.data.foco?.requestFocus();
      });
    } catch (_) {
      if (mounted) setState(() => _falhou = true);
    }
  }

  _TipoGrade? _tipoDe(Object? tipo) {
    for (final t in _tiposDaGrade) {
      if (t.tipos.contains(tipo)) return t;
    }
    return null;
  }

  bool _doTipo(FormaDePagamento f, _TipoGrade t) =>
      !f.inativa &&
      t.tipos.contains(f.tipo) &&
      (widget.data.tipoOperacao == null ||
          f.tipoOperacao.name == widget.data.tipoOperacao);

  bool _permitida(FormaDePagamento f) =>
      widget.data.idsPermitidos == null ||
      widget.data.idsPermitidos!.contains(f.id);

  List<FormaDePagamento> _formasDo(_TipoGrade t) =>
      (_formas ?? const []).where((f) => _doTipo(f, t)).toList()
        ..sort((a, b) {
          final porUso = (_uso[b.id] ?? 0).compareTo(_uso[a.id] ?? 0);
          return porUso != 0 ? porUso : a.descricao.compareTo(b.descricao);
        });

  List<_TipoGrade> get _tiposVisiveis => [
        for (final t in _tiposDaGrade)
          if (_formasDo(t).isNotEmpty &&
              (t.tecla != 'S' || widget.data.saldoCliente > 0))
            t,
      ];

  List<FormaDePagamento> get _formasListadas {
    final busca = _filtro.trim().toLowerCase();
    return _formasDo(_tipo!)
        .where(
            (f) => busca.isEmpty || f.descricao.toLowerCase().contains(busca))
        .toList();
  }

  void _escolherTipo(_TipoGrade t) {
    final formas = _formasDo(t).where(_permitida).toList();
    if (formas.isEmpty) return;
    setState(() {
      _tipo = t;
      _filtro = '';
      _destaque = 0;
    });
    if (_formasDo(t).length == 1) {
      _escolherForma(formas.first);
    } else {
      // Várias formas: o foco vai para a escolha (digitar filtra, ← → navegam).
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _focoFiltro.requestFocus();
      });
    }
  }

  // Com o foco no filtro as setas navegam as formas (e não o cursor).
  KeyEventResult _teclaFiltro(FocusNode _, KeyEvent e) {
    final lista = _tipo == null ? const <FormaDePagamento>[] : _formasListadas;
    if (e is! KeyDownEvent || lista.isEmpty) return KeyEventResult.ignored;
    if (e.logicalKey == LogicalKeyboardKey.enter && _destaque < lista.length) {
      _escolherForma(lista[_destaque]);
      return KeyEventResult.handled;
    }
    final passo = e.logicalKey == LogicalKeyboardKey.arrowRight
        ? 1
        : e.logicalKey == LogicalKeyboardKey.arrowLeft
            ? -1
            : 0;
    if (passo == 0) return KeyEventResult.ignored;
    setState(
        () => _destaque = (_destaque + passo + lista.length) % lista.length);
    return KeyEventResult.handled;
  }

  void _escolherForma(FormaDePagamento f) {
    if (!_permitida(f)) return;
    widget.data.onEscolhida(
      SelectData(
        id: f.id ?? 0,
        nome: f.descricao,
        data: {
          'id': f.id,
          'descricao': f.descricao,
          'parcelas': f.parcelas,
          'tipo': f.tipo,
          'inicio': f.inicio,
          'inativa': f.inativa,
          'tipoOperacao': f.tipoOperacao.name,
        },
      ),
    );
  }

  bool get _digitando =>
      FocusManager.instance.primaryFocus?.context
          ?.findAncestorWidgetOfExactType<EditableText>() !=
      null;

  KeyEventResult _tecla(FocusNode _, KeyEvent e) {
    if (e is! KeyDownEvent || _digitando || _formas == null) {
      return KeyEventResult.ignored;
    }
    final key = e.logicalKey;
    final tipo = _tipo;
    if (tipo != null) {
      final lista = _formasListadas;
      if (key == LogicalKeyboardKey.arrowRight && lista.isNotEmpty) {
        setState(() => _destaque = (_destaque + 1) % lista.length);
        return KeyEventResult.handled;
      }
      if (key == LogicalKeyboardKey.arrowLeft && lista.isNotEmpty) {
        setState(
            () => _destaque = (_destaque - 1 + lista.length) % lista.length);
        return KeyEventResult.handled;
      }
      if (key == LogicalKeyboardKey.enter && _destaque < lista.length) {
        _escolherForma(lista[_destaque]);
        return KeyEventResult.handled;
      }
    }
    final letra = key.keyLabel.toUpperCase();
    for (final t in _tiposVisiveis) {
      if (t.tecla == letra) {
        _escolherTipo(t);
        return KeyEventResult.handled;
      }
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final cores = context.sivColors;
    final textos = context.sivTextos;

    if (_falhou) {
      return Text(
        'Não foi possível carregar as formas de pagamento.',
        style: textos.apoio.copyWith(color: cores.vinho),
      );
    }
    if (_formas == null) {
      return const Center(child: CircularProgressIndicator.adaptive());
    }

    final tipos = _tiposVisiveis;
    if (tipos.isEmpty) {
      return Text('Nenhuma forma de pagamento disponível.',
          style: textos.apoio);
    }

    final selecionadaId = widget.data.selecionada?.id;
    final tipo = _tipo != null && tipos.contains(_tipo) ? _tipo : null;
    final listadas =
        tipo == null ? const <FormaDePagamento>[] : _formasListadas;

    return Focus(
      focusNode: widget.data.foco,
      autofocus: true,
      onKeyEvent: _tecla,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('TIPO · TECLA = LETRA', style: textos.rotulo),
          const SizedBox(height: 8),
          LayoutBuilder(
            builder: (context, c) {
              final largura = c.maxWidth < 600 ? (c.maxWidth - 16) / 3 : 150.0;
              return Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final t in tipos)
                    SizedBox(
                      width: largura,
                      child: _Botao(
                        tecla: t.tecla,
                        rotulo: t.rotulo,
                        altura: 60,
                        detalhe: _formasDo(t).length > 1
                            ? '${_formasDo(t).length} formas'
                            : null,
                        selecionado: t == tipo,
                        bloqueado: !_formasDo(t).any(_permitida),
                        onTap: () => _escolherTipo(t),
                      ),
                    ),
                ],
              );
            },
          ),
          if (tipo != null && _formasDo(tipo).length > 1) ...[
            const SizedBox(height: 16),
            Text(
              'FORMA — ${tipo.rotulo.toUpperCase()} · ← → OU DIGITE',
              style: textos.rotulo,
            ),
            const SizedBox(height: 8),
            Focus(
              onKeyEvent: _teclaFiltro,
              child: TextField(
                focusNode: _focoFiltro,
                decoration: InputDecoration(
                  isDense: true,
                  hintText: 'Filtrar formas de ${tipo.rotulo.toLowerCase()}…',
                ),
                onChanged: (v) => setState(() {
                  _filtro = v;
                  _destaque = 0;
                }),
                onSubmitted: (_) {
                  if (_destaque < listadas.length) {
                    _escolherForma(listadas[_destaque]);
                  }
                },
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (var i = 0; i < listadas.length; i++)
                  _Botao(
                    rotulo: listadas[i].descricao,
                    selecionado: listadas[i].id == selecionadaId,
                    destacado: i == _destaque,
                    bloqueado: !_permitida(listadas[i]),
                    onTap: () => _escolherForma(listadas[i]),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _Botao extends StatelessWidget {
  final String? tecla;
  final String rotulo;
  final String? detalhe;
  final bool selecionado;
  final bool destacado;
  final bool bloqueado;
  final double? altura;
  final VoidCallback onTap;

  const _Botao({
    this.tecla,
    required this.rotulo,
    this.detalhe,
    this.selecionado = false,
    this.destacado = false,
    this.bloqueado = false,
    this.altura,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cores = context.sivColors;
    final textos = context.sivTextos;
    final corTexto = selecionado
        ? cores.textoSobreEscuroTitulo
        : bloqueado
            ? cores.textoDesabilitado
            : cores.textoPrincipal;

    return Semantics(
      button: true,
      enabled: !bloqueado,
      child: InkWell(
        onTap: bloqueado ? null : onTap,
        borderRadius: BorderRadius.circular(SivDimensoes.raio),
        child: CustomPaint(
          painter: bloqueado ? _BordaTracejada(cores.hairline) : null,
          child: Container(
            // Altura fixa nos tipos: com/sem "N formas" ficam do mesmo tamanho.
            constraints: altura == null
                ? const BoxConstraints(minHeight: 48)
                : BoxConstraints.tightFor(height: altura),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: bloqueado
                ? null
                : BoxDecoration(
                    color: selecionado ? cores.acoEscuro : cores.superficie,
                    borderRadius: BorderRadius.circular(SivDimensoes.raio),
                    border: Border.all(
                      color: destacado ? cores.aco : cores.hairline,
                      width: destacado ? 2 : 1,
                    ),
                  ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (tecla != null) ...[
                  Text(tecla!, style: textos.codigo.copyWith(color: corTexto)),
                  const SizedBox(width: 8),
                ],
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        rotulo,
                        overflow: TextOverflow.ellipsis,
                        style: textos.corpo.copyWith(color: corTexto),
                      ),
                      if (detalhe != null)
                        Text(
                          detalhe!,
                          style: textos.apoio.copyWith(
                            fontSize: 11,
                            color: selecionado
                                ? cores.textoSobreEscuroApoio
                                : cores.textoApoio,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BordaTracejada extends CustomPainter {
  final Color cor;

  _BordaTracejada(this.cor);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = cor
      ..style = PaintingStyle.stroke;
    const traco = 4.0, vao = 3.0;
    void linha(Offset a, Offset b) {
      final total = (b - a).distance;
      final dir = (b - a) / total;
      for (var d = 0.0; d < total; d += traco + vao) {
        canvas.drawLine(
            a + dir * d, a + dir * (d + traco).clamp(0, total), paint);
      }
    }

    linha(Offset.zero, Offset(size.width, 0));
    linha(Offset(size.width, 0), Offset(size.width, size.height));
    linha(Offset(size.width, size.height), Offset(0, size.height));
    linha(Offset(0, size.height), Offset.zero);
  }

  @override
  bool shouldRepaint(_BordaTracejada old) => old.cor != cor;
}
