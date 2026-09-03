import 'package:autenticacao/domain/models/grupo_de_acesso.dart';
import 'package:autenticacao/presentation/bloc/grupos_de_acesso_bloc/grupos_de_acesso_bloc.dart';
import 'package:autenticacao/presentation/pages/grupo_de_acesso_page.dart';
import 'package:autenticacao/presentation/utils/fluxos_de_permissao.dart';
import 'package:core/bloc.dart';
import 'package:core/injecoes.dart';
import 'package:core/presentation.dart';
import 'package:core/tema.dart';
import 'package:flutter/material.dart';

/// Grupo de acesso em 3 colunas na mesma tela -- lista, edição e prévia do
/// que o grupo enxerga, sem navegar entre listar e editar (diferente do
/// fluxo antigo, que empurrava uma rota nova por cima pra editar).
class GruposDeAcessoPage extends StatefulWidget {
  const GruposDeAcessoPage({super.key});

  @override
  State<GruposDeAcessoPage> createState() => _GruposDeAcessoPageState();
}

class _GruposDeAcessoPageState extends State<GruposDeAcessoPage> {
  late final GruposDeAcessoBloc _bloc;

  /// `null` = nenhum grupo selecionado ainda. `-1` = "novo grupo" (ainda
  /// sem id). Qualquer outro valor = id de um grupo existente.
  int? _idSelecionado;

  @override
  void initState() {
    super.initState();
    _bloc = sl<GruposDeAcessoBloc>()..add(const GruposDeAcessoIniciouEvent());
  }

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  void _recarregarLista() => _bloc.add(const GruposDeAcessoIniciouEvent());

  @override
  Widget build(BuildContext context) {
    return BlocProvider<GruposDeAcessoBloc>.value(
      value: _bloc,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(width: 300, child: _colunaLista(context)),
          const SizedBox(width: SivDimensoes.gapCards),
          Expanded(child: _colunaCentro(context)),
          const SizedBox(width: SivDimensoes.gapCards),
          SizedBox(width: 340, child: _colunaPreview(context)),
        ],
      ),
    );
  }

  Widget _colunaLista(BuildContext context) {
    final textos = context.sivTextos;
    return BlocBuilder<GruposDeAcessoBloc, GruposDeAcessoState>(
      builder: (context, state) {
        if (state is GruposDeAcessoCarregarEmProgresso ||
            state is GruposDeAcessoInitial) {
          return const Center(child: CircularProgressIndicator.adaptive());
        }
        if (state is GruposDeAcessoCarregarError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(state.mensagem, textAlign: TextAlign.center),
            ),
          );
        }

        final grupos = (state as GruposDeAcessoCarregarSucesso).grupos;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: grupos.isEmpty
                  ? Center(
                      child: Text(
                        'Nenhum grupo de acesso cadastrado.',
                        style: textos.apoio,
                        textAlign: TextAlign.center,
                      ),
                    )
                  : ListView.separated(
                      itemCount: grupos.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, index) =>
                          _cardGrupo(context, grupos[index]),
                    ),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () => setState(() => _idSelecionado = -1),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Novo grupo'),
            ),
          ],
        );
      },
    );
  }

  Widget _cardGrupo(BuildContext context, GrupoDeAcesso grupo) {
    final textos = context.sivTextos;
    final selecionado = grupo.id == _idSelecionado;

    return SivCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: InkWell(
        onTap: () => setState(() => _idSelecionado = grupo.id),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    grupo.nome,
                    style: textos.corpo.copyWith(
                      fontWeight: selecionado ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // TODO: contagem de usuários vinculados ao grupo não está
                  // disponível -- falta um endpoint grupo->usuários (hoje só
                  // existe o inverso, usuário->grupos, em
                  // VinculosGrupoDeAcessoUsuarioBloc). Mostra só a contagem
                  // de permissões até esse dado existir.
                  Text(
                    '${grupo.permissoes.length} permissões ativas',
                    style: textos.apoio,
                  ),
                ],
              ),
            ),
            if (selecionado)
              Icon(Icons.chevron_right, color: context.sivColors.aco),
          ],
        ),
      ),
    );
  }

  Widget _colunaCentro(BuildContext context) {
    if (_idSelecionado == null) {
      return Center(
        child: Text(
          'Selecione um grupo à esquerda ou crie um novo.',
          style: context.sivTextos.apoio,
        ),
      );
    }

    final idGrupo = _idSelecionado == -1 ? null : _idSelecionado;

    return GrupoDeAcessoPage(
      key: ValueKey('grupo-$_idSelecionado'),
      idGrupoDeAcesso: idGrupo,
      aoSalvar: () {
        _recarregarLista();
      },
      aoExcluir: () {
        setState(() => _idSelecionado = null);
        _recarregarLista();
      },
    );
  }

  Widget _colunaPreview(BuildContext context) {
    final textos = context.sivTextos;
    final cores = context.sivColors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('O que este grupo enxerga', style: textos.secao),
        const SizedBox(height: 12),
        Expanded(
          child: BlocBuilder<GruposDeAcessoBloc, GruposDeAcessoState>(
            builder: (context, state) {
              GrupoDeAcesso? grupo;
              if (state is GruposDeAcessoCarregarSucesso) {
                for (final g in state.grupos) {
                  if (g.id == _idSelecionado) {
                    grupo = g;
                    break;
                  }
                }
              }
              final codigosDoGrupo = grupo?.permissoes.map((p) => p.id).toSet() ?? {};

              return SivMenuLateral(
                colapsado: false,
                secoes: [
                  SivMenuLateralSecao(
                    itens: [
                      for (final item in itensPreviewMenu)
                        _itemPreview(item, codigosDoGrupo, grupo != null),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        // TODO: usuários vinculados ao grupo não estão disponíveis por aqui
        // (falta endpoint grupo->usuários, ver TODO em _cardGrupo). Sem
        // esse dado não dá pra montar os chips "+N" nem contar quantos
        // usuários são afetados no aviso abaixo.
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: cores.superficieRecuada,
            borderRadius: BorderRadius.circular(SivDimensoes.raio),
          ),
          child: Text(
            'Alterações valem no próximo login dos usuários deste grupo.',
            style: textos.apoio,
          ),
        ),
      ],
    );
  }

  SivMenuLateralItem _itemPreview(
    ItemPreviewMenu item,
    Set<String> codigosDoGrupo,
    bool temGrupoSelecionado,
  ) {
    final liberado = item.componentesNecessarios.isEmpty ||
        item.componentesNecessarios.any(codigosDoGrupo.contains);

    return SivMenuLateralItem(
      label: item.label,
      icone: item.icone,
      selecionado: false,
      desabilitado: temGrupoSelecionado && !liberado,
    );
  }
}
