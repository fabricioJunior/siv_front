import 'package:autenticacao/domain/models/permissao.dart';
import 'package:autenticacao/presentation/bloc/grupo_de_acesso_bloc/grupo_de_acesso_bloc.dart';
import 'package:autenticacao/presentation/utils/fluxos_de_permissao.dart';
import 'package:core/bloc.dart';
import 'package:core/injecoes.dart';
import 'package:core/presentation.dart';
import 'package:core/tema.dart';
import 'package:flutter/material.dart';

/// Coluna central da tela de grupo de acesso: nome, contador de permissões
/// ativas, busca, alternância "Só marcadas" e as permissões agrupadas por
/// fluxo de negócio. Sem `Scaffold`/`AppBar` próprio -- é montada dentro da
/// grade de 3 colunas de [GruposDeAcessoPage].
///
/// [idGrupoDeAcesso] nulo monta um grupo novo. Use uma `ValueKey` diferente
/// por grupo selecionado (ver [GruposDeAcessoPage]) pra forçar remontagem
/// (e um bloc novo) ao trocar de seleção na lista da esquerda.
class GrupoDeAcessoPage extends StatefulWidget {
  final int? idGrupoDeAcesso;
  final VoidCallback? aoSalvar;
  final VoidCallback? aoExcluir;

  const GrupoDeAcessoPage({
    super.key,
    this.idGrupoDeAcesso,
    this.aoSalvar,
    this.aoExcluir,
  });

  @override
  State<GrupoDeAcessoPage> createState() => _GrupoDeAcessoPageState();
}

class _GrupoDeAcessoPageState extends State<GrupoDeAcessoPage> {
  late final GrupoDeAcessoBloc bloc;
  final _buscaController = TextEditingController();
  final Set<String> _fluxosAbertos = {};
  bool _somenteMarcadas = false;

  @override
  void initState() {
    super.initState();
    bloc = sl<GrupoDeAcessoBloc>()
      ..add(GrupoDeAcessoIniciouEvent(idGrupoDeAcesso: widget.idGrupoDeAcesso));
  }

  @override
  void dispose() {
    _buscaController.dispose();
    bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<GrupoDeAcessoBloc>.value(
      value: bloc,
      child: BlocListener<GrupoDeAcessoBloc, GrupoDeAcessoState>(
        listenWhen: (previous, current) =>
            current is GrupoDeAcessoSalvarSucesso ||
            current is GrupoDeAcessoSalvarFalha ||
            current is GrupoDeAcessoExcluirGrupoSucesso,
        listener: (context, state) {
          if (state is GrupoDeAcessoSalvarFalha) {
            SivAviso.mostrar(
              context,
              tipo: SivAvisoTipo.falha,
              mensagem: state.mensagem,
            );
          }
          if (state is GrupoDeAcessoSalvarSucesso) {
            SivAviso.mostrar(context, mensagem: 'Grupo de acesso salvo.');
            widget.aoSalvar?.call();
            // Volta pro modo de edição (com o id definitivo) -- sem isso o
            // bloc fica parado em SalvarSucesso e um novo toque em
            // adicionar/remover permissão quebra (o handler espera
            // EdicaoEmProgresso).
            bloc.add(
              GrupoDeAcessoIniciouEvent(idGrupoDeAcesso: state.grupoDeAcesso.id),
            );
          }
          if (state is GrupoDeAcessoExcluirGrupoSucesso) {
            widget.aoExcluir?.call();
          }
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            BlocBuilder<GrupoDeAcessoBloc, GrupoDeAcessoState>(
              // Bloqueia rebuild do cabeçalho (e do TextFormField do nome,
              // que perderia o cursor a cada tecla) enquanto o estado
              // continua EdicaoEmProgresso -- o contador de permissões
              // ativas abaixo tem seu próprio BlocBuilder e atualiza
              // independente disso.
              buildWhen: (previous, current) =>
                  previous is! GrupoDeAcessoEdicaoEmProgresso &&
                  current is! GrupoDeAcessoSalvarFalha,
              builder: (context, state) {
                if (state is GrupoDeAcessoCarregarEmProgresso) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: Center(child: CircularProgressIndicator.adaptive()),
                  );
                }
                if (state is GrupoDeAcessoCarregarFalha) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Column(
                      children: [
                        Text(state.erroMessage),
                        const SizedBox(height: 12),
                        FilledButton.icon(
                          onPressed: () => bloc.add(
                            GrupoDeAcessoIniciouEvent(
                              idGrupoDeAcesso: widget.idGrupoDeAcesso,
                            ),
                          ),
                          icon: const Icon(Icons.refresh),
                          label: const Text('Tentar novamente'),
                        ),
                      ],
                    ),
                  );
                }
                return _cabecalho(context);
              },
            ),
            const SizedBox(height: SivDimensoes.gapCards),
            Expanded(
              child: BlocBuilder<GrupoDeAcessoBloc, GrupoDeAcessoState>(
                builder: (context, state) {
                  if (state is! GrupoDeAcessoEdicaoEmProgresso &&
                      state is! GrupoDeAcessoSalvarSucesso) {
                    return const SizedBox.shrink();
                  }
                  return _corpo(context, state);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _cabecalho(BuildContext context) {
    final textos = context.sivTextos;
    final id = bloc.state.grupoDeAcesso?.id ?? bloc.state.id ?? widget.idGrupoDeAcesso;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: TextFormField(
            key: ValueKey('nome-$id'),
            initialValue: bloc.state.nome ?? '',
            style: textos.secao,
            decoration: const InputDecoration(
              labelText: 'Nome do grupo',
              isDense: true,
            ),
            onChanged: (value) =>
                bloc.add(GrupoDeAcessoAlterouNomeEvent(nome: value)),
          ),
        ),
        const SizedBox(width: 12),
        BlocBuilder<GrupoDeAcessoBloc, GrupoDeAcessoState>(
          buildWhen: (previous, current) =>
              previous.permissoesDoGrupo != current.permissoesDoGrupo ||
              previous.permissoesNaoUtilizadasNoGrupo !=
                  current.permissoesNaoUtilizadasNoGrupo,
          builder: (context, state) {
            final ativas = state.permissoesDoGrupo?.length ?? 0;
            final total = ativas + (state.permissoesNaoUtilizadasNoGrupo?.length ?? 0);
            return Text('$ativas / $total permissões ativas', style: textos.apoio);
          },
        ),
        const SizedBox(width: 12),
        if (id != null)
          IconButton(
            tooltip: 'Excluir grupo',
            onPressed: () => _confirmarExclusao(context),
            icon: const Icon(Icons.delete_outline),
          ),
        FilledButton.icon(
          onPressed: () => bloc.add(GrupoDeAcessoSalvou()),
          icon: const Icon(Icons.check, size: 18),
          label: const Text('Salvar'),
        ),
      ],
    );
  }

  Future<void> _confirmarExclusao(BuildContext context) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir grupo de acesso?'),
        content: const Text(
          'Ação irreversível. Usuários vinculados a este grupo perdem as '
          'permissões associadas a ele.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(ctx).colorScheme.error,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
    if (confirmar == true) {
      bloc.add(GrupoExcluiu());
    }
  }

  Widget _corpo(BuildContext context, GrupoDeAcessoState state) {
    final permissoesDoGrupo = state.permissoesDoGrupo ?? const <Permissao>[];
    final todas = <Permissao>[
      ...permissoesDoGrupo,
      ...(state.permissoesNaoUtilizadasNoGrupo ?? const <Permissao>[]),
    ];
    final grupoNovoVazio =
        widget.idGrupoDeAcesso == null && permissoesDoGrupo.isEmpty;

    final busca = _buscaController.text.trim().toLowerCase();
    final filtradas = todas.where((p) {
      if (_somenteMarcadas && !permissoesDoGrupo.contains(p)) return false;
      if (busca.isEmpty) return true;
      return p.nomeExibicao.toLowerCase().contains(busca) ||
          p.id.toLowerCase().contains(busca);
    }).toList();

    final porFluxo = agruparPermissoesPorFluxo(filtradas);

    return ListView(
      children: [
        if (grupoNovoVazio) _seletorDeCargo(context),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _buscaController,
                decoration: const InputDecoration(
                  isDense: true,
                  hintText: 'Buscar por nome ou código (ex: PEDFC001)',
                  prefixIcon: Icon(Icons.search_outlined, size: 18),
                ),
                onChanged: (_) => setState(() {}),
              ),
            ),
            const SizedBox(width: 12),
            const Text('Só marcadas'),
            Switch(
              value: _somenteMarcadas,
              onChanged: (v) => setState(() => _somenteMarcadas = v),
            ),
          ],
        ),
        const SizedBox(height: SivDimensoes.gapCards),
        if (porFluxo.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Text('Nenhuma permissão encontrada.'),
          ),
        for (final entrada in porFluxo.entries) ...[
          _fluxoCard(context, entrada.key, entrada.value, permissoesDoGrupo),
          const SizedBox(height: 12),
        ],
      ],
    );
  }

  Widget _fluxoCard(
    BuildContext context,
    String fluxo,
    List<Permissao> permissoesDoFluxo,
    List<Permissao> permissoesDoGrupo,
  ) {
    final cores = context.sivColors;
    final textos = context.sivTextos;
    final marcadas =
        permissoesDoFluxo.where((p) => permissoesDoGrupo.contains(p)).length;
    final total = permissoesDoFluxo.length;
    final estado = marcadas == 0
        ? false
        : (marcadas == total ? true : null);
    final aberto = _fluxosAbertos.contains(fluxo);

    return SivCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            onTap: () => setState(() {
              aberto ? _fluxosAbertos.remove(fluxo) : _fluxosAbertos.add(fluxo);
            }),
            child: Padding(
              padding: const EdgeInsets.all(SivDimensoes.paddingCard),
              child: Row(
                children: [
                  Checkbox(
                    tristate: true,
                    value: estado,
                    onChanged: (_) =>
                        _alternarFluxo(fluxo, permissoesDoFluxo, permissoesDoGrupo),
                  ),
                  Expanded(
                    child: Text(fluxo, style: textos.corpo.copyWith(fontWeight: FontWeight.w700)),
                  ),
                  Text('$marcadas de $total', style: textos.apoio),
                  const SizedBox(width: 12),
                  TextButton(
                    onPressed: marcadas == 0
                        ? null
                        : () => _desmarcarFluxo(permissoesDoFluxo, permissoesDoGrupo),
                    child: const Text('Desmarcar fluxo'),
                  ),
                  Icon(aberto ? Icons.expand_less : Icons.expand_more, color: cores.textoApoio),
                ],
              ),
            ),
          ),
          if (aberto)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                SivDimensoes.paddingCard, 0, SivDimensoes.paddingCard, SivDimensoes.paddingCard,
              ),
              child: Wrap(
                runSpacing: 4,
                children: [
                  for (final permissao in permissoesDoFluxo)
                    FractionallySizedBox(
                      widthFactor: 0.5,
                      child: _permissaoLinha(
                        context,
                        permissao,
                        permissoesDoGrupo.contains(permissao),
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _permissaoLinha(BuildContext context, Permissao permissao, bool marcada) {
    final textos = context.sivTextos;
    final cores = context.sivColors;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
      child: InkWell(
        onTap: () => marcada
            ? bloc.add(GrupoDeAcessoRemoveuPermissao(permissao: permissao))
            : bloc.add(GrupoDeAcessoAdionouPermissao(permissao: permissao)),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Checkbox(
              value: marcada,
              onChanged: (_) => marcada
                  ? bloc.add(GrupoDeAcessoRemoveuPermissao(permissao: permissao))
                  : bloc.add(GrupoDeAcessoAdionouPermissao(permissao: permissao)),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Row(
                  children: [
                    Flexible(
                      child: Text(
                        permissao.nomeExibicao,
                        style: textos.corpo,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      permissao.id,
                      style: textos.codigo.copyWith(color: cores.textoApoio),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _alternarFluxo(
    String fluxo,
    List<Permissao> permissoesDoFluxo,
    List<Permissao> permissoesDoGrupo,
  ) {
    final marcadas = permissoesDoFluxo.where((p) => permissoesDoGrupo.contains(p));
    if (marcadas.length == permissoesDoFluxo.length) {
      _desmarcarFluxo(permissoesDoFluxo, permissoesDoGrupo);
      return;
    }
    for (final permissao in permissoesDoFluxo) {
      if (!permissoesDoGrupo.contains(permissao)) {
        bloc.add(GrupoDeAcessoAdionouPermissao(permissao: permissao));
      }
    }
  }

  void _desmarcarFluxo(
    List<Permissao> permissoesDoFluxo,
    List<Permissao> permissoesDoGrupo,
  ) {
    for (final permissao in permissoesDoFluxo) {
      if (permissoesDoGrupo.contains(permissao)) {
        bloc.add(GrupoDeAcessoRemoveuPermissao(permissao: permissao));
      }
    }
  }

  // Templates de cargo (Vendedor/Caixa/Gerente) só aparecem num grupo NOVO
  // e ainda sem nenhuma permissão -- monta o perfil de uma vez em vez de
  // escolher item por item. Some assim que a primeira permissão é
  // adicionada (por template ou manualmente).
  Widget _seletorDeCargo(BuildContext context) {
    final theme = Theme.of(context);
    final disponiveis = bloc.state.permissoesNaoUtilizadasNoGrupo ?? const [];

    void aplicarCargo(String cargo) {
      final codigos = componentesDoCargo(cargo).toSet();
      for (final permissao in disponiveis) {
        if (codigos.contains(permissao.id)) {
          bloc.add(GrupoDeAcessoAdionouPermissao(permissao: permissao));
        }
      }
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: SivDimensoes.gapCards),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Começar com um cargo pronto?', style: theme.textTheme.titleSmall),
          const SizedBox(height: 4),
          Text(
            'Escolha um ponto de partida e ajuste depois. Ou marque as '
            'permissões manualmente abaixo.',
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final cargo in cargosPredefinidos)
                ActionChip(
                  avatar: const Icon(Icons.badge_outlined, size: 18),
                  label: Text(cargo),
                  onPressed: () => aplicarCargo(cargo),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
