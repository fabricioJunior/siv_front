import 'package:autenticacao/models.dart';
import 'package:flutter/material.dart';

class SelecionarPermissaoModal extends StatelessWidget {
  static Future<Permissao?> show(
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
  Widget build(BuildContext context) {
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
        const SizedBox(
          height: 40,
        ),
        Flexible(
          child: ListView.builder(
            itemCount: permissoes.length,
            itemBuilder: (context, index) {
              var permissao = permissoes[index];
              return _permissaoCard(context, permissao);
            },
            shrinkWrap: true,
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
          Navigator.of(context).pop(permissao);
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ID: ${permissao.id}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Nome: ${permissao.nome}',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    permissao.descontinuado
                        ? 'Status: Descontinuado'
                        : 'Status: Ativo',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: permissao.descontinuado
                              ? Colors.red
                              : Colors.green,
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
