import 'package:core/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:produtos/presentation.dart';

class ReferenciaPrecosTab extends StatelessWidget {
  final int referenciaId;

  const ReferenciaPrecosTab({super.key, required this.referenciaId});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PrecosDaReferenciaBloc, PrecosDaReferenciaState>(
      builder: (context, state) {
        if (state.step == PrecosDaReferenciaStep.carregando ||
            state.step == PrecosDaReferenciaStep.inicial) {
          return const Center(child: CircularProgressIndicator.adaptive());
        }

        if (state.step == PrecosDaReferenciaStep.falha) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Falha ao carregar tabelas de preço.'),
                const SizedBox(height: 8),
                OutlinedButton(
                  onPressed: () => context.read<PrecosDaReferenciaBloc>().add(
                    PrecosDaReferenciaIniciou(referenciaId: referenciaId),
                  ),
                  child: const Text('Tentar novamente'),
                ),
              ],
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ListView.separated(
                itemCount: state.tabelas.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final tabela = state.tabelas[index];
                  final emEdicao = state.tabelaEmEdicaoId == tabela.tabelaDePrecoId;

                  if (emEdicao) {
                    return _LinhaEmEdicao(state: state);
                  }

                  return ListTile(
                    onTap: tabela.tabelaInativa
                        ? null
                        : () => context.read<PrecosDaReferenciaBloc>().add(
                            PrecosDaReferenciaEditouLinha(
                              tabelaDePrecoId: tabela.tabelaDePrecoId,
                            ),
                          ),
                    title: Row(
                      children: [
                        Text(tabela.tabelaNome),
                        if (tabela.tabelaPadrao) ...[
                          const SizedBox(width: 6),
                          const Chip(
                            label: Text('Padrão'),
                            visualDensity: VisualDensity.compact,
                          ),
                        ],
                        if (tabela.tabelaInativa) ...[
                          const SizedBox(width: 6),
                          const Chip(
                            label: Text('Inativa'),
                            visualDensity: VisualDensity.compact,
                          ),
                        ],
                      ],
                    ),
                    subtitle: Text(
                      'Terminador: ${_formatarTerminador(tabela.terminador)}'
                      '${tabela.atualizadoEm == null ? '' : ' · atualizado em ${_formatarData(tabela.atualizadoEm!)}'}',
                    ),
                    trailing: Text(
                      tabela.temPreco
                          ? 'R\$ ${tabela.valor!.toStringAsFixed(2).replaceAll('.', ',')}'
                          : 'Sem preço · definir',
                      style: TextStyle(
                        fontWeight: tabela.temPreco
                            ? FontWeight.w600
                            : FontWeight.normal,
                        color: tabela.temPreco ? null : Colors.grey,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  String _formatarTerminador(double? terminador) {
    if (terminador == null) return '-';
    final centavos = (terminador % 1) * 100;
    return ',${centavos.round().toString().padLeft(2, '0')}';
  }

  String _formatarData(DateTime data) {
    return '${data.day.toString().padLeft(2, '0')}/'
        '${data.month.toString().padLeft(2, '0')}/${data.year}';
  }
}

class _LinhaEmEdicao extends StatefulWidget {
  final PrecosDaReferenciaState state;

  const _LinhaEmEdicao({required this.state});

  @override
  State<_LinhaEmEdicao> createState() => _LinhaEmEdicaoState();
}

class _LinhaEmEdicaoState extends State<_LinhaEmEdicao> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.state.valorDigitado);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tabela = widget.state.tabelas.firstWhere(
      (t) => t.tabelaDePrecoId == widget.state.tabelaEmEdicaoId,
    );
    final previa = widget.state.previaValorComTerminador;
    final salvando = widget.state.step == PrecosDaReferenciaStep.salvando;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(child: Text(tabela.tabelaNome)),
          SizedBox(
            width: 160,
            child: TextField(
              controller: _controller,
              autofocus: true,
              enabled: !salvando,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
              ],
              decoration: InputDecoration(
                isDense: true,
                prefixText: 'R\$ ',
                errorText: widget.state.erroValidacao,
              ),
              onChanged: (texto) => context.read<PrecosDaReferenciaBloc>().add(
                PrecosDaReferenciaValorAlterou(texto: texto),
              ),
              onSubmitted: (_) => context.read<PrecosDaReferenciaBloc>().add(
                PrecosDaReferenciaSalvou(),
              ),
            ),
          ),
          if (previa != null) ...[
            const SizedBox(width: 8),
            Text(
              'Será salvo como R\$ ${previa.toStringAsFixed(2).replaceAll('.', ',')}',
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: salvando
                ? null
                : () => context.read<PrecosDaReferenciaBloc>().add(
                    PrecosDaReferenciaSalvou(),
                  ),
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: salvando
                ? null
                : () => context.read<PrecosDaReferenciaBloc>().add(
                    PrecosDaReferenciaCancelouEdicao(),
                  ),
          ),
        ],
      ),
    );
  }
}
