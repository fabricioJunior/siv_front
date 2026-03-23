import 'package:flutter/material.dart';
import 'package:core/bloc.dart';
import 'package:core/imagens.dart';
import 'package:produtos/models.dart';
import 'package:produtos/presentantion/modals/referencia_midia_metadados_modal.dart';
import '../bloc/referencia_midias_bloc/referencia_midias_bloc.dart';

const int _limiteMaximoMidias = 20;

class ReferenciaMidiasWidget extends StatelessWidget {
  final int referenciaId;

  const ReferenciaMidiasWidget({Key? key, required this.referenciaId})
    : super(key: key);

  Future<void> _adicionarMidia(BuildContext context) async {
    final bloc = context.read<ReferenciaMidiasBloc>();
    final state = bloc.state;
    final total = state is ReferenciaMidiasCarregado ? state.midias.length : 0;

    if (total >= _limiteMaximoMidias) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Limite de $_limiteMaximoMidias imagens atingido para esta referência.',
          ),
        ),
      );
      return;
    }

    final picked = await showSelecionarImagemModal(context);
    if (picked == null || picked.isEmpty) return;

    // Metadados opcionais: descrição livre + cor e tamanho associados
    final metadados = await ReferenciaMidiaMetadadosModal.show(context);
    if (metadados == null) return; // usuário cancelou

    final cor = metadados.cor;
    final tamanho = metadados.tamanho;

    // Monta a field key usando cor_tamanho com underscore como separador
    final String field;
    final String? descricao;

    if (cor != null && tamanho != null) {
      final corKey = cor.nome.toLowerCase().replaceAll(' ', '_');
      final tamanhoKey = tamanho.nome.toLowerCase().replaceAll(' ', '_');
      field = '${corKey}_$tamanhoKey';
      descricao = 'Cor: ${cor.nome}, Tamanho: ${tamanho.nome}';
    } else if (cor != null) {
      field = cor.nome.toLowerCase().replaceAll(' ', '_');
      descricao = metadados.descricao?.isNotEmpty == true
          ? metadados.descricao
          : 'Cor: ${cor.nome}';
    } else if (tamanho != null) {
      field = tamanho.nome.toLowerCase().replaceAll(' ', '_');
      descricao = metadados.descricao?.isNotEmpty == true
          ? metadados.descricao
          : 'Tamanho: ${tamanho.nome}';
    } else {
      field = 'arquivo';
      descricao = metadados.descricao?.isNotEmpty == true
          ? metadados.descricao
          : null;
    }

    final imagem = Imagem(
      path: picked.first.path,
      bytes: picked.first.bytes,
      field: field,
      descricao: descricao,
    );

    bloc.add(AdicionarMidiaReferencia(referenciaId, [imagem]));
  }

  void _removerMidia(BuildContext context, int midiaId) {
    context.read<ReferenciaMidiasBloc>().add(
      RemoverMidiaReferencia(referenciaId, midiaId),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ReferenciaMidiasBloc, ReferenciaMidiasState>(
      builder: (context, state) {
        final carregando = state is ReferenciaMidiasCarregando;
        final midias = state is ReferenciaMidiasCarregado
            ? state.midias
            : <ReferenciaMidia>[];
        final limiteAtingido = midias.length >= _limiteMaximoMidias;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Mídias (${midias.length}/$_limiteMaximoMidias)',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                if (carregando)
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                else
                  IconButton(
                    icon: const Icon(Icons.add_a_photo),
                    onPressed: limiteAtingido
                        ? null
                        : () => _adicionarMidia(context),
                    tooltip: limiteAtingido
                        ? 'Limite de imagens atingido'
                        : 'Adicionar imagem',
                  ),
              ],
            ),
            if (state is ReferenciaMidiasErro)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  state.mensagem,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                    fontSize: 12,
                  ),
                ),
              ),
            const SizedBox(height: 8),
            if (midias.isEmpty && !carregando)
              const Text(
                'Nenhuma mídia cadastrada.',
                style: TextStyle(color: Colors.grey),
              ),
            if (midias.isNotEmpty)
              SizedBox(
                height: 140,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: midias.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, i) {
                    final midia = midias[i];
                    return _MidiaCard(
                      midia: midia,
                      onRemover: () => _removerMidia(context, midia.id),
                    );
                  },
                ),
              ),
          ],
        );
      },
    );
  }
}

class _MidiaCard extends StatelessWidget {
  final ReferenciaMidia midia;
  final VoidCallback onRemover;

  const _MidiaCard({required this.midia, required this.onRemover});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 120,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  midia.url,
                  width: 120,
                  height: 100,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 120,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.broken_image),
                  ),
                ),
              ),
              Positioned(
                top: 4,
                right: 4,
                child: GestureDetector(
                  onTap: onRemover,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.all(2),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
              ),
              if (midia.ePrincipal)
                Positioned(
                  bottom: 4,
                  left: 4,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 2,
                    ),
                    child: const Text(
                      'Principal',
                      style: TextStyle(color: Colors.white, fontSize: 9),
                    ),
                  ),
                ),
            ],
          ),
          if (midia.descricao?.isNotEmpty == true)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                midia.descricao!,
                style: const TextStyle(fontSize: 10, color: Colors.grey),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
        ],
      ),
    );
  }
}
