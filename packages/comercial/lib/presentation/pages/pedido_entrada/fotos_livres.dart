import 'package:comercial/domain/models/pedido_entrada.dart';
import 'package:comercial/presentation/pages/pedido_entrada/adicionar_foto_contagem.dart';
import 'package:comercial/presentation/pages/pedido_entrada/foto_ampliada_dialog.dart';
import 'package:core/tema.dart';
import 'package:flutter/material.dart';
import 'package:produtos/models.dart';

/// Fotos de um produto contado sem referência: miniaturas (toque amplia, para
/// o responsável conferir antes de associar) e "+ FOTO" para quem tem a
/// permissão. [onAdicionar]/[onRemover] nulos escondem as ações.
class FotosLivres extends StatelessWidget {
  final String descricao;
  final List<FotoLivre> fotos;
  final double tamanho;
  final VoidCallback? onAdicionar;
  final void Function(FotoLivre foto)? onRemover;

  const FotosLivres({
    super.key,
    required this.descricao,
    required this.fotos,
    this.tamanho = 56,
    this.onAdicionar,
    this.onRemover,
  });

  @override
  Widget build(BuildContext context) {
    final cores = context.sivColors;
    final textos = context.sivTextos;
    final podeAdicionar = onAdicionar != null && podeAdicionarFotoContagem;
    if (fotos.isEmpty && !podeAdicionar) return const SizedBox.shrink();

    final midias = [
      for (final f in fotos) ReferenciaMidiaSimples(url: f.url, origem: f.origem),
    ];
    return SizedBox(
      height: tamanho,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          for (var i = 0; i < fotos.length; i++)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: InkWell(
                key: Key('foto_livre_${fotos[i].id}'),
                onTap: () => showFotoAmpliada(
                  context,
                  referenciaNome: descricao,
                  referenciaCodigo: fotos[i].origem == 'fornecedor'
                      ? 'Foto do fornecedor'
                      : 'Foto da contagem',
                  fotos: midias,
                  indiceInicial: i,
                ),
                onLongPress: onRemover == null ? null : () => onRemover!(fotos[i]),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(SivDimensoes.raio),
                  child: Image.network(
                    fotos[i].url,
                    width: tamanho,
                    height: tamanho,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: tamanho,
                      height: tamanho,
                      color: cores.hairline,
                      child: const Icon(Icons.broken_image_outlined),
                    ),
                  ),
                ),
              ),
            ),
          if (podeAdicionar)
            InkWell(
              key: Key('foto_livre_adicionar_$descricao'),
              onTap: onAdicionar,
              child: Container(
                width: tamanho,
                height: tamanho,
                decoration: BoxDecoration(
                  border: Border.all(color: cores.hairline),
                  borderRadius: BorderRadius.circular(SivDimensoes.raio),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.add_a_photo_outlined, size: 20),
                    Text('FOTO', style: textos.apoio.copyWith(fontSize: 10)),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
