import 'package:autenticacao/models.dart';
import 'package:autenticacao/presentation/utils/fluxos_de_permissao.dart';
import 'package:comercial/presentation.dart' show comercialAcordeaoItens;
import 'package:core/bloc.dart';
import 'package:core/injecoes.dart';
import 'package:core/presentation.dart';
import 'package:core/tema.dart';
import 'package:estoque/presentation.dart' show estoqueAcordeaoItens;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:siv_front/presentation/bloc/app_bloc/app_bloc.dart';
import 'package:siv_front/presentation/pages/administracao_menu_page.dart'
    show administracaoAcordeaoItens;
import 'package:siv_front/presentation/pages/relatorios_menu_page.dart'
    show relatoriosAcordeaoItens;

/// Casca de navegação: menu lateral fixo + barra de título, vivendo acima
/// do [Navigator] (montada uma única vez em `MaterialApp.builder`). Trocar
/// de tela não reconstrói o menu nem perde o estado de rolagem dele.
///
/// Rotas fora do fluxo autenticado principal (login, splash, seleção de
/// empresa/terminal, config. de dispositivo) não recebem a casca --
/// aparecem em tela cheia, como hoje.
class AppShell extends StatelessWidget {
  final ValueListenable<String?> rotaAtual;
  final Widget child;

  /// Navegação do menu/barra de título usa esta key (não `Navigator.of(context)`
  /// -- [AppShell] embrulha o [Navigator] em vez de descender dele, então
  /// não existe um Navigator ancestor pra achar a partir do context daqui).
  final GlobalKey<NavigatorState> navigatorKey;

  const AppShell({
    super.key,
    required this.rotaAtual,
    required this.child,
    required this.navigatorKey,
  });

  static const _rotasSemCasca = {
    '/',
    '/login',
    '/selecionar_empresa',
    '/selecionar_terminal',
    '/configuracao_dispositivo',
  };

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppBloc, AppState>(
      bloc: sl<AppBloc>(),
      builder: (context, appState) {
        if (appState.statusAutenticacao != StatusAutenticacao.autenticado) {
          return child;
        }

        return ValueListenableBuilder<String?>(
          valueListenable: rotaAtual,
          builder: (context, rota, _) {
            if (rota == null || _rotasSemCasca.contains(rota)) {
              return child;
            }

            return _AppShellCasca(
              rotaAtual: rota,
              appState: appState,
              navigatorKey: navigatorKey,
              child: child,
            );
          },
        );
      },
    );
  }
}

/// Filha de um item de topo com acordeão (ver [_ItemDeNavegacao.filhos]).
class _ItemFilhoNav {
  final String label;
  final String rota;
  final List<String> componentesNecessarios;
  final String? grupo;

  const _ItemFilhoNav({
    required this.label,
    required this.rota,
    this.componentesNecessarios = const [],
    this.grupo,
  });

  bool get permitido =>
      componentesNecessarios.isEmpty ||
      componentesNecessarios.any(PermissaoPorNome.acessoPermitido);
}

_ItemFilhoNav _deAcordeaoFilho(SivMenuAcordeaoFilho filho) => _ItemFilhoNav(
      label: filho.label,
      rota: filho.rota,
      componentesNecessarios:
          filho.componente == null ? const [] : [filho.componente!],
      grupo: filho.grupo,
    );

List<String> _uniaoComponentes(List<_ItemFilhoNav> filhos) =>
    {for (final f in filhos) ...f.componentesNecessarios}.toList();

class _ItemDeNavegacao {
  final String label;
  final IconData icone;

  /// Rota de destino -- `null` quando [filhos] não é vazio (item-acordeão,
  /// não navega sozinho, só expande/recolhe).
  final String? rota;
  final List<String> componentesNecessarios;
  final List<_ItemFilhoNav> filhos;

  const _ItemDeNavegacao({
    required this.label,
    required this.icone,
    this.rota,
    this.componentesNecessarios = const [],
    this.filhos = const [],
  });

  /// Chave estável de seleção/expansão -- a própria rota quando existe,
  /// senão um id sintético a partir do label (item-acordeão sem rota).
  String get chave => rota ?? 'acordeao:$label';

  bool get eAcordeao => filhos.isNotEmpty;

  bool get exigePermissao => componentesNecessarios.isNotEmpty;

  bool get permitido =>
      !exigePermissao ||
      componentesNecessarios.any(PermissaoPorNome.acessoPermitido);
}

final _itensComercialFilhos = comercialAcordeaoItens.map(_deAcordeaoFilho).toList();
final _itensEstoqueFilhos = estoqueAcordeaoItens.map(_deAcordeaoFilho).toList();
final _itensAdministracaoFilhos =
    administracaoAcordeaoItens.map(_deAcordeaoFilho).toList();
final _itensRelatoriosFilhos = relatoriosAcordeaoItens.map(_deAcordeaoFilho).toList();

final _itensEcommerceFilhos = <_ItemFilhoNav>[
  const _ItemFilhoNav(
    label: 'Pedidos do e-commerce',
    rota: '/ecommerce_pedidos',
    componentesNecessarios: ['PEDFC001'],
  ),
  const _ItemFilhoNav(
    label: 'Promoções do e-commerce',
    rota: '/ecommerce_promocoes',
    componentesNecessarios: ['PROMFC001'],
  ),
  const _ItemFilhoNav(
    label: 'Configurações',
    rota: '/configuracao_ecommerce',
    componentesNecessarios: ['ECOFM001'],
  ),
];

final _itensDiaADia = <_ItemDeNavegacao>[
  const _ItemDeNavegacao(label: 'Início', icone: Icons.home_outlined, rota: '/home'),
  _ItemDeNavegacao(
    label: 'Venda',
    icone: Icons.shopping_cart_checkout_outlined,
    rota: '/venda',
    componentesNecessarios: componentesPorFluxo['Vendas']!,
  ),
  _ItemDeNavegacao(
    label: 'Caixa',
    icone: Icons.point_of_sale_outlined,
    rota: '/fluxo_de_caixa',
    componentesNecessarios: componentesPorFluxo['Caixa']!,
  ),
  const _ItemDeNavegacao(
    label: 'Pessoas',
    icone: Icons.people_outline,
    rota: '/pessoas',
    componentesNecessarios: ['PESFM001', 'PESFC001', 'PESFC002', 'PESFC003'],
  ),
  _ItemDeNavegacao(
    label: 'Comercial',
    icone: Icons.local_mall_outlined,
    // Item-acordeão (venda, devolução, pedidos, romaneios, histórico de
    // vendas, consignações, promoções, cupons, minhas listas) -- e-commerce
    // saiu daqui, virou item de topo próprio.
    componentesNecessarios: _uniaoComponentes(_itensComercialFilhos),
    filhos: _itensComercialFilhos,
  ),
];

final _itensGestao = <_ItemDeNavegacao>[
  _ItemDeNavegacao(
    label: 'Produtos',
    icone: Icons.checkroom_outlined,
    rota: '/menu_produtos',
    componentesNecessarios: componentesPorFluxo['Produtos']!,
  ),
  _ItemDeNavegacao(
    label: 'E-commerce',
    icone: Icons.storefront_outlined,
    componentesNecessarios: _uniaoComponentes(_itensEcommerceFilhos),
    filhos: _itensEcommerceFilhos,
  ),
  _ItemDeNavegacao(
    label: 'Estoque',
    icone: Icons.inventory_2_outlined,
    // Item-acordeão (entrada/saída manual, histórico, balanço, consulta de
    // saldo).
    componentesNecessarios: _uniaoComponentes(_itensEstoqueFilhos),
    filhos: _itensEstoqueFilhos,
  ),
  _ItemDeNavegacao(
    label: 'Notas fiscais',
    icone: Icons.description_outlined,
    rota: '/documentos_fiscais',
    componentesNecessarios: componentesPorFluxo['Fiscal']!,
  ),
  _ItemDeNavegacao(
    label: 'Relatórios',
    icone: Icons.bar_chart_outlined,
    componentesNecessarios: _uniaoComponentes(_itensRelatoriosFilhos),
    filhos: _itensRelatoriosFilhos,
  ),
];

final _itensSistema = <_ItemDeNavegacao>[
  _ItemDeNavegacao(
    label: 'Administração',
    icone: Icons.admin_panel_settings_outlined,
    componentesNecessarios: _uniaoComponentes(_itensAdministracaoFilhos),
    filhos: _itensAdministracaoFilhos,
  ),
  const _ItemDeNavegacao(
    label: 'Sincronização',
    icone: Icons.sync,
    rota: '/sincronizacao',
  ),
];

class _AppShellCasca extends StatefulWidget {
  final String rotaAtual;
  final AppState appState;
  final Widget child;
  final GlobalKey<NavigatorState> navigatorKey;

  const _AppShellCasca({
    required this.rotaAtual,
    required this.appState,
    required this.child,
    required this.navigatorKey,
  });

  @override
  State<_AppShellCasca> createState() => _AppShellCascaState();
}

class _AppShellCascaState extends State<_AppShellCasca> {
  // null = segue o breakpoint automático de largura (SivScaffold decide).
  // Setado (true/false) assim que o usuário mexe no botão de colapso --
  // vale pra sessão inteira a partir daí, sobrepõe o automático.
  bool? _colapsoManual;

  final Set<String> _expandidos = {};

  static final _itensComAcordeao = [
    ..._itensDiaADia,
    ..._itensGestao,
    ..._itensSistema,
  ].where((item) => item.eAcordeao).toList();

  static final _mapaFilhoParaChavePai = <String, String>{
    for (final pai in _itensComAcordeao)
      for (final filho in pai.filhos) filho.rota: pai.chave,
  };

  void _toggleColapso(double larguraAtual) {
    final autoAtual = larguraAtual < SivDimensoes.breakpointMenuRail;
    final atual = _colapsoManual ?? autoAtual;
    setState(() => _colapsoManual = !atual);
  }

  void _alternarExpandido(String chave) {
    setState(() {
      if (_expandidos.contains(chave)) {
        _expandidos.remove(chave);
      } else {
        _expandidos.add(chave);
        // Rail não tem onde mostrar filhas -- reabre o menu inteiro pra
        // caber o acordeão que acabou de abrir.
        if (_colapsoManual == true) _colapsoManual = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final itensTodos = [..._itensDiaADia, ..._itensGestao, ..._itensSistema];
    final chavePaiAtiva = _mapaFilhoParaChavePai[widget.rotaAtual];

    // Módulo correspondente à rota ativa abre automaticamente -- mutação
    // direta de estado durante build (sem setState), efetiva já neste frame.
    if (chavePaiAtiva != null) _expandidos.add(chavePaiAtiva);

    final itemAtivoTopo =
        itensTodos.where((item) => item.rota == widget.rotaAtual).toList();
    final paiAtivo =
        chavePaiAtiva == null
            ? null
            : itensTodos.where((item) => item.chave == chavePaiAtiva).toList();

    final tituloAtivo = itemAtivoTopo.isNotEmpty
        ? itemAtivoTopo.first.label
        : (paiAtivo != null && paiAtivo.isNotEmpty ? paiAtivo.first.label : null);

    return SivScaffold(
      colapsoMenuForcado: _colapsoManual,
      onToggleColapsoMenu: () =>
          _toggleColapso(MediaQuery.sizeOf(context).width),
      floatingActionButton: ValueListenableBuilder<Widget?>(
        valueListenable: SivPageFab.notifier,
        builder: (context, fab, _) => fab ?? const SizedBox.shrink(),
      ), // SivScaffold repassa direto ao Scaffold.floatingActionButton --
      // SizedBox.shrink() (sem tamanho, sem hit-test) equivale a "nenhum
      // FAB" visualmente, mas mantém o slot como Widget não-nulo (evita
      // remontar o subtree do ValueListenableBuilder a cada troca null/
      // widget, que já causava um pequeno flash ao navegar entre páginas).
      secoesMenu: [
        SivMenuLateralSecao(
          titulo: 'DIA A DIA',
          itens: _itensDiaADia
              .where((item) => item.permitido)
              .map((item) => _mapearItem(item, chavePaiAtiva))
              .toList(),
        ),
        SivMenuLateralSecao(
          titulo: 'GESTÃO',
          itens: _itensGestao
              .where((item) => item.permitido)
              .map((item) => _mapearItem(item, chavePaiAtiva))
              .toList(),
        ),
        SivMenuLateralSecao(
          titulo: 'SISTEMA',
          itens: _itensSistema
              .where((item) => item.permitido)
              .map((item) => _mapearItem(item, chavePaiAtiva))
              .toList(),
        ),
      ],
      rodapeMenu: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _BarraTituloInfo(appState: widget.appState, navigatorKey: widget.navigatorKey),
          _RodapeMenu(appState: widget.appState, navigatorKey: widget.navigatorKey),
        ],
      ),
      // Rotas sem label no menu (ex: telas abertas fora da navegação
      // principal) renderizam o próprio título -- ver [SivTituloPagina] --
      // então não duplica nada aqui.
      corpo: tituloAtivo == null
          ? widget.child
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SivTituloPagina(titulo: tituloAtivo),
                Expanded(child: widget.child),
              ],
            ),
    );
  }

  SivMenuLateralItem _mapearItem(_ItemDeNavegacao item, String? chavePaiAtiva) {
    if (item.eAcordeao) {
      final expandido = _expandidos.contains(item.chave);
      return SivMenuLateralItem(
        label: item.label,
        icone: item.icone,
        selecionado: item.chave == chavePaiAtiva && !expandido,
        expandido: expandido,
        onToggleExpandir: () => _alternarExpandido(item.chave),
        filhos: item.filhos
            .where((filho) => filho.permitido)
            .map(
              (filho) => SivMenuLateralFilho(
                label: filho.label,
                selecionado: filho.rota == widget.rotaAtual,
                onTap: filho.rota == widget.rotaAtual
                    ? null
                    : () => widget.navigatorKey.currentState?.pushNamed(filho.rota),
              ),
            )
            .toList(),
      );
    }

    return SivMenuLateralItem(
      label: item.label,
      icone: item.icone,
      selecionado: item.rota == widget.rotaAtual,
      onTap: item.rota == widget.rotaAtual
          ? null
          : () => widget.navigatorKey.currentState?.pushNamed(item.rota!),
    );
  }
}

class _RodapeMenu extends StatelessWidget {
  final AppState appState;
  final GlobalKey<NavigatorState> navigatorKey;

  const _RodapeMenu({required this.appState, required this.navigatorKey});

  @override
  Widget build(BuildContext context) {
    final cores = context.sivColors;
    final textos = context.sivTextos;
    final nome = appState.usuarioDaSessao?.nome ?? 'Usuário';
    final inicial = nome.isNotEmpty ? nome[0].toUpperCase() : 'U';
    // TODO: grupo de acesso (papel) do usuário não está disponível no
    // AppState hoje -- usa o tipo de usuário (Padrão/Administrador/Sysadmin)
    // como aproximação até a sessão carregar o grupo de acesso vinculado.
    final papel = appState.usuarioDaSessao?.tipo.nome ?? '';

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: cores.textoSobreEscuroTerciario.withValues(alpha: 0.2),
          ),
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: cores.aco,
            child: Text(
              inicial,
              style: textos.rotulo.copyWith(
                color: cores.textoSobreEscuroTitulo,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  nome,
                  overflow: TextOverflow.ellipsis,
                  style: textos.corpo.copyWith(
                    color: cores.textoSobreEscuroTitulo,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (papel.isNotEmpty)
                  Text(
                    papel,
                    overflow: TextOverflow.ellipsis,
                    style: textos.apoio.copyWith(
                      color: cores.textoSobreEscuroApoio,
                    ),
                  ),
              ],
            ),
          ),
          IconButton(
            key: const Key('sair_button'),
            tooltip: 'Sair',
            icon: Icon(
              Icons.logout,
              size: 18,
              color: cores.textoSobreEscuroApoio,
            ),
            onPressed: () => _confirmarSaida(),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmarSaida() async {
    final navigatorContext = navigatorKey.currentContext;
    if (navigatorContext == null) {
      return;
    }

    final confirmar = await showDialog<bool>(
      context: navigatorContext,
      builder: (ctx) => AlertDialog(
        title: const Text('Sair da conta'),
        content: const Text('Deseja encerrar a sessão atual?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Sair'),
          ),
        ],
      ),
    );
    if (confirmar == true && navigatorContext.mounted) {
      sl<AppBloc>().add(AppDesautenticou());
    }
  }
}

class _BarraTituloInfo extends StatelessWidget {
  final AppState appState;
  final GlobalKey<NavigatorState> navigatorKey;

  const _BarraTituloInfo({required this.appState, required this.navigatorKey});

  @override
  Widget build(BuildContext context) {
    final cores = context.sivColors;
    final caixaAberto = appState.caixaIdDaSessao != null;

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: cores.textoSobreEscuroTerciario.withValues(alpha: 0.2),
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _ChipInfo(
            texto: appState.empresaDaSessao?.nome ?? 'Selecionar empresa',
            onTap: () => navigatorKey.currentState?.pushNamed(
              '/login',
              arguments: {'trocandoDeEmpresa': true},
            ),
          ),
          const SizedBox(height: 6),
          _ChipInfo(
            texto: appState.terminalDaSessao?.nome ?? 'Selecionar terminal',
            onTap: () => _trocarTerminal(context),
          ),
          const SizedBox(height: 6),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: caixaAberto ? cores.emAndamentoFundo : cores.falhaFundo,
              border: Border.all(
                color: caixaAberto ? cores.aco : cores.falhaBorda,
              ),
              borderRadius: BorderRadius.circular(SivDimensoes.raio),
            ),
            // TODO: valor em caixa (R$ x) não está disponível no AppState hoje
            // -- exibe só o status até a sessão carregar o saldo do caixa.
            child: Text(
              caixaAberto ? 'CAIXA ABERTO' : 'CAIXA FECHADO',
              style: context.sivTextos.rotulo.copyWith(
                color: cores.textoPrincipal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _trocarTerminal(BuildContext context) async {
    if (appState.usuarioDaSessao == null || appState.empresaDaSessao == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Usuário ou empresa da sessão não encontrados.'),
        ),
      );
      return;
    }

    final terminaisDaEmpresa = appState.terminaisDaEmpresaDaSessao;
    if (terminaisDaEmpresa.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nenhum terminal disponível para a empresa da sessão.'),
        ),
      );
      return;
    }

    final resultado = await navigatorKey.currentState?.pushNamed(
      '/selecionar_terminal',
      arguments: {'terminais': terminaisDaEmpresa},
    );

    // NAO checar context.mounted aqui -- '/selecionar_terminal' esta em
    // _rotasSemCasca, entao o AppShell desmonta este widget (e o context
    // capturado no onTap) enquanto a rota fica em foco. Ao resolver o
    // pushNamed o context sempre chega desmontado, e o guard antigo
    // descartava a selecao em silencio 100% das vezes. Despachar o evento
    // no AppBloc (singleton) nao depende de context nenhum.
    if (resultado is! Map) {
      return;
    }

    final idTerminal = resultado['idTerminal'];
    final idEmpresa = resultado['idEmpresa'];
    final nomeTerminal = resultado['nomeTerminal'];

    if (idTerminal is! int || idEmpresa is! int || nomeTerminal is! String) {
      return;
    }

    sl<AppBloc>().add(
      AppSelecionouTerminalDaSessao(
        terminal: _TerminalSelecionado(
          id: idTerminal,
          idEmpresa: idEmpresa,
          nome: nomeTerminal,
        ),
      ),
    );
  }
}

class _ChipInfo extends StatelessWidget {
  final String texto;
  final VoidCallback onTap;

  const _ChipInfo({required this.texto, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cores = context.sivColors;
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(SivDimensoes.raio),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          border: Border.all(
            color: cores.textoSobreEscuroTerciario.withValues(alpha: 0.3),
          ),
          borderRadius: BorderRadius.circular(SivDimensoes.raio),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              child: Text(
                texto,
                overflow: TextOverflow.ellipsis,
                style: context.sivTextos.apoio.copyWith(
                  color: cores.textoSobreEscuroApoio,
                ),
              ),
            ),
            const SizedBox(width: 4),
            Icon(Icons.swap_horiz,
                size: 14, color: cores.textoSobreEscuroApoio),
          ],
        ),
      ),
      ),
    );
  }
}

class _TerminalSelecionado implements TerminalDoUsuario {
  @override
  final int id;
  @override
  final int idEmpresa;
  @override
  final String nome;

  _TerminalSelecionado({
    required this.id,
    required this.idEmpresa,
    required this.nome,
  });

  @override
  List<Object?> get props => [id, idEmpresa, nome];

  @override
  bool? get stringify => true;
}
