import 'package:core/tema.dart';
import 'package:flutter/material.dart';

enum ClienteAba {
  dados('Dados'),
  enderecos('Endereços'),
  compras('Compras'),
  pontos('Pontos'),
  credito('Crédito de devolução');

  final String rotulo;
  const ClienteAba(this.rotulo);

  /// Converte o argumento `aba` das rotas (nome do enum); desconhecido = dados.
  static ClienteAba de(Object? nome) => ClienteAba.values.firstWhere(
        (a) => a.name == nome,
        orElse: () => ClienteAba.dados,
      );
}

/// Ações do cabeçalho que dependem de conteúdo da aba. A aba registra o
/// callback no initState (`ClienteAcoes.de(context).definir(...)`) e limpa no
/// dispose (`definir(acao, null)`); o botão só aparece com callback registrado.
enum ClienteAcao { novoEndereco, resgatarPontos, lancarPontos, adicionarCredito }

class ClienteAcoes extends ChangeNotifier {
  final _acoes = <ClienteAcao, VoidCallback>{};

  VoidCallback? operator [](ClienteAcao acao) => _acoes[acao];

  void definir(ClienteAcao acao, VoidCallback? aoPressionar) {
    if (aoPressionar == null) {
      if (_acoes.remove(acao) == null) return;
    } else {
      _acoes[acao] = aoPressionar;
    }
    // Chamado de initState/dispose de filhos: notifica fora do build.
    WidgetsBinding.instance.addPostFrameCallback((_) => notifyListeners());
  }

  static ClienteAcoes de(BuildContext context) => context
      .dependOnInheritedWidgetOfExactType<ClienteAcoesEscopo>()!
      .acoes;
}

class ClienteAcoesEscopo extends InheritedWidget {
  final ClienteAcoes acoes;

  const ClienteAcoesEscopo({
    super.key,
    required this.acoes,
    required super.child,
  });

  @override
  bool updateShouldNotify(ClienteAcoesEscopo old) => acoes != old.acoes;
}

/// Barra de abas: sublinhado no desktop, chips rolláveis de 44px no mobile.
class ClienteAbas extends StatelessWidget {
  final ClienteAba selecionada;
  final ValueChanged<ClienteAba> aoSelecionar;
  final bool mobile;

  const ClienteAbas({
    super.key,
    required this.selecionada,
    required this.aoSelecionar,
    required this.mobile,
  });

  @override
  Widget build(BuildContext context) {
    final cores = context.sivColors;
    final textos = context.sivTextos;

    final itens = [
      for (final aba in ClienteAba.values)
        InkWell(
          onTap: () => aoSelecionar(aba),
          child: mobile
              ? _chip(aba, cores, textos)
              : _sublinhada(aba, cores, textos),
        ),
    ];

    return Container(
      height: mobile ? SivDimensoes.alvoToqueMinimo + 16 : null,
      decoration: BoxDecoration(
        color: cores.superficie,
        border: Border(bottom: BorderSide(color: cores.hairline)),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: mobile ? 16 : SivDimensoes.paddingBarraTituloHorizontal,
      ),
      child: mobile
          ? ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: itens.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) => Center(child: itens[i]),
            )
          : Row(children: [
              for (final i in itens) ...[i, const SizedBox(width: 26)],
            ]),
    );
  }

  Widget _sublinhada(ClienteAba aba, SivColors cores, SivTextStyles textos) {
    final ativa = aba == selecionada;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 2),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            width: 2,
            color: ativa ? cores.aco : Colors.transparent,
          ),
        ),
      ),
      child: Text(
        aba.rotulo,
        style: textos.secao.copyWith(
          fontSize: 14,
          color: ativa ? cores.textoPrincipal : cores.textoApoio,
        ),
      ),
    );
  }

  Widget _chip(ClienteAba aba, SivColors cores, SivTextStyles textos) {
    final ativa = aba == selecionada;
    return Container(
      height: SivDimensoes.alvoToqueMinimo,
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: ativa ? cores.acoEscuro : null,
        border: Border.all(color: ativa ? cores.acoEscuro : cores.hairline),
        borderRadius: BorderRadius.circular(SivDimensoes.raio),
      ),
      child: Text(
        aba.rotulo,
        style: textos.secao.copyWith(
          fontSize: 14,
          color: ativa ? cores.textoSobreEscuroTitulo : cores.textoPrincipal,
        ),
      ),
    );
  }
}
