import 'package:core/imagens.dart';
import 'package:core/injecoes.dart';
import 'package:flutter/material.dart';
import 'package:produtos/models.dart';
import 'package:produtos/use_cases.dart';

/// Foto do fornecedor da referência esperada. É de uso interno: fica separada
/// da galeria do site (que só mostra fotos `origem = site`) e nunca pode virar
/// pública nem capa. Ajuda o contador a reconhecer a peça quando ela chegar.
class FotoDoFornecedorReferencia extends StatefulWidget {
  final int referenciaId;

  const FotoDoFornecedorReferencia({super.key, required this.referenciaId});

  @override
  State<FotoDoFornecedorReferencia> createState() =>
      _FotoDoFornecedorReferenciaState();
}

class _FotoDoFornecedorReferenciaState
    extends State<FotoDoFornecedorReferencia> {
  List<ReferenciaMidia> _fotos = const [];
  bool _carregando = true;
  bool _enviando = false;

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  Future<void> _carregar() async {
    try {
      final fotos = await sl<RecuperarReferenciaMidias>().call(
        widget.referenciaId,
        doFornecedor: true,
      );
      if (mounted) setState(() => _fotos = fotos);
    } catch (_) {
      // sem a foto a tela segue normal
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  Future<void> _adicionar() async {
    final escolhidas = await showSelecionarImagemModal(context);
    final imagem = escolhidas?.firstOrNull;
    final bytes = imagem?.bytes;
    if (imagem == null || bytes == null) return;
    setState(() => _enviando = true);
    try {
      await sl<CriarReferenciaMidia>().call(
        bytes: bytes,
        fileName: imagem.path?.split('/').last ?? 'foto-fornecedor.jpg',
        referenciaId: widget.referenciaId,
        ePrincipal: false,
        ePublica: false,
        tipo: TipoReferenciaMidia.imagem,
        field: imagem.field ?? 'file',
        descricao: 'Foto do fornecedor',
        cor: null,
        tamanho: null,
        origem: 'fornecedor',
      );
      await _carregar();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Não foi possível enviar a foto.')),
        );
      }
    } finally {
      if (mounted) setState(() => _enviando = false);
    }
  }

  Future<void> _remover(ReferenciaMidia foto) async {
    try {
      await sl<ExcluirReferenciaMidia>().call(
        referenciaId: widget.referenciaId,
        id: foto.id,
      );
      await _carregar();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Não foi possível remover a foto.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                'FOTO DO FORNECEDOR',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
              ),
            ),
            if (_carregando || _enviando)
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            else
              IconButton(
                tooltip: 'Adicionar foto do fornecedor',
                visualDensity: VisualDensity.compact,
                icon: const Icon(Icons.add_a_photo_outlined, size: 20),
                onPressed: _adicionar,
              ),
          ],
        ),
        Text(
          'Uso interno: ajuda o contador a reconhecer a peça. Não vai para o site.',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        if (_fotos.isNotEmpty) ...[
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final foto in _fotos)
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: Image.network(
                        foto.url,
                        width: 72,
                        height: 72,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => const SizedBox(
                          width: 72,
                          height: 72,
                          child: Icon(Icons.broken_image_outlined),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 0,
                      right: 0,
                      child: InkWell(
                        onTap: () => _remover(foto),
                        child: const Icon(Icons.cancel, size: 18),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ],
      ],
    );
  }
}
