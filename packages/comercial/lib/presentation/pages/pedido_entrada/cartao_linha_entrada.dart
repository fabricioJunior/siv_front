import 'package:comercial/domain/models/pedido_entrada.dart';
import 'package:comercial/presentation/blocs/pedido_entrada_bloc/pedido_entrada_bloc.dart';
import 'package:comercial/presentation/pages/pedido_entrada/componentes_entrada.dart';
import 'package:core/bloc.dart';
import 'package:core/seletores.dart';
import 'package:flutter/material.dart';

class CabecalhoEntrada extends StatelessWidget {
  final EntradaResumo resumo;
  const CabecalhoEntrada({required this.resumo});

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context).textTheme;
    final nfe = resumo.nfe;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              nfe == null
                  ? 'Origem: ${resumo.origemEntrada ?? 'MANUAL'}'
                  : 'NF-e ${nfe.numero}/${nfe.serie} · ${nfe.emitenteNome}',
              style: tema.titleMedium,
            ),
            if (nfe != null) ...[
              const SizedBox(height: 4),
              Text(
                'Chave ${nfe.chaveAcesso}\nValor da nota ${moeda(nfe.valorTotal)}',
                style: tema.bodySmall,
              ),
            ],
            const SizedBox(height: 8),
            Wrap(
              spacing: 24,
              children: [
                Text('NF-e: ${qtd(resumo.totalNfe)} un.'),
                Text('Contado: ${qtd(resumo.totalContado)} un.'),
                Text(
                  'Diferença: ${qtd(resumo.totalContado - resumo.totalNfe)}',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class PendenciasEntrada extends StatelessWidget {
  final List<String> pendencias;
  const PendenciasEntrada({required this.pendencias});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.amber.shade50,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Pendências antes de conferir',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            for (final p in pendencias) Text('• $p'),
          ],
        ),
      ),
    );
  }
}

class CartaoLinhaEntrada extends StatelessWidget {
  final EntradaResumo resumo;
  final EntradaLinha linha;
  final bool salvando;
  final SeletoresEntrada seletores;
  final void Function(EntradaLinha linha) onContar;

  const CartaoLinhaEntrada({
    required this.resumo,
    required this.linha,
    required this.salvando,
    required this.seletores,
    required this.onContar,
  });

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context).textTheme;
    final bloc = context.read<PedidoEntradaBloc>();
    final ignorada = linha.status == StatusLinhaEntrada.ignorada;
    final contada = linha.quantidadeContada;
    final dif = linha.diferenca;
    final corDif = dif == null || dif == 0
        ? null
        : (linha.divergenciaResolvida ? Colors.grey : Colors.red);

    return Card(
      key: Key('entrada_linha_${linha.id}'),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Opacity(
          opacity: ignorada ? 0.5 : 1,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '${linha.sequencia}. ${linha.descricao}',
                      style: tema.titleSmall,
                    ),
                  ),
                  Chip(
                    label: Text(linha.status.rotulo),
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
              Text(
                [
                  if (linha.codigoFornecedor != null)
                    'Cód. fornecedor ${linha.codigoFornecedor}',
                  if (linha.ncm != null) 'NCM ${linha.ncm}',
                  if (linha.unidade != null) linha.unidade!,
                  'unit. ${moeda(linha.valorUnitario)}',
                ].join(' · '),
                style: tema.bodySmall,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 24,
                children: [
                  Text('NF-e: ${qtd(linha.quantidadeNfe)}'),
                  Text('Contado: ${contada == null ? '—' : qtd(contada)}'),
                  Text(
                    'Diferença: ${dif == null ? '—' : (dif > 0 ? '+' : '') + qtd(dif)}',
                    style: TextStyle(color: corDif),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  if (linha.status == StatusLinhaEntrada.naoCadastrado) ...[
                    OutlinedButton(
                      onPressed: salvando
                          ? null
                          : () => _preCadastrar(context, bloc),
                      child: const Text('Pré-cadastrar'),
                    ),
                    OutlinedButton(
                      onPressed: salvando
                          ? null
                          : () => _vincular(context, bloc),
                      child: const Text('Vincular a referência'),
                    ),
                  ],
                  if (linha.status == StatusLinhaEntrada.mapeado ||
                      linha.status == StatusLinhaEntrada.referenciaVinculada)
                    FilledButton.tonal(
                      key: Key('entrada_contar_${linha.id}'),
                      onPressed: salvando ? null : () => onContar(linha),
                      child: const Text('Contar'),
                    ),
                  if (linha.status == StatusLinhaEntrada.referenciaVinculada &&
                      linha.referenciaId != null)
                    TextButton(
                      onPressed: () => Navigator.of(context).pushNamed(
                        '/referencia',
                        arguments: {'idReferencia': linha.referenciaId},
                      ),
                      child: const Text('Abrir referência'),
                    ),
                  if (linha.divergente && !linha.divergenciaResolvida)
                    OutlinedButton(
                      onPressed: salvando
                          ? null
                          : () => _resolver(context, bloc),
                      child: const Text('Resolver divergência'),
                    ),
                  if (contada == null)
                    TextButton(
                      onPressed: salvando
                          ? null
                          : () => bloc.add(
                              PedidoEntradaIgnorouLinha(
                                linha.id,
                                ignorar: !ignorada,
                              ),
                            ),
                      child: Text(ignorada ? 'Reativar' : 'Ignorar'),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _preCadastrar(
    BuildContext context,
    PedidoEntradaBloc bloc,
  ) async {
    final nome = TextEditingController(text: linha.descricao);
    int? categoriaId;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: const Text('Pré-cadastrar referência'),
          content: SizedBox(
            width: 420,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nome,
                  decoration: const InputDecoration(labelText: 'Nome'),
                ),
                const SizedBox(height: 12),
                seletores.categoriaSeletor(
                  SeletorData(
                    compacto: true,
                    onChanged: (itens) => setState(
                      () => categoriaId = itens.isEmpty ? null : itens.first.id,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'NCM, unidade e custo vêm da NF-e. Subcategoria, grade e '
                  'preço de venda se completam na referência.',
                  style: TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: categoriaId == null
                  ? null
                  : () => Navigator.pop(ctx, true),
              child: const Text('Criar referência'),
            ),
          ],
        ),
      ),
    );
    if (ok == true && categoriaId != null) {
      bloc.add(
        PedidoEntradaPreCadastrouLinha(
          linha.id,
          categoriaId: categoriaId!,
          nome: nome.text.trim().isEmpty ? null : nome.text.trim(),
        ),
      );
    }
    nome.dispose();
  }

  Future<void> _vincular(BuildContext context, PedidoEntradaBloc bloc) async {
    int? referenciaId;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: const Text('Vincular a uma referência'),
          content: SizedBox(
            width: 420,
            child: seletores.referenciaSeletor(
              SeletorData(
                compacto: true,
                onChanged: (itens) => setState(
                  () => referenciaId = itens.isEmpty ? null : itens.first.id,
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: referenciaId == null
                  ? null
                  : () => Navigator.pop(ctx, true),
              child: const Text('Vincular'),
            ),
          ],
        ),
      ),
    );
    if (ok == true && referenciaId != null) {
      bloc.add(PedidoEntradaVinculouLinha(linha.id, referenciaId!));
    }
  }

  Future<void> _resolver(BuildContext context, PedidoEntradaBloc bloc) async {
    final obs = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Resolver divergência'),
        content: TextField(
          controller: obs,
          maxLength: 255,
          decoration: const InputDecoration(
            labelText: 'Explicação (ex.: veio 1 a menos)',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Resolver'),
          ),
        ],
      ),
    );
    if (ok == true) {
      bloc.add(
        PedidoEntradaResolveuDivergencia(
          linha.id,
          observacao: obs.text.trim().isEmpty ? null : obs.text.trim(),
        ),
      );
    }
    obs.dispose();
  }
}
