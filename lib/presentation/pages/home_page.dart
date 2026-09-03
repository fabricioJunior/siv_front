import 'package:core/bloc.dart';
import 'package:core/injecoes.dart';
import 'package:core/presentation.dart';
import 'package:core/tema.dart';
import 'package:flutter/material.dart';
import 'package:siv_front/presentation/bloc/app_bloc/app_bloc.dart';
import 'package:siv_front/presentation/bloc/sync_data/sync_data_bloc.dart';

class _OperacaoDoDia {
  final String nome;
  final String descricao;
  final IconData icone;
  final String rota;
  final List<String> componentesNecessarios;

  const _OperacaoDoDia({
    required this.nome,
    required this.descricao,
    required this.icone,
    required this.rota,
    required this.componentesNecessarios,
  });

  bool get permitido =>
      componentesNecessarios.any(PermissaoPorNome.acessoPermitido);
}

const _operacoesDoDia = <_OperacaoDoDia>[
  _OperacaoDoDia(
    nome: 'Venda',
    descricao: 'Bipar produtos e fechar uma venda.',
    icone: Icons.shopping_cart_checkout_outlined,
    rota: '/venda',
    componentesNecessarios: ['PEDFC001', 'ROMFP001'],
  ),
  _OperacaoDoDia(
    nome: 'Pedidos',
    descricao: 'Acompanhar pedidos abertos e retiradas.',
    icone: Icons.receipt_long_outlined,
    rota: '/pedidos',
    componentesNecessarios: ['PEDFC001', 'PEDFM001'],
  ),
  _OperacaoDoDia(
    nome: 'Caixa',
    descricao: 'Abrir, sangrar ou fechar o caixa do terminal.',
    icone: Icons.point_of_sale_outlined,
    rota: '/fluxo_de_caixa',
    componentesNecessarios: ['FCXFP001', 'FCXFP002', 'FCXFL001'],
  ),
  _OperacaoDoDia(
    nome: 'Troca e devolução',
    descricao: 'Registrar troca ou devolução de um produto.',
    icone: Icons.assignment_return_outlined,
    rota: '/devolucao',
    componentesNecessarios: ['PEDFC001', 'ROMFP001'],
  ),
  _OperacaoDoDia(
    nome: 'Consignações',
    descricao: 'Abrir, acompanhar e acertar consignações.',
    icone: Icons.card_giftcard_outlined,
    rota: '/consignacoes',
    componentesNecessarios: ['CONFC001'],
  ),
  _OperacaoDoDia(
    nome: 'Pagamentos',
    descricao: 'Lançar pagamentos avulsos do dia.',
    icone: Icons.payments_outlined,
    rota: '/pagamentos_avulsos',
    componentesNecessarios: ['PAGFM001', 'PAGFP005'],
  ),
  _OperacaoDoDia(
    nome: 'Consultar produto',
    descricao: 'Ver preço e estoque de um produto.',
    icone: Icons.search_outlined,
    rota: '/consultar_produto',
    componentesNecessarios: ['PRDFL002'],
  ),
  _OperacaoDoDia(
    nome: 'Chamar entregador',
    descricao: 'Solicitar entregador pra um pedido pronto.',
    icone: Icons.delivery_dining_outlined,
    rota: '/chamar_entregador',
    componentesNecessarios: ['ENTFM001'],
  ),
  _OperacaoDoDia(
    nome: 'Pessoas',
    descricao: 'Consultar ou cadastrar clientes.',
    icone: Icons.people_outline,
    rota: '/pessoas',
    componentesNecessarios: ['PESFC001', 'PESFM001'],
  ),
];

/// Painel inicial. A navegação principal do app vive no menu lateral fixo
/// (ver `AppShell`) -- esta tela mostra o resumo do dia e as operações mais
/// usadas, filtradas por permissão.
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      sl<SyncDataBloc>().add(
        const SyncDataSolicitouSincronizacao(origem: SyncDataOrigem.home),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppBloc, AppState>(
      bloc: sl<AppBloc>(),
      builder: (context, appState) {
        final operacoesPermitidas = _operacoesDoDia
            .where((op) => op.permitido)
            .toList();

        return ListView(
          padding: const EdgeInsets.all(SivDimensoes.paginaHorizontal),
          children: [
            _faixaDeDestaque(context, appState),
            const SizedBox(height: SivDimensoes.gapCards),
            _indicadores(context),
            const SizedBox(height: SivDimensoes.gapCards * 1.5),
            Text('Operações do dia', style: context.sivTextos.secao),
            const SizedBox(height: 12),
            _gridDeOperacoes(context, operacoesPermitidas),
          ],
        );
      },
    );
  }

  Widget _faixaDeDestaque(BuildContext context, AppState appState) {
    final cores = context.sivColors;
    final textos = context.sivTextos;
    final nome = appState.usuarioDaSessao?.nome ?? 'Usuário';
    final primeiroNome = nome.split(' ').first;
    final caixaAberto = appState.caixaIdDaSessao != null;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: cores.acoEscuro,
        borderRadius: BorderRadius.circular(SivDimensoes.raio),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Bora, $primeiroNome',
            style: textos.titulo.copyWith(color: cores.textoSobreEscuroTitulo),
          ),
          const SizedBox(height: 6),
          Text(
            caixaAberto
                ? 'Caixa aberto neste terminal.'
                : 'Caixa fechado neste terminal.',
            style: textos.corpo.copyWith(color: cores.textoSobreEscuroApoio),
          ),
          // TODO: linha de contexto ("N pedidos aguardam retirada hoje") sem
          // fonte de dado hoje -- nenhum bloc/estado atual expõe contagem de
          // pedidos aguardando retirada.
          const SizedBox(height: 20),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _acaoRapida(
                context,
                texto: 'Iniciar venda',
                icone: Icons.shopping_cart_checkout_outlined,
                primaria: true,
                onTap: () => Navigator.of(context).pushNamed('/venda'),
              ),
              _acaoRapida(
                context,
                texto: 'Sangria',
                icone: Icons.arrow_upward_outlined,
                onTap: () => Navigator.of(context).pushNamed('/sangrias'),
              ),
              _acaoRapida(
                context,
                texto: 'Consultar produto',
                icone: Icons.search_outlined,
                onTap: () =>
                    Navigator.of(context).pushNamed('/consultar_produto'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _acaoRapida(
    BuildContext context, {
    required String texto,
    required IconData icone,
    required VoidCallback onTap,
    bool primaria = false,
  }) {
    final cores = context.sivColors;
    final textos = context.sivTextos;

    if (primaria) {
      return FilledButton.icon(
        onPressed: onTap,
        style: FilledButton.styleFrom(
          backgroundColor: cores.ceu,
          foregroundColor: cores.acoEscuro,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(SivDimensoes.raio),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        ),
        icon: Icon(icone, size: 18),
        label: Text(texto, style: textos.rotulo.copyWith(fontSize: 13)),
      );
    }

    return OutlinedButton.icon(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        foregroundColor: cores.textoSobreEscuroTitulo,
        side: BorderSide(
          color: cores.textoSobreEscuroTerciario.withValues(alpha: 0.4),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(SivDimensoes.raio),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      ),
      icon: Icon(icone, size: 18),
      label: Text(texto, style: textos.rotulo.copyWith(fontSize: 13)),
    );
  }

  Widget _indicadores(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final colunas = constraints.maxWidth >= 700 ? 4 : 2;
        return GridView.count(
          crossAxisCount: colunas,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: SivDimensoes.gapCards,
          crossAxisSpacing: SivDimensoes.gapCards,
          childAspectRatio: 1.9,
          children: [
            _indicadorCard(context, titulo: 'Vendido hoje', valor: '—'),
            _indicadorCard(context, titulo: 'Ticket médio', valor: '—'),
            _indicadorCard(context, titulo: 'Pedidos abertos', valor: '—'),
            _indicadorSincronizacao(context),
          ],
        );
      },
    );
  }

  Widget _indicadorCard(
    BuildContext context, {
    required String titulo,
    required String valor,
  }) {
    final cores = context.sivColors;
    final textos = context.sivTextos;

    // TODO: "vendido hoje" (com comparativo), "ticket médio" e "pedidos
    // abertos" não têm fonte de dado no AppState/blocs atuais -- ligar
    // quando existir um use case/bloc de indicadores do dia.
    return SivCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(titulo, style: textos.apoio.copyWith(color: cores.textoApoio)),
          const SizedBox(height: 6),
          Text(valor, style: textos.valor),
        ],
      ),
    );
  }

  Widget _indicadorSincronizacao(BuildContext context) {
    final cores = context.sivColors;
    final textos = context.sivTextos;

    return BlocBuilder<SyncDataBloc, SyncDataState>(
      bloc: sl<SyncDataBloc>(),
      builder: (context, syncState) {
        final finalizadoEm = syncState.finalizadoEm;
        final valor = finalizadoEm == null
            ? '—'
            : '${finalizadoEm.hour.toString().padLeft(2, '0')}:${finalizadoEm.minute.toString().padLeft(2, '0')}';

        return SivCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Última sincronização',
                style: textos.apoio.copyWith(color: cores.textoApoio),
              ),
              const SizedBox(height: 6),
              Text(valor, style: textos.valor),
            ],
          ),
        );
      },
    );
  }

  Widget _gridDeOperacoes(
    BuildContext context,
    List<_OperacaoDoDia> operacoes,
  ) {
    if (operacoes.isEmpty) {
      final cores = context.sivColors;
      return Text(
        'Nenhuma operação liberada pra este usuário.',
        style: context.sivTextos.corpo.copyWith(color: cores.textoApoio),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final colunas = constraints.maxWidth >= 1000
            ? 4
            : constraints.maxWidth >= 640
            ? 2
            : 1;

        return GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: colunas,
            mainAxisSpacing: SivDimensoes.gapCards,
            crossAxisSpacing: SivDimensoes.gapCards,
            childAspectRatio: 1.5,
          ),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: operacoes.length,
          itemBuilder: (context, index) {
            return _operacaoCard(context, index + 1, operacoes[index]);
          },
        );
      },
    );
  }

  Widget _operacaoCard(
    BuildContext context,
    int numero,
    _OperacaoDoDia operacao,
  ) {
    final cores = context.sivColors;
    final textos = context.sivTextos;

    return Material(
      color: cores.superficie,
      borderRadius: BorderRadius.circular(SivDimensoes.raio),
      child: InkWell(
        key: Key('home_operacao_${operacao.rota}'),
        borderRadius: BorderRadius.circular(SivDimensoes.raio),
        onTap: () => Navigator.of(context).pushNamed(operacao.rota),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(SivDimensoes.raio),
            border: Border.all(color: cores.hairline),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    numero.toString().padLeft(2, '0'),
                    style: textos.secao.copyWith(color: cores.aco),
                  ),
                  const Spacer(),
                  Icon(operacao.icone, color: cores.acoEscuro),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                operacao.nome,
                style: textos.corpo.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              Text(
                operacao.descricao,
                style: textos.apoio.copyWith(color: cores.textoApoio),
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
