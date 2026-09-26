import 'package:core/bloc.dart';
import 'package:core/tema.dart';
import 'package:core/presentation.dart';
import 'package:core/precos_portas.dart';
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

        final cores = context.sivColors;
        final textos = context.sivTextos;
        final rotuloColuna = textos.rotulo.copyWith(color: cores.textoApoio);

        return Stack(
          children: [
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: cores.superficie,
                  borderRadius: BorderRadius.circular(SivDimensoes.raio),
                  border: Border.all(color: cores.hairline),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 12,
                      ),
                      child: Row(
                        children: [
                          Expanded(flex: 3, child: Text('TABELA', style: rotuloColuna)),
                          SizedBox(
                            width: 110,
                            child: Text('TERMINADOR', style: rotuloColuna),
                          ),
                          SizedBox(
                            width: 190,
                            child: Text('ATUALIZADO', style: rotuloColuna),
                          ),
                          SizedBox(
                            width: 150,
                            child: Text(
                              'VALOR',
                              textAlign: TextAlign.right,
                              style: rotuloColuna,
                            ),
                          ),
                          const SizedBox(width: 80),
                        ],
                      ),
                    ),
                    Divider(height: 1, color: cores.hairline),
                    Expanded(
                      child: ListView.separated(
                        itemCount: state.tabelas.length,
                        separatorBuilder: (_, __) =>
                            Divider(height: 1, color: cores.hairline),
                        itemBuilder: (context, index) {
                          final tabela = state.tabelas[index];
                          final emEdicao =
                              state.tabelaEmEdicaoId == tabela.tabelaDePrecoId;

                          return emEdicao
                              ? _LinhaEmEdicao(state: state)
                              : _LinhaIdle(tabela: tabela);
                        },
                      ),
                    ),
                    Divider(height: 1, color: cores.hairline),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 10,
                      ),
                      child: Text(
                        'Enter salva · Esc cancela · tabela inativa fica só para consulta',
                        style: textos.apoio.copyWith(
                          fontSize: 12,
                          color: cores.textoApoio,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            ...sivCantosBlueprint(cores.hairline),
          ],
        );
      },
    );
  }
}

class _LinhaIdle extends StatelessWidget {
  final PrecoDaReferenciaPorTabela tabela;

  const _LinhaIdle({required this.tabela});

  @override
  Widget build(BuildContext context) {
    final cores = context.sivColors;
    final textos = context.sivTextos;

    return InkWell(
      onTap: tabela.tabelaInativa
          ? null
          : () => context.read<PrecosDaReferenciaBloc>().add(
              PrecosDaReferenciaEditouLinha(tabelaDePrecoId: tabela.tabelaDePrecoId),
            ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: Row(
                children: [
                  Flexible(
                    child: Text(
                      tabela.tabelaNome,
                      overflow: TextOverflow.ellipsis,
                      style: textos.secao.copyWith(
                        fontSize: 17,
                        color: cores.acoEscuro,
                      ),
                    ),
                  ),
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
            ),
            SizedBox(
              width: 110,
              child: Text(
                _formatarTerminador(tabela.terminador),
                style: textos.corpo,
              ),
            ),
            SizedBox(
              width: 190,
              child: Text(
                tabela.atualizadoEm == null
                    ? '-'
                    : _formatarData(tabela.atualizadoEm!),
                style: textos.apoio.copyWith(color: cores.textoApoio),
              ),
            ),
            SizedBox(
              width: 150,
              child: Text(
                tabela.temPreco
                    ? 'R\$ ${tabela.valor!.toStringAsFixed(2).replaceAll('.', ',')}'
                    : 'Sem preço · definir',
                textAlign: TextAlign.right,
                style: tabela.temPreco
                    ? textos.corpo.copyWith(fontWeight: FontWeight.w600)
                    : textos.corpo.copyWith(color: cores.textoDesabilitado),
              ),
            ),
            SizedBox(
              width: 80,
              child: tabela.tabelaInativa
                  ? null
                  : Icon(Icons.edit_outlined, size: 18, color: cores.textoApoio),
            ),
          ],
        ),
      ),
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
    final cores = context.sivColors;
    final textos = context.sivTextos;
    final tabela = widget.state.tabelas.firstWhere(
      (t) => t.tabelaDePrecoId == widget.state.tabelaEmEdicaoId,
    );
    final previa = widget.state.previaValorComTerminador;
    final salvando = widget.state.step == PrecosDaReferenciaStep.salvando;

    return Container(
      decoration: BoxDecoration(
        color: cores.selecaoFundo,
        border: Border(left: BorderSide(color: cores.aco, width: 3)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: Text(
              tabela.tabelaNome,
              style: textos.secao.copyWith(fontSize: 17, color: cores.acoEscuro),
            ),
          ),
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
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(SivDimensoes.raio),
                  borderSide: BorderSide(color: cores.aco, width: 2),
                ),
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
              style: textos.apoio.copyWith(color: cores.textoApoio),
            ),
          ],
          const SizedBox(width: 8),
          IconButton.filled(
            icon: const Icon(Icons.check),
            style: IconButton.styleFrom(
              backgroundColor: cores.aco,
              foregroundColor: Colors.white,
              minimumSize: const Size(34, 34),
            ),
            onPressed: salvando
                ? null
                : () => context.read<PrecosDaReferenciaBloc>().add(
                    PrecosDaReferenciaSalvou(),
                  ),
          ),
          const SizedBox(width: 4),
          IconButton.outlined(
            icon: const Icon(Icons.close),
            style: IconButton.styleFrom(minimumSize: const Size(34, 34)),
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
