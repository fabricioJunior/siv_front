import 'package:core/presentation.dart';
import 'package:core/tema.dart';
import 'package:flutter/material.dart';

/// Casca dos forms de cupom e promocao: modal no desktop, pagina no mobile.
///
/// Uso nas paginas dos forms: a pagina devolve este layout como raiz (dentro
/// do `Form`), com o corpo do form como um widget so. A mesma pagina serve
/// de rota (mobile/deep link) e de conteudo do modal (desktop); quem abre
/// chama [abrir]. Ao salvar com sucesso a pagina faz `Navigator.pop(true)`.
class FormPromocionalLayout extends StatelessWidget {
  final String titulo;
  final Widget corpo;
  final String rotuloSalvar;
  final bool salvando;
  final VoidCallback onSalvar;
  final double larguraModal;

  const FormPromocionalLayout({
    super.key,
    required this.titulo,
    required this.corpo,
    required this.rotuloSalvar,
    required this.salvando,
    required this.onSalvar,
    this.larguraModal = 560,
  });

  static bool _desktop(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= SivDimensoes.breakpointMenuDrawer;

  /// Desktop: modal que constroi [pagina]. Mobile: `pushNamed` de [rota].
  static Future<bool?> abrir(
    BuildContext context, {
    required String rota,
    required Map<String, Object?> arguments,
    required WidgetBuilder pagina,
  }) {
    if (!_desktop(context)) {
      return Navigator.of(context).pushNamed<bool>(rota, arguments: arguments);
    }
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      barrierColor: context.sivColors.acoEscuro.withValues(alpha: 0.35),
      builder: pagina,
    );
  }

  Widget _botaoSalvar(BuildContext context) {
    final cores = context.sivColors;
    return ElevatedButton(
      onPressed: salvando ? null : onSalvar,
      child: salvando
          ? SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: cores.superficie,
              ),
            )
          : Text(rotuloSalvar),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_desktop(context)) {
      return SivModal(
        titulo: titulo,
        corpo: corpo,
        larguraMaxima: larguraModal,
        fechavel: !salvando,
        acoes: [
          TextButton(
            onPressed: salvando ? null : () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          _botaoSalvar(context),
        ],
      );
    }

    final cores = context.sivColors;
    return Scaffold(
      backgroundColor: cores.superficie,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Container(
              height: 52,
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: cores.hairline)),
              ),
              child: Row(
                children: [
                  IconButton(
                    constraints: const BoxConstraints.tightFor(
                      width: SivDimensoes.alvoToqueMinimo,
                      height: SivDimensoes.alvoToqueMinimo,
                    ),
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Navigator.of(context).maybePop(),
                  ),
                  Expanded(
                    child: Text(titulo, style: context.sivTextos.secao),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.all(SivDimensoes.paddingCard),
                child: corpo,
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
              decoration: BoxDecoration(
                color: cores.superficie,
                border: Border(top: BorderSide(color: cores.hairline)),
              ),
              child: SafeArea(
                top: false,
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: _botaoSalvar(context),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Rotulo acima do campo. [filho] ja mostra o proprio erro abaixo.
class RotuloCampo extends StatelessWidget {
  final String rotulo;
  final Widget filho;

  const RotuloCampo({super.key, required this.rotulo, required this.filho});

  @override
  Widget build(BuildContext context) {
    final textos = context.sivTextos;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          rotulo,
          style: textos.apoio.copyWith(
            color: context.sivColors.tinta,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        filho,
      ],
    );
  }
}

/// Segmento de opcoes (estilo `.seg`): selecionado em `aco` com texto em
/// `superficie`. Quebra linha quando nao cabe.
class SegmentoOpcoes<T> extends StatelessWidget {
  final Map<T, String> opcoes;
  final T selecionado;
  final ValueChanged<T> onChanged;

  const SegmentoOpcoes({
    super.key,
    required this.opcoes,
    required this.selecionado,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final cores = context.sivColors;
    final textos = context.sivTextos;
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final e in opcoes.entries)
          Material(
            color: e.key == selecionado ? cores.aco : cores.superficie,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(SivDimensoes.raio),
              side: BorderSide(
                color: e.key == selecionado ? cores.aco : cores.hairline,
              ),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(SivDimensoes.raio),
              onTap: () => onChanged(e.key),
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  minHeight: SivDimensoes.alvoToqueMinimo,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Center(
                    widthFactor: 1,
                    child: Text(
                      e.value,
                      style: textos.corpo.copyWith(
                        color: e.key == selecionado
                            ? cores.superficie
                            : cores.tinta,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
