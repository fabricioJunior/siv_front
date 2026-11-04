import 'package:core/bloc.dart';
import 'package:core/seletores.dart';
import 'package:flutter/material.dart';
import 'package:leitor_camera/leitor_camera.dart';
import 'package:produtos/models.dart';
import 'package:produtos/presentation.dart';
import 'package:produtos/presentantion/widgets/consulta/consulta_detalhe.dart';
import 'package:produtos/presentantion/widgets/consulta/consulta_formato.dart';
import 'package:produtos/presentantion/widgets/consulta/consulta_lista.dart';
import 'package:produtos/presentantion/widgets/consulta/filtro_variacao_consulta.dart';
import 'package:produtos/presentantion/widgets/consulta/ler_codigo_dialog.dart';

const rotaDetalheConsultarProduto = '/consultar_produto/detalhe';

/// Lista de consulta (e detalhe lado a lado no desktop). O [ConsultarProdutoBloc] vem de
/// cima das rotas de lista e detalhe: voltar do detalhe nunca reinicia a consulta.
class ConsultarProdutoPage extends StatefulWidget {
  final SeletorWidget tabelaDePrecoSeletor;

  const ConsultarProdutoPage({super.key, required this.tabelaDePrecoSeletor});

  @override
  State<ConsultarProdutoPage> createState() => _ConsultarProdutoPageState();
}

class _ConsultarProdutoPageState extends State<ConsultarProdutoPage> {
  late final ConsultarProdutoBloc _bloc = context.read<ConsultarProdutoBloc>();
  late final _busca = TextEditingController(text: _bloc.state.busca);

  @override
  void dispose() {
    _busca.dispose();
    _bloc.add(ConsultarProdutoLimpou());
    super.dispose();
  }

  bool _desktop(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= larguraDesktopConsulta;

  void _abrirDetalhe() => Navigator.of(context).pushNamed(rotaDetalheConsultarProduto);

  Future<void> _escanear() async {
    final codigo = await LeitorCamera.escanear(context);
    if (codigo != null) _bloc.add(ConsultarProdutoCodigoLido(codigo));
  }

  void _aoLer(BuildContext context, ConsultarProdutoState state) {
    if (_desktop(context)) return;
    final l = state.leitura;
    if (l == null) return;
    if (l.encontrada) {
      _abrirDetalhe();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Código "${l.codigo}" não encontrado.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final desktop = _desktop(context);
    final lista = Column(
      children: [
        _Topo(busca: _busca, tabelaDePrecoSeletor: widget.tabelaDePrecoSeletor, desktop: desktop),
        const Divider(height: 1),
        Expanded(
          child: ConsultaLista(
            onAbrir: (item) {
              _bloc.add(ConsultarProdutoReferenciaSelecionada(item.referenciaId));
              if (!desktop) _abrirDetalhe();
            },
          ),
        ),
      ],
    );

    return BlocListener<ConsultarProdutoBloc, ConsultarProdutoState>(
      listenWhen: (a, b) => a.leitura != b.leitura && b.leitura != null,
      listener: _aoLer,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Consultar produto'),
          actions: [
            if (!desktop)
              IconButton(
                tooltip: 'Ler código de barras',
                icon: const Icon(Icons.qr_code_scanner),
                onPressed: _escanear,
              ),
          ],
        ),
        body: desktop
            ? Row(
                children: [
                  SizedBox(width: 420, child: lista),
                  const VerticalDivider(width: 1),
                  const Expanded(child: ConsultaDetalhe()),
                ],
              )
            : lista,
      ),
    );
  }
}

/// Rota de detalhe no mobile.
class ConsultarProdutoDetalhePage extends StatelessWidget {
  const ConsultarProdutoDetalhePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Produto')),
      body: const ConsultaDetalhe(),
    );
  }
}

class _Topo extends StatelessWidget {
  final TextEditingController busca;
  final SeletorWidget tabelaDePrecoSeletor;
  final bool desktop;

  const _Topo({required this.busca, required this.tabelaDePrecoSeletor, required this.desktop});

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<ConsultarProdutoBloc>();
    final state = context.watch<ConsultarProdutoBloc>().state;
    final nFiltros = state.cores.length + state.tamanhos.length + state.estampas.length;

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: busca,
                  decoration: const InputDecoration(
                    hintText: 'Nome ou código da referência',
                    prefixIcon: Icon(Icons.search),
                  ),
                  onChanged: (v) => bloc.add(ConsultarProdutoBuscaAlterada(v)),
                ),
              ),
              if (desktop) ...[
                const SizedBox(width: 8),
                FilledButton.icon(
                  onPressed: () => LerCodigoDialog.show(context),
                  icon: const Icon(Icons.qr_code_scanner),
                  label: const Text('Bipar código'),
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
          tabelaDePrecoSeletor(
            SeletorData(
              itemsSelecionadosInicial: state.tabelaDePreco,
              onChanged: (itens) => bloc.add(ConsultarProdutoTabelaDePrecoAlterada(itens)),
            ),
          ),
          if (desktop)
            ExpansionTile(
              tilePadding: EdgeInsets.zero,
              title: Text(nFiltros == 0 ? 'Filtros' : 'Filtros ($nFiltros)'),
              children: [
                CorSeletor(
                  modo: CorSeletorModo.multipla,
                  titulo: 'Cor',
                  coresSelecionadasIniciais: state.cores,
                  onCorChanged: (v) => bloc.add(ConsultarProdutoFiltrosAlterados(cores: v)),
                ),
                TamanhoSeletor(
                  modo: TamanhoSeletorModo.multipla,
                  titulo: 'Tamanho',
                  tamanhosSelecionadosIniciais: state.tamanhos,
                  onTamanhosChanged: (v) => bloc.add(ConsultarProdutoFiltrosAlterados(tamanhos: v)),
                ),
                EstampaSeletor(
                  modo: EstampaSeletorModo.multipla,
                  estampasSelecionadasIniciais: state.estampas,
                  onEstampasChanged: (v) => bloc.add(ConsultarProdutoFiltrosAlterados(estampas: v)),
                ),
              ],
            )
          else ...[
            const SizedBox(height: 8),
            FiltroVariacaoConsulta<Cor, CoresBloc, CoresState>(
              chave: 'cor',
              rotulo: 'COR',
              botao: '+ cor',
              titulo: 'Cores',
              singular: 'cor',
              plural: 'cores',
              selecionados: state.cores,
              onChanged: (v) => bloc.add(ConsultarProdutoFiltrosAlterados(cores: v)),
              id: (c) => c.id ?? 0,
              nome: (c) => c.nome,
              carregar: (b) => b.add(CoresIniciou()),
              itens: (s) => s.cores.where((c) => !(c.inativo ?? false)).toList(),
              carregando: (s) => s is CoresCarregarEmProgresso,
              falhou: (s) => s is CoresCarregarFalha,
            ),
            FiltroVariacaoConsulta<Estampa, EstampasBloc, EstampasState>(
              chave: 'estampa',
              rotulo: 'ESTAMPA',
              botao: '+ estampa',
              titulo: 'Estampas',
              singular: 'estampa',
              plural: 'estampas',
              selecionados: state.estampas,
              onChanged: (v) => bloc.add(ConsultarProdutoFiltrosAlterados(estampas: v)),
              id: (e) => e.id ?? 0,
              nome: (e) => e.nome,
              carregar: (b) => b.add(EstampasIniciou(inativo: false)),
              itens: (s) => s.estampas.where((e) => !e.inativo).toList(),
              carregando: (s) => s is EstampasCarregarEmProgresso,
              falhou: (s) => s is EstampasCarregarFalha,
            ),
            FiltroVariacaoConsulta<Tamanho, TamanhosBloc, TamanhosState>(
              chave: 'tam',
              rotulo: 'TAMANHO',
              botao: '+ tam.',
              titulo: 'Tamanhos',
              singular: 'tamanho',
              plural: 'tamanhos',
              feminino: false,
              selecionados: state.tamanhos,
              onChanged: (v) => bloc.add(ConsultarProdutoFiltrosAlterados(tamanhos: v)),
              id: (t) => t.id ?? 0,
              nome: (t) => t.nome,
              carregar: (b) => b.add(TamanhosIniciou(inativo: false)),
              itens: (s) => s.tamanhos.where((t) => !t.inativo).toList(),
              carregando: (s) => s is TamanhosCarregarEmProgresso,
              falhou: (s) => s is TamanhosCarregarFalha,
            ),
          ],
        ],
      ),
    );
  }
}
