import 'package:comercial/domain/models/pedido_entrada.dart';
import 'package:comercial/presentation/blocs/pedido_entrada_bloc/pedido_entrada_bloc.dart';
import 'package:comercial/presentation/pages/pedido_entrada/componentes_entrada.dart';
import 'package:core/bloc.dart';
import 'package:core/leitor.dart';
import 'package:core/tema.dart';
import 'package:flutter/material.dart';

/// Passo 4: LeitorWidget em modo conferência (contado × lido). Cada bipe é
/// repassado a [onConferirCodigo] (servidor: lido = atendido).
class PassoConferir extends StatelessWidget {
  final EntradaResumo resumo;
  final ILeitorDataDatasource dataSource;
  final ILeitorBuscaDataDatasource? buscaDataSource;

  /// Soma [quantidade] (negativa = remover leitura) ao atendido do produto.
  final void Function(String codigoDeBarras, int quantidade) onConferirCodigo;
  final ValueChanged<int> onIrParaPasso;

  const PassoConferir({
    super.key,
    required this.resumo,
    required this.dataSource,
    this.buscaDataSource,
    required this.onConferirCodigo,
    required this.onIrParaPasso,
  });

  List<ProdutoEsperado>? get _esperados {
    final itens = resumo.conferencia.itens;
    if (itens.isEmpty) return null; // backend antigo: leitor comum
    return [
      for (final i in itens)
        ProdutoEsperado(
          id: i.produtoId,
          codigoDeBarras: i.codigoDeBarras,
          descricao: i.descricao,
          idReferencia: i.idReferencia,
          cor: i.cor,
          tamanho: i.tamanho,
          esperado: i.contado.round(),
          lido: i.lido.round(),
        ),
    ];
  }

  Future<void> _corrigir(
    BuildContext context,
    ProdutoEsperado p,
    int lido,
  ) async {
    final bloc = context.read<PedidoEntradaBloc>();
    final r = await showModalBottomSheet<({bool corrigir, String? obs})>(
      context: context,
      isScrollControlled: true,
      builder: (_) => FolhaCorrigirContagem(produto: p, lido: lido),
    );
    if (r != null && r.corrigir) {
      bloc.add(
        PedidoEntradaCorrigiuContagem(
          p.id,
          lido.toDouble(),
          motivo: r.obs,
          origem: 'conferencia',
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final mobile = ehMobile(context);
    final textos = context.sivTextos;
    final conf = resumo.conferencia;
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(12),
            child: LeitorWidget(
              dataSource: dataSource,
              buscaDataSource: buscaDataSource,
              autofocus: !mobile,
              alturaLista: mobile ? 420 : 480,
              campoCodigoHint: 'Código de barras…',
              produtosEsperados: _esperados,
              onUltimoProdutoLido: (item) =>
                  onConferirCodigo(item.codigoDeBarras, 1),
              onRemoverLeitura: (p) => onConferirCodigo(p.codigoDeBarras, -1),
              onCorrigirContagem: (p, lido) => _corrigir(context, p, lido),
            ),
          ),
        ),
        RodapeAcaoEntrada(
          resumo: Text(
            '${qtd(conf.totalLido)} de ${qtd(conf.totalContado > 0 ? conf.totalContado : resumo.totalContado)} peças',
            style: textos.apoio,
          ),
          acao: BotaoPrincipalEntrada(
            key: const Key('conferir_continuar'),
            rotulo: 'CONTINUAR · REVISAR',
            onPressed: () => onIrParaPasso(4),
          ),
        ),
      ],
    );
  }
}

/// Bottom sheet "Corrigir contagem" (5g): contagem errada x ainda há peças.
class FolhaCorrigirContagem extends StatefulWidget {
  final ProdutoEsperado produto;
  final int lido;
  const FolhaCorrigirContagem({
    super.key,
    required this.produto,
    required this.lido,
  });

  @override
  State<FolhaCorrigirContagem> createState() => _FolhaCorrigirContagemState();
}

class _FolhaCorrigirContagemState extends State<FolhaCorrigirContagem> {
  bool _corrigir = true;
  final _obs = TextEditingController();

  @override
  void dispose() {
    _obs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textos = context.sivTextos;
    final p = widget.produto;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        16,
        16,
        16,
        16 + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Corrigir contagem', style: textos.secao),
            const SizedBox(height: 4),
            Text('${p.descricao} · ${p.grade}', style: textos.apoio),
            const SizedBox(height: 12),
            Row(
              children: [
                Text('CONTADO ', style: textos.rotulo),
                Text('${p.esperado}', style: textos.secao),
                const SizedBox(width: 24),
                Text('LIDO ', style: textos.rotulo),
                Text('${widget.lido}', style: textos.secao),
              ],
            ),
            const SizedBox(height: 8),
            RadioGroup<bool>(
              groupValue: _corrigir,
              onChanged: (v) => setState(() => _corrigir = v ?? true),
              child: Column(
                children: [
                  RadioListTile<bool>(
                    key: const Key('opcao_corrigir'),
                    value: true,
                    title: const Text('A contagem estava errada'),
                    subtitle: Text('Contado passa a ser ${widget.lido}.'),
                  ),
                  RadioListTile<bool>(
                    key: const Key('opcao_continuar'),
                    value: false,
                    title: const Text(
                      'A contagem está certa, ainda há peças para bipar',
                    ),
                    subtitle: Text('Mantém ${p.esperado}.'),
                  ),
                ],
              ),
            ),
            TextField(
              key: const Key('corrigir_obs'),
              controller: _obs,
              maxLength: 255,
              decoration: const InputDecoration(
                labelText: 'Observação (opcional)',
                counterText: '',
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                TextButton(
                  style: TextButton.styleFrom(minimumSize: const Size(44, 48)),
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar'),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: BotaoPrincipalEntrada(
                    key: const Key('corrigir_confirmar'),
                    rotulo: _corrigir ? 'CORRIGIR CONTAGEM' : 'CONTINUAR BIPANDO',
                    onPressed: () => Navigator.pop(
                      context,
                      (
                        corrigir: _corrigir,
                        obs: _obs.text.trim().isEmpty ? null : _obs.text.trim(),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
