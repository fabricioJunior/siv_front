import 'dart:typed_data';

import 'package:comercial/data.dart';
import 'package:comercial/presentation/blocs/pedido_entrada_bloc/pedido_entrada_bloc.dart';
import 'package:core/bloc.dart';
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

/// Pergunta a origem (fornecedor ou tirada na contagem) e pega a foto da
/// câmera ou da galeria, já comprimida. Null se cancelou.
Future<({String origem, Uint8List bytes})?> escolherFotoContagem(
  BuildContext context,
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
  return (origem: origem, bytes: await comprimirImagem(bytes));
}

void _falhou(ScaffoldMessengerState messenger) => messenger.showSnackBar(
      const SnackBar(content: Text('Não foi possível enviar a foto.')),
    );

/// Foto de uma referência (esperada). Devolve a foto salva, ou null.
Future<ReferenciaMidiaSimples?> adicionarFotoContagem(
  BuildContext context,
  int referenciaId,
) async {
  final messenger = ScaffoldMessenger.of(context);
  try {
    final foto = await escolherFotoContagem(context);
    if (foto == null) return null;
    final midia = await sl<IReferenciaMidiasRepository>().registrarFotoContagem(
      bytes: foto.bytes,
      fileName: 'foto_${foto.origem}.jpg',
      referenciaId: referenciaId,
      origem: foto.origem,
    );
    return ReferenciaMidiaSimples(
      url: midia.url,
      urlMiniatura: midia.urlMiniatura,
      origem: foto.origem,
    );
  } catch (_) {
    _falhou(messenger);
    return null;
  }
}

/// Foto de um produto contado sem referência (agrupado pela [descricao]).
/// O resumo devolvido pelo servidor já traz a foto: atualiza o bloc.
Future<void> adicionarFotoLivre(
  BuildContext context,
  int pedidoId,
  String descricao,
) async {
  final messenger = ScaffoldMessenger.of(context);
  final bloc = context.read<PedidoEntradaBloc>();
  try {
    final foto = await escolherFotoContagem(context);
    if (foto == null) return;
    final resumo = await sl<IFotosLivresRemoteDataSource>().adicionar(
      pedidoId,
      descricao: descricao,
      origem: foto.origem,
      bytes: foto.bytes,
      fileName: 'foto_${foto.origem}.jpg',
    );
    bloc.add(PedidoEntradaAtualizouResumo(resumo));
  } catch (_) {
    _falhou(messenger);
  }
}

Future<void> removerFotoLivre(
  BuildContext context,
  int pedidoId,
  int fotoId,
) async {
  final messenger = ScaffoldMessenger.of(context);
  final bloc = context.read<PedidoEntradaBloc>();
  try {
    final resumo = await sl<IFotosLivresRemoteDataSource>().remover(pedidoId, fotoId);
    bloc.add(PedidoEntradaAtualizouResumo(resumo));
  } catch (_) {
    messenger.showSnackBar(
      const SnackBar(content: Text('Não foi possível remover a foto.')),
    );
  }
}
