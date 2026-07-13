import 'package:autenticacao/models.dart';
import 'package:autenticacao/presentation/utils/fluxos_de_permissao.dart';
import 'package:flutter/material.dart';

class SelecionarPermissaoModal extends StatefulWidget {
  static Future<List<Permissao>?> show(
    BuildContext context,
    List<Permissao> permissoes,
  ) async {
    return showModalBottomSheet(
      isScrollControlled: true,
      enableDrag: false,
      useSafeArea: true,
      context: context,
      builder: (context) => SelecionarPermissaoModal(permissoes: permissoes),
    );
  }

  final List<Permissao> permissoes;
  const SelecionarPermissaoModal({required this.permissoes, super.key});

  @override
  State<SelecionarPermissaoModal> createState() =>
      _SelecionarPermissaoModalState();
}

class _SelecionarPermissaoModalState extends State<SelecionarPermissaoModal> {
  final Set<String> _categoriasExpandidas = <String>{};

  void _toggleCategoria(String categoria) {
    setState(() {
      if (_categoriasExpandidas.contains(categoria)) {
        _categoriasExpandidas.remove(categoria);
      } else {
        _categoriasExpandidas.add(categoria);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final permissoesClassificadas =
        agruparPermissoesPorFluxo(widget.permissoes);

    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.all(8.0),
          child: Row(
            children: [
              BackButton(),
            ],
          ),
        ),
        Text(
          'Selecione a permissão',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              key: const Key('selecionar_todas_permissoes_button'),
              onPressed: widget.permissoes.isEmpty
                  ? null
                  : () {
                      Navigator.of(context).pop(widget.permissoes);
                    },
              icon: const Icon(Icons.select_all),
              label: const Text('Selecionar todos'),
            ),
          ),
        ),
        const SizedBox(height: 20),
        Flexible(
          child: ListView(
            shrinkWrap: true,
            children: [
              for (final entry in permissoesClassificadas.entries) ...[
                InkWell(
                  onTap: () => _toggleCategoria(entry.key),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 8, 12, 6),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            entry.key,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                        ),
                        Icon(
                          _categoriasExpandidas.contains(entry.key)
                              ? Icons.expand_less
                              : Icons.expand_more,
                        ),
                      ],
                    ),
                  ),
                ),
                if (_categoriasExpandidas.contains(entry.key))
                  ...entry.value
                      .map((permissao) => _permissaoCard(context, permissao)),
                const SizedBox(height: 8),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _permissaoCard(BuildContext context, Permissao permissao) {
    return Ink(
      color:
          permissao.descontinuado ? Colors.red.shade100 : Colors.green.shade100,
      child: InkWell(
        onTap: () {
          Navigator.of(context).pop([permissao]);
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nome amigável (nomeExibicao) é o texto principal --
                  // antes mostrava a descrição técnica crua do backend
                  // (ex: "Exclusão lógica de pagamento avulso"). Código
                  // interno vira detalhe pequeno, só pra quem precisa.
                  Text(
                    permissao.nomeExibicao,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    permissao.descontinuado
                        ? '${permissao.id} · Descontinuado'
                        : permissao.id,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: permissao.descontinuado
                              ? Colors.red
                              : Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
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
