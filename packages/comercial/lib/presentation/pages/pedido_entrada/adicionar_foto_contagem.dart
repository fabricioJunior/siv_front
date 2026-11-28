import 'package:core/imagens.dart';
import 'package:core/injecoes.dart';
import 'package:core/presentation.dart';
import 'package:flutter/material.dart';
import 'package:produtos/domain/data/repositorios/i_referencia_midias_repository.dart';
import 'package:produtos/models.dart';

/// Permissão própria (fluxo "Entrada por contagem" > "Cadastrar fotos do
/// fornecedor e da chegada").
bool get podeAdicionarFotoContagem =>
    PermissaoPorNome.acessoPermitido('PRDFM015');

/// Pergunta a origem (fornecedor ou tirada na contagem), pega a foto da câmera
/// ou da galeria e envia. Devolve a foto salva, ou null se cancelou/falhou.
Future<ReferenciaMidiaSimples?> adicionarFotoContagem(
  BuildContext context,
  int referenciaId,
) async {
  final origem = await showModalBottomSheet<String>(
    context: context,
    builder: (ctx) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            key: const Key('foto_origem_fornecedor'),
            leading: const Icon(Icons.local_shipping_outlined),
            title: const Text('Foto do fornecedor'),
            subtitle: const Text('Peça enviada pelo fornecedor (catálogo, WhatsApp)'),
            onTap: () => Navigator.pop(ctx, 'fornecedor'),
          ),
          ListTile(
            key: const Key('foto_origem_chegada'),
            leading: const Icon(Icons.inventory_2_outlined),
            title: const Text('Foto tirada na contagem'),
            subtitle: const Text('Peça inteira, de frente, sobre fundo liso'),
            onTap: () => Navigator.pop(ctx, 'chegada'),
          ),
        ],
      ),
    ),
  );
  if (origem == null || !context.mounted) return null;

  final imagens = await showSelecionarImagemModal(context);
  final bytes = imagens?.firstOrNull?.bytes;
  if (bytes == null || !context.mounted) return null;

  final messenger = ScaffoldMessenger.of(context);
  try {
    final enviada = await comprimirImagem(bytes);
    final midia = await sl<IReferenciaMidiasRepository>().registrarFotoContagem(
      bytes: enviada,
      fileName: 'foto_$origem.jpg',
      referenciaId: referenciaId,
      origem: origem,
    );
    return ReferenciaMidiaSimples(
      url: midia.url,
      urlMiniatura: midia.urlMiniatura,
      origem: origem,
    );
  } catch (_) {
    messenger.showSnackBar(
      const SnackBar(content: Text('Não foi possível enviar a foto.')),
    );
    return null;
  }
}
