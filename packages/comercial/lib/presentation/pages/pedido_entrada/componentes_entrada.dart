import 'package:core/presentation.dart';
import 'package:core/seletores.dart';
import 'package:core/tema.dart';
import 'package:flutter/material.dart';

/// Busca de referências parecidas pelo nome (montada em `lib/routes.dart`; o
/// comercial não importa o pacote produtos).
typedef BuscaReferenciasParecidas = Future<List<ReferenciaParecida>> Function(
  String nome,
);

class ReferenciaParecida {
  final int id;
  final String nome;
  const ReferenciaParecida({required this.id, required this.nome});
}

/// Seletores montados em `lib/routes.dart` (o comercial não importa produtos).
class SeletoresEntrada {
  final SeletorWidget categoriaSeletor;
  final SeletorWidget referenciaSeletor;

  /// Referência com cadastro (wizard) -- usado na contagem sem NF-e.
  final SeletorWidget referenciaContagemSeletor;
  final SeletorWidget corSeletor;
  final SeletorWidget tamanhoSeletor;
  final BuscaReferenciasParecidas? buscarReferenciasParecidas;

  const SeletoresEntrada({
    required this.categoriaSeletor,
    required this.referenciaSeletor,
    required this.referenciaContagemSeletor,
    required this.corSeletor,
    required this.tamanhoSeletor,
    this.buscarReferenciasParecidas,
  });
}

String qtd(double v) => v == v.roundToDouble() ? '${v.toInt()}' : '$v';
String moeda(double v) => 'R\$ ${v.toStringAsFixed(2).replaceAll('.', ',')}';

bool ehMobile(BuildContext context) =>
    MediaQuery.sizeOf(context).width < SivDimensoes.breakpointMenuDrawer;

/// Altura do botão principal fixo no rodapé (50–52px no mobile).
const double alturaBotaoPrincipal = 52;

/// Botão principal com a moldura blueprint (cantos +), mínimo 44px de toque.
class BotaoPrincipalEntrada extends StatelessWidget {
  final String rotulo;
  final VoidCallback? onPressed;
  final IconData? icone;

  const BotaoPrincipalEntrada({
    super.key,
    required this.rotulo,
    required this.onPressed,
    this.icone,
  });

  @override
  Widget build(BuildContext context) {
    final cores = context.sivColors;
    return SizedBox(
      height: alturaBotaoPrincipal,
      child: Stack(
        children: [
          Positioned.fill(
            child: FilledButton(
              onPressed: onPressed,
              style: FilledButton.styleFrom(
                backgroundColor: cores.acoEscuro,
                foregroundColor: cores.textoSobreEscuroTitulo,
                minimumSize: const Size(0, alturaBotaoPrincipal),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(SivDimensoes.raio),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icone != null) ...[Icon(icone, size: 18), const SizedBox(width: 8)],
                  Flexible(
                    child: Text(
                      rotulo,
                      overflow: TextOverflow.ellipsis,
                      style: context.sivTextos.rotulo.copyWith(
                        color: cores.textoSobreEscuroTitulo,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          ...sivCantosBlueprint(cores.ceu),
        ],
      ),
    );
  }
}

/// Rodapé fixo de cada passo: resumo opcional à esquerda + ação principal.
class RodapeAcaoEntrada extends StatelessWidget {
  final Widget? resumo;
  final Widget? aviso;
  final Widget acao;

  const RodapeAcaoEntrada({
    super.key,
    required this.acao,
    this.resumo,
    this.aviso,
  });

  @override
  Widget build(BuildContext context) {
    final cores = context.sivColors;
    return Container(
      key: const Key('rodape_acao_entrada'),
      decoration: BoxDecoration(
        color: cores.superficie,
        border: Border(top: BorderSide(color: cores.hairline)),
      ),
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (aviso != null) ...[aviso!, const SizedBox(height: 8)],
            Row(
              children: [
                if (resumo != null) ...[
                  Flexible(child: resumo!),
                  const SizedBox(width: 12),
                ],
                Expanded(flex: resumo != null ? 2 : 1, child: acao),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Etiqueta de situação da conferência (cores do tema SIV).
class SituacaoEtiqueta extends StatelessWidget {
  final String texto;
  final Color fundo;
  final Color cor;
  const SituacaoEtiqueta({
    super.key,
    required this.texto,
    required this.fundo,
    required this.cor,
  });

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: fundo,
          borderRadius: BorderRadius.circular(SivDimensoes.raio),
        ),
        child: Text(
          texto,
          style: context.sivTextos.rotulo.copyWith(color: cor, fontSize: 10.5),
        ),
      );
}
