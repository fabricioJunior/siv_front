import 'dart:async';

import 'package:comercial/models.dart';
import 'package:core/tema.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

typedef CriarChaveMcpCallback = Future<CriarChaveMcpResultado> Function(
  String nome,
  List<String> escopos,
  DateTime? expiraEm,
);

/// Abre [builder] como diálogo (desktop) ou tela cheia (mobile).
Future<T?> abrirModalChaveMcp<T>(
  BuildContext context, {
  required bool mobile,
  required WidgetBuilder builder,
  bool dispensavel = true,
}) {
  if (mobile) {
    return Navigator.of(context).push<T>(
      MaterialPageRoute(fullscreenDialog: true, builder: builder),
    );
  }
  return showDialog<T>(
    context: context,
    barrierDismissible: dispensavel,
    barrierColor: context.sivColors.acoEscuro.withValues(alpha: 0.45),
    builder: builder,
  );
}

String formatarDataChaveMcp(DateTime d) =>
    '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

class _Moldura extends StatelessWidget {
  final bool mobile;
  final double largura;
  final String? sobretitulo;
  final String titulo;
  final Widget corpo;
  final Widget rodape;
  final Widget? acaoTopo;

  const _Moldura({
    required this.mobile,
    required this.largura,
    this.sobretitulo,
    required this.titulo,
    required this.corpo,
    required this.rodape,
    this.acaoTopo,
  });

  @override
  Widget build(BuildContext context) {
    final cores = context.sivColors;
    final textos = context.sivTextos;
    final conteudo = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(mobile ? 16 : 26, mobile ? 8 : 22, mobile ? 16 : 26, 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (sobretitulo != null)
                      Text(sobretitulo!.toUpperCase(),
                          style: textos.rotulo.copyWith(color: cores.aco)),
                    Text(titulo, style: textos.secao.copyWith(fontSize: mobile ? 22 : 26)),
                  ],
                ),
              ),
              if (acaoTopo != null) acaoTopo!,
            ],
          ),
        ),
        Flexible(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: mobile ? 16 : 26),
            child: corpo,
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: mobile ? 16 : 26, vertical: 14),
          decoration: BoxDecoration(border: Border(top: BorderSide(color: cores.hairline))),
          child: rodape,
        ),
      ],
    );
    if (mobile) {
      return Scaffold(backgroundColor: cores.superficie, body: SafeArea(child: conteudo));
    }
    return Dialog(
      child: ConstrainedBox(constraints: BoxConstraints(maxWidth: largura), child: conteudo),
    );
  }
}

class BotaoCopiarChaveMcp extends StatefulWidget {
  final String texto;
  final String rotulo;
  final bool sobreEscuro;
  final VoidCallback? onCopiou;

  const BotaoCopiarChaveMcp({
    super.key,
    required this.texto,
    this.rotulo = 'Copiar',
    this.sobreEscuro = false,
    this.onCopiou,
  });

  @override
  State<BotaoCopiarChaveMcp> createState() => _BotaoCopiarChaveMcpState();
}

class _BotaoCopiarChaveMcpState extends State<BotaoCopiarChaveMcp> {
  bool _copiado = false;
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _copiar() async {
    await Clipboard.setData(ClipboardData(text: widget.texto));
    widget.onCopiou?.call();
    if (!mounted) return;
    setState(() => _copiado = true);
    _timer?.cancel();
    _timer = Timer(const Duration(seconds: 2), () {
      if (mounted) setState(() => _copiado = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final cores = context.sivColors;
    final icone = Icon(_copiado ? Icons.check : Icons.copy_outlined, size: 16);
    final rotulo = Text(_copiado ? 'Copiado' : widget.rotulo);
    if (widget.sobreEscuro) {
      return FilledButton.icon(
        onPressed: _copiar,
        style: FilledButton.styleFrom(
            backgroundColor: cores.superficie, foregroundColor: cores.acoEscuro),
        icon: icone,
        label: rotulo,
      );
    }
    return OutlinedButton.icon(onPressed: _copiar, icon: icone, label: rotulo);
  }
}

class CriarChaveMcpDialogo extends StatefulWidget {
  final bool mobile;
  final String tituloCanal;
  final CriarChaveMcpCallback onCriar;

  const CriarChaveMcpDialogo({
    super.key,
    required this.mobile,
    required this.tituloCanal,
    required this.onCriar,
  });

  @override
  State<CriarChaveMcpDialogo> createState() => _CriarChaveMcpDialogoState();
}

class _CriarChaveMcpDialogoState extends State<CriarChaveMcpDialogo> {
  final _nome = TextEditingController();
  final _escopos = <String>{};
  bool _comData = false;
  DateTime? _data;
  bool _tentou = false;
  bool _enviando = false;
  String? _erroApi;

  @override
  void dispose() {
    _nome.dispose();
    super.dispose();
  }

  bool get _erroNome => _tentou && _nome.text.trim().isEmpty;
  bool get _erroEscopo => _tentou && _escopos.isEmpty;
  bool get _erroData => _tentou && _comData && _data == null;

  Future<void> _escolherData() async {
    final hoje = DateTime.now();
    final d = await showDatePicker(
      context: context,
      initialDate: _data ?? hoje,
      firstDate: DateTime(hoje.year, hoje.month, hoje.day),
      lastDate: DateTime(hoje.year + 10),
    );
    if (d != null) setState(() => _data = d);
  }

  Future<void> _criar() async {
    setState(() {
      _tentou = true;
      _erroApi = null;
    });
    if (_erroNome || _erroEscopo || _erroData) return;
    setState(() => _enviando = true);
    final d = _comData ? _data : null;
    try {
      final resultado = await widget.onCriar(
        _nome.text.trim(),
        [for (final e in escoposMcp) if (_escopos.contains(e.id)) e.id],
        d == null ? null : DateTime(d.year, d.month, d.day, 23, 59, 59),
      );
      if (mounted) Navigator.of(context).pop(resultado);
    } catch (e) {
      if (mounted) {
        setState(() {
          _enviando = false;
          _erroApi = e is String ? e : 'Falha ao criar a chave.';
        });
      }
    }
  }

  Widget _opcao(EscopoMcp e, {Color? fundo}) {
    final textos = context.sivTextos;
    final cores = context.sivColors;
    return InkWell(
      onTap: () => setState(() => _escopos.contains(e.id) ? _escopos.remove(e.id) : _escopos.add(e.id)),
      child: Container(
        color: fundo,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Checkbox(
              value: _escopos.contains(e.id),
              onChanged: (v) => setState(() => v == true ? _escopos.add(e.id) : _escopos.remove(e.id)),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(e.rotulo, style: textos.corpo),
                    Text(e.descricao,
                        style: textos.apoio.copyWith(fontSize: 12, color: cores.textoPrincipal.withValues(alpha: 0.55))),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _grade(List<EscopoMcp> lista, int colunas, {Color? fundo}) {
    return Column(
      children: [
        for (var i = 0; i < lista.length; i += colunas)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var j = i; j < i + colunas; j++)
                Expanded(child: j < lista.length ? _opcao(lista[j], fundo: fundo) : const SizedBox()),
            ],
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final cores = context.sivColors;
    final textos = context.sivTextos;
    final m = widget.mobile;
    final todos = _escopos.length == escoposMcp.length;
    final erroStyle = textos.apoio.copyWith(color: cores.vinho, fontSize: 12.5);

    return _Moldura(
      mobile: m,
      largura: 680,
      sobretitulo: widget.tituloCanal,
      titulo: 'Criar chave do agente',
      acaoTopo: IconButton(
        tooltip: 'Fechar',
        onPressed: _enviando ? null : () => Navigator.of(context).pop(),
        icon: const Icon(Icons.close),
      ),
      corpo: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 6),
          TextField(
            controller: _nome,
            maxLength: 100,
            enabled: !_enviando,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              labelText: 'Nome',
              hintText: 'Ex.: agente CRM',
              errorText: _erroNome ? 'Informe um nome para identificar a chave.' : null,
              counterText: '${_nome.text.length}/100',
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: Text('ESCOPOS — O QUE O AGENTE PODE FAZER', style: textos.rotulo),
              ),
              TextButton(
                onPressed: _enviando
                    ? null
                    : () => setState(() => todos
                        ? _escopos.clear()
                        : _escopos.addAll(escoposMcp.map((e) => e.id))),
                child: Text(todos ? 'Limpar seleção' : 'Selecionar todos para atendimento completo'),
              ),
            ],
          ),
          Container(
            decoration: BoxDecoration(border: Border.all(color: cores.hairline)),
            child: _grade(escoposMcp.where((e) => !e.escrita).toList(), m ? 1 : 2),
          ),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              color: cores.atencaoFundo,
              border: Border.all(color: cores.atencaoBorda),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.warning_amber_rounded, size: 18, color: cores.atencao),
                      const SizedBox(width: 9),
                      Expanded(
                        child: Text.rich(
                          TextSpan(children: [
                            const TextSpan(
                              text: 'Escopos de escrita. ',
                              style: TextStyle(fontWeight: FontWeight.w700),
                            ),
                            const TextSpan(
                              text: 'Carrinho, pedido e pagamento permitem que o agente crie '
                                  'pedidos (com reserva de estoque) e cobranças.',
                            ),
                          ]),
                          style: textos.apoio.copyWith(color: cores.atencao, fontSize: 12.5),
                        ),
                      ),
                    ],
                  ),
                ),
                _grade(escoposMcp.where((e) => e.escrita).toList(), m ? 1 : 3, fundo: cores.superficie),
              ],
            ),
          ),
          if (_erroEscopo)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text('Escolha pelo menos um escopo.', style: erroStyle),
            ),
          const SizedBox(height: 16),
          Text('EXPIRA EM', style: textos.rotulo),
          const SizedBox(height: 8),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              SegmentedButton<bool>(
                showSelectedIcon: false,
                segments: const [
                  ButtonSegment(value: false, label: Text('Sem expiração')),
                  ButtonSegment(value: true, label: Text('Definir data')),
                ],
                selected: {_comData},
                onSelectionChanged: _enviando ? null : (s) => setState(() => _comData = s.first),
              ),
              if (_comData)
                OutlinedButton.icon(
                  onPressed: _enviando ? null : _escolherData,
                  icon: const Icon(Icons.event, size: 18),
                  label: Text(_data == null ? 'Escolher data' : formatarDataChaveMcp(_data!)),
                ),
            ],
          ),
          if (_erroData)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text('Escolha a data de expiração.', style: erroStyle),
            ),
          const SizedBox(height: 6),
          Text(
            'Depois da data, o agente perde o acesso e a chave aparece como Expirada.',
            style: textos.apoio.copyWith(fontSize: 12),
          ),
          if (_erroApi != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              color: cores.falhaFundo,
              child: Text(_erroApi!, style: erroStyle),
            ),
          ],
          const SizedBox(height: 16),
        ],
      ),
      rodape: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          OutlinedButton(
            onPressed: _enviando ? null : () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          const SizedBox(width: 10),
          FilledButton(
            onPressed: _enviando ? null : _criar,
            child: _enviando
                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                : const Text('CRIAR CHAVE'),
          ),
        ],
      ),
    );
  }
}

/// Única exibição da chave em claro: ela vive só no estado deste widget.
/// Sem X, Esc, fundo ou voltar -- a saída é Concluir.
class ChaveMcpExibicaoUnica extends StatefulWidget {
  final bool mobile;
  final String nome;
  final String chave;
  final String urlMcp;
  final int ecommerceId;

  const ChaveMcpExibicaoUnica({
    super.key,
    required this.mobile,
    required this.nome,
    required this.chave,
    required this.urlMcp,
    required this.ecommerceId,
  });

  @override
  State<ChaveMcpExibicaoUnica> createState() => _ChaveMcpExibicaoUnicaState();
}

class _ChaveMcpExibicaoUnicaState extends State<ChaveMcpExibicaoUnica> {
  bool _copiou = false;
  bool _guardei = false;

  @override
  Widget build(BuildContext context) {
    final cores = context.sivColors;
    final textos = context.sivTextos;
    final mono = textos.codigo.copyWith(fontSize: 12.5);
    final podeConcluir = _copiou || _guardei;
    final tudo = 'URL do MCP: ${widget.urlMcp}\n'
        'Chave: ${widget.chave}\n'
        'ID do e-commerce: ${widget.ecommerceId}';

    Widget linha(String rotulo, String valor) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: widget.mobile
              ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(rotulo, style: textos.apoio),
                  SelectableText(valor, style: mono),
                ])
              : Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  SizedBox(width: 136, child: Text(rotulo, style: textos.apoio)),
                  Expanded(child: SelectableText(valor, style: mono)),
                ]),
        );

    return PopScope(
      canPop: false,
      child: _Moldura(
        mobile: widget.mobile,
        largura: 720,
        sobretitulo: 'Chave criada · ${widget.nome}',
        titulo: 'Guarde a chave agora',
        corpo: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              color: cores.acoEscuro,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SelectableText(
                    widget.chave,
                    style: textos.codigo.copyWith(
                        fontSize: 17, color: cores.textoSobreEscuroTitulo),
                  ),
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 14,
                    runSpacing: 10,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    alignment: WrapAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.warning_amber_rounded, size: 16, color: cores.atencaoBorda),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              'Esta chave não será mostrada novamente. Guarde-a agora.',
                              style: textos.corpo.copyWith(color: cores.atencaoBorda, fontSize: 13.5),
                            ),
                          ),
                        ],
                      ),
                      BotaoCopiarChaveMcp(
                        texto: widget.chave,
                        rotulo: 'Copiar chave',
                        sobreEscuro: true,
                        onCopiou: () => setState(() => _copiou = true),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Container(
              decoration: BoxDecoration(border: Border.all(color: cores.hairline)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    color: cores.superficieRecuada,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    child: Row(
                      children: [
                        Expanded(child: Text('PARA CONFIGURAR NO CRM', style: textos.rotulo)),
                        BotaoCopiarChaveMcp(
                          texto: tudo,
                          rotulo: 'Copiar tudo',
                          onCopiou: () => setState(() => _copiou = true),
                        ),
                      ],
                    ),
                  ),
                  linha('URL do MCP', widget.urlMcp),
                  linha('Chave', widget.chave),
                  linha('ID do e-commerce', '${widget.ecommerceId}'),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text.rich(
              TextSpan(children: [
                const TextSpan(text: 'O segredo da conversa ('),
                TextSpan(text: 'MCP_CONVERSA_SECRET', style: textos.codigo.copyWith(fontSize: 12)),
                const TextSpan(text: ') é combinado à parte com o administrador.'),
              ]),
              style: textos.apoio.copyWith(fontSize: 12),
            ),
            const SizedBox(height: 14),
          ],
        ),
        rodape: Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          runSpacing: 8,
          children: [
            InkWell(
              onTap: () => setState(() => _guardei = !_guardei),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Checkbox(value: _guardei, onChanged: (v) => setState(() => _guardei = v ?? false)),
                Text('Já guardei a chave', style: textos.corpo),
              ]),
            ),
            Row(mainAxisSize: MainAxisSize.min, children: [
              if (!podeConcluir)
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: Text('Copie a chave ou confirme que guardou',
                      style: textos.apoio.copyWith(fontSize: 12)),
                ),
              FilledButton(
                onPressed: podeConcluir ? () => Navigator.of(context).pop() : null,
                child: const Text('CONCLUIR'),
              ),
            ]),
          ],
        ),
      ),
    );
  }
}

class RevogarChaveMcpDialogo extends StatefulWidget {
  final EcommerceChaveMcp chave;
  final Future<void> Function() onRevogar;

  const RevogarChaveMcpDialogo({super.key, required this.chave, required this.onRevogar});

  @override
  State<RevogarChaveMcpDialogo> createState() => _RevogarChaveMcpDialogoState();
}

class _RevogarChaveMcpDialogoState extends State<RevogarChaveMcpDialogo> {
  bool _enviando = false;
  String? _erro;

  Future<void> _revogar() async {
    setState(() {
      _enviando = true;
      _erro = null;
    });
    try {
      await widget.onRevogar();
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) {
        setState(() {
          _enviando = false;
          _erro = e is String ? e : 'Falha ao revogar a chave.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cores = context.sivColors;
    final textos = context.sivTextos;
    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500),
        child: Padding(
          padding: const EdgeInsets.all(SivDimensoes.paddingCard),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Revogar “${widget.chave.nome}”?', style: textos.secao),
              const SizedBox(height: 8),
              Text(widget.chave.chaveMascarada, style: textos.codigo.copyWith(fontSize: 12.5)),
              const SizedBox(height: 12),
              Text(
                'O agente que usa esta chave perderá o acesso imediatamente. '
                'Esta ação não pode ser desfeita.',
                style: textos.corpo,
              ),
              const SizedBox(height: 8),
              Text('A chave continua na lista, marcada como Revogada, para histórico.',
                  style: textos.apoio.copyWith(fontSize: 12.5)),
              if (_erro != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(10),
                  color: cores.falhaFundo,
                  child: Text(_erro!, style: textos.apoio.copyWith(color: cores.vinho)),
                ),
              ],
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: _enviando ? null : () => Navigator.of(context).pop(false),
                    child: const Text('Cancelar'),
                  ),
                  const SizedBox(width: 10),
                  FilledButton(
                    onPressed: _enviando ? null : _revogar,
                    style: FilledButton.styleFrom(backgroundColor: cores.vinho),
                    child: const Text('REVOGAR CHAVE'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
