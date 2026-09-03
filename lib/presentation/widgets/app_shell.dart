import 'package:autenticacao/models.dart';
import 'package:autenticacao/presentation/utils/fluxos_de_permissao.dart';
import 'package:core/bloc.dart';
import 'package:core/injecoes.dart';
import 'package:core/presentation.dart';
import 'package:core/tema.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:siv_front/presentation/bloc/app_bloc/app_bloc.dart';

/// Componentes que liberam o item "Relatórios" do menu -- mais amplo que
/// [componentesPorFluxo]['Relatórios'] porque a página agregadora reúne
/// relatórios de vendas, clientes, estoque e caixa.
const _componentesRelatorios = [
  'RELFC001',
  'RELFC002',
  'RELFC003',
  'RELFC004',
  'RELFC006',
  'RELFC007',
  'RELFC008',
  'RELFC009',
  'RELFC010',
  'FCXFP008',
];

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

  const AppShell({super.key, required this.rotaAtual, required this.child});

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

            return _AppShellCasca(rotaAtual: rota, appState: appState, child: child);
          },
        );
      },
    );
  }
}

class _ItemDeNavegacao {
  final String label;
  final IconData icone;
  final String rota;
  final List<String> componentesNecessarios;

  const _ItemDeNavegacao({
    required this.label,
    required this.icone,
    required this.rota,
    this.componentesNecessarios = const [],
  });

  bool get exigePermissao => componentesNecessarios.isNotEmpty;

  bool get permitido =>
      !exigePermissao ||
      componentesNecessarios.any(PermissaoPorNome.acessoPermitido);
}

final _itensOperacao = <_ItemDeNavegacao>[
  _ItemDeNavegacao(label: 'Início', icone: Icons.home_outlined, rota: '/home'),
  _ItemDeNavegacao(
    label: 'Venda',
    icone: Icons.shopping_cart_checkout_outlined,
    rota: '/venda',
    componentesNecessarios: componentesPorFluxo['Vendas']!,
  ),
  _ItemDeNavegacao(
    label: 'Pedidos',
    icone: Icons.receipt_long_outlined,
    rota: '/pedidos',
    componentesNecessarios: componentesPorFluxo['Pedidos']!,
  ),
  _ItemDeNavegacao(
    label: 'Caixa',
    icone: Icons.point_of_sale_outlined,
    rota: '/fluxo_de_caixa',
    componentesNecessarios: componentesPorFluxo['Caixa']!,
  ),
  _ItemDeNavegacao(
    label: 'Estoque',
    icone: Icons.inventory_2_outlined,
    rota: '/estoque',
    componentesNecessarios: componentesPorFluxo['Estoque']!,
  ),
  _ItemDeNavegacao(
    label: 'Relatórios',
    icone: Icons.bar_chart_outlined,
    rota: '/relatorios',
    componentesNecessarios: _componentesRelatorios,
  ),
];

final _itensSistema = <_ItemDeNavegacao>[
  _ItemDeNavegacao(
    label: 'Administração',
    icone: Icons.admin_panel_settings_outlined,
    rota: '/administracao',
    componentesNecessarios: ['ADMFM001', 'ADMFM004', 'SYSFM001'],
  ),
  _ItemDeNavegacao(
    label: 'Sincronização',
    icone: Icons.sync,
    rota: '/sincronizacao',
  ),
];

class _AppShellCasca extends StatelessWidget {
  final String rotaAtual;
  final AppState appState;
  final Widget child;

  const _AppShellCasca({
    required this.rotaAtual,
    required this.appState,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final itensTodos = [..._itensOperacao, ..._itensSistema];
    final itemAtivo = itensTodos
        .where((item) => item.rota == rotaAtual)
        .toList();
    final tituloAtivo = itemAtivo.isNotEmpty ? itemAtivo.first.label : null;

    return SivScaffold(
      titulo: tituloAtivo ?? 'SIV',
      acoes: [_BarraTituloInfo(appState: appState)],
      secoesMenu: [
        SivMenuLateralSecao(
          titulo: 'OPERAÇÃO',
          itens: _itensOperacao
              .where((item) => item.permitido)
              .map((item) => _mapearItem(context, item))
              .toList(),
        ),
        SivMenuLateralSecao(
          titulo: 'SISTEMA',
          itens: _itensSistema
              .where((item) => item.permitido)
              .map((item) => _mapearItem(context, item))
              .toList(),
        ),
      ],
      rodapeMenu: _RodapeMenu(appState: appState),
      corpo: child,
    );
  }

  SivMenuLateralItem _mapearItem(BuildContext context, _ItemDeNavegacao item) {
    return SivMenuLateralItem(
      label: item.label,
      icone: item.icone,
      selecionado: item.rota == rotaAtual,
      onTap: item.rota == rotaAtual
          ? null
          : () => Navigator.of(context).pushNamed(item.rota),
    );
  }
}

class _RodapeMenu extends StatelessWidget {
  final AppState appState;

  const _RodapeMenu({required this.appState});

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
        border: Border(top: BorderSide(color: cores.textoSobreEscuroTerciario.withValues(alpha: 0.2))),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: cores.aco,
            child: Text(
              inicial,
              style: textos.rotulo.copyWith(color: cores.textoSobreEscuroTitulo),
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
                    style: textos.apoio.copyWith(color: cores.textoSobreEscuroApoio),
                  ),
              ],
            ),
          ),
          IconButton(
            key: const Key('sair_button'),
            tooltip: 'Sair',
            icon: Icon(Icons.logout, size: 18, color: cores.textoSobreEscuroApoio),
            onPressed: () => _confirmarSaida(context),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmarSaida(BuildContext context) async {
    final confirmar = await showDialog<bool>(
      context: context,
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
    if (confirmar == true && context.mounted) {
      sl<AppBloc>().add(AppDesautenticou());
    }
  }
}

class _BarraTituloInfo extends StatelessWidget {
  final AppState appState;

  const _BarraTituloInfo({required this.appState});

  @override
  Widget build(BuildContext context) {
    final cores = context.sivColors;
    final caixaAberto = appState.caixaIdDaSessao != null;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _ChipInfo(
          texto: appState.empresaDaSessao?.nome ?? 'Selecionar empresa',
          onTap: () => Navigator.of(context).pushNamed(
            '/login',
            arguments: {'trocandoDeEmpresa': true},
          ),
        ),
        const SizedBox(width: 8),
        _ChipInfo(
          texto: appState.terminalDaSessao?.nome ?? 'Selecionar terminal',
          onTap: () => _trocarTerminal(context),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
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
            style: context.sivTextos.rotulo.copyWith(color: cores.textoPrincipal),
          ),
        ),
      ],
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

    final resultado = await Navigator.of(context).pushNamed(
      '/selecionar_terminal',
      arguments: {'terminais': terminaisDaEmpresa},
    );

    if (!context.mounted || resultado is! Map) {
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
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(SivDimensoes.raio),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          border: Border.all(color: cores.hairline),
          borderRadius: BorderRadius.circular(SivDimensoes.raio),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(texto, style: context.sivTextos.apoio),
            const SizedBox(width: 4),
            Icon(Icons.swap_horiz, size: 14, color: cores.textoApoio),
          ],
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
