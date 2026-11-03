import 'package:core/bloc.dart';
import 'package:flutter/material.dart';
import 'package:produtos/presentantion/blocs/consultar_produto_bloc/consultar_produto_bloc.dart';
import 'package:produtos/presentantion/widgets/consulta/consulta_formato.dart';
import 'package:produtos/presentantion/widgets/consulta/consulta_grade_estoque.dart';

/// Detalhe da referência aberta (desktop: painel; mobile: corpo da rota de detalhe).
class ConsultaDetalhe extends StatelessWidget {
  const ConsultaDetalhe({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<ConsultarProdutoBloc>().state;
    final theme = Theme.of(context);
    final grade = state.grade;

    if (state.referenciaAbertaId == null) {
      return Center(
        child: Text('Selecione um produto na lista.', style: theme.textTheme.bodyMedium),
      );
    }
    if (grade == null) {
      return Center(
        child: state.erroGrade != null
            ? Text(state.erroGrade!, style: TextStyle(color: theme.colorScheme.error))
            : const CircularProgressIndicator(),
      );
    }

    final imagemUrl = grade.imagem?.url;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  width: 96,
                  height: 96,
                  child: imagemUrl != null
                      ? Image.network(imagemUrl, fit: BoxFit.cover, errorBuilder: (_, _, _) => const _SemFoto())
                      : const _SemFoto(),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(grade.nome, style: theme.textTheme.titleMedium),
                    if (grade.referenciaIdExterno != null)
                      Text('REF ${grade.referenciaIdExterno}', style: theme.textTheme.bodySmall),
                    const SizedBox(height: 8),
                    Text(
                      grade.valor != null ? moeda(grade.valor!) : 'Preço não cadastrado',
                      style: theme.textTheme.titleLarge,
                    ),
                    Text('Total em estoque: ${grade.totalEmEstoque}', style: theme.textTheme.bodyMedium),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (grade.produtos.isEmpty)
            Text('Nenhuma variação cadastrada para este produto.', style: theme.textTheme.bodyMedium)
          else
            ConsultaGradeEstoque(
              produtos: grade.produtos,
              corIds: state.corIds.toSet(),
              tamanhoIds: state.tamanhoIds.toSet(),
              estampaIds: state.estampaIds.toSet(),
              produtoIdLido: state.produtoIdLido,
            ),
        ],
      ),
    );
  }
}

class _SemFoto extends StatelessWidget {
  const _SemFoto();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return ColoredBox(
      color: cs.surfaceContainerHighest,
      child: Icon(Icons.image_not_supported_outlined, color: cs.onSurfaceVariant),
    );
  }
}
