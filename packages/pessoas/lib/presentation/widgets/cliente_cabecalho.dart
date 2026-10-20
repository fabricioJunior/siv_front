import 'package:core/tema.dart';
import 'package:flutter/material.dart';

class ClienteAcaoBotao {
  final String rotulo;
  final IconData icone;
  final VoidCallback aoPressionar;
  final bool primaria;

  const ClienteAcaoBotao({
    required this.rotulo,
    required this.icone,
    required this.aoPressionar,
    this.primaria = false,
  });

  Widget botao() => primaria
      ? FilledButton.icon(
          onPressed: aoPressionar, icon: Icon(icone, size: 16), label: Text(rotulo))
      : OutlinedButton.icon(
          onPressed: aoPressionar, icon: Icon(icone, size: 16), label: Text(rotulo));
}

/// Cabeçalho fixo: voltar, nome, documento · cidade, situação e ações da aba.
/// No mobile só o lápis de edição (a ação principal da aba vai ao rodapé).
class ClienteCabecalho extends StatelessWidget {
  final String nome;
  final String? subtitulo;
  final bool bloqueado;
  final bool mobile;
  final List<ClienteAcaoBotao> acoes;
  final VoidCallback? aoEditar;

  const ClienteCabecalho({
    super.key,
    required this.nome,
    required this.subtitulo,
    required this.bloqueado,
    required this.mobile,
    required this.acoes,
    this.aoEditar,
  });

  @override
  Widget build(BuildContext context) {
    final cores = context.sivColors;
    final textos = context.sivTextos;
    final corTag = bloqueado ? cores.vinho : cores.textoPrincipal;

    return Container(
      height: SivDimensoes.alturaBarraTitulo,
      padding: EdgeInsets.symmetric(
        horizontal: mobile ? 8 : SivDimensoes.paddingBarraTituloHorizontal,
      ),
      decoration: BoxDecoration(
        color: cores.superficie,
        border: Border(bottom: BorderSide(color: cores.hairline)),
      ),
      child: Row(
        children: [
          const BackButton(),
          const SizedBox(width: 4),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        nome,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textos.secao.copyWith(fontSize: 21),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: bloqueado ? cores.vinho : cores.hairline,
                        ),
                        borderRadius: BorderRadius.circular(SivDimensoes.raio),
                      ),
                      child: Text(
                        bloqueado ? 'Bloqueado' : 'Ativo',
                        style: textos.apoio.copyWith(color: corTag),
                      ),
                    ),
                  ],
                ),
                if (subtitulo != null)
                  Text(
                    subtitulo!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textos.apoio.copyWith(color: cores.textoApoio),
                  ),
              ],
            ),
          ),
          if (mobile)
            if (aoEditar != null)
              IconButton(
                tooltip: 'Editar cadastro',
                onPressed: aoEditar,
                icon: const Icon(Icons.edit_outlined),
              )
            else
              const SizedBox.shrink()
          else
            for (final a in acoes) ...[
              const SizedBox(width: 10),
              a.botao(),
            ],
        ],
      ),
    );
  }
}
