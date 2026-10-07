import 'package:autenticacao/models.dart';
import 'package:autenticacao/presentation/bloc/acoes_do_grupo_bloc/acoes_do_grupo_bloc.dart';
import 'package:core/bloc.dart';
import 'package:core/injecoes.dart';
import 'package:core/presentation.dart';
import 'package:core/tema.dart';
import 'package:flutter/material.dart';

/// Seção "Por fluxo" da tela de grupo de acesso: o admin liga ou desliga
/// ações (ex: Venda > Fazer venda; Caixa > Ver movimentações) e o servidor
/// aplica TODAS as permissões que a ação exige, pra nenhuma ficar de fora.
///
/// As alterações ficam pendentes e só vão ao servidor no FAB "Salvar
/// alterações" (independe do botão Salvar do grupo). Devolve a área rolável
/// inteira: [cabecalho] (abas) + lista + FAB. [aoAplicar] roda depois de
/// salvar, pra o pai recarregar a lista de permissões individuais. [nomesPorCodigo] traduz o
/// código da permissão (PEDFC001) no nome que o admin entende.
class PermissoesPorFluxoView extends StatefulWidget {
  final int? idGrupoDeAcesso;
  final Map<String, String> nomesPorCodigo;
  final VoidCallback aoAplicar;
  final Widget cabecalho;

  const PermissoesPorFluxoView({
    super.key,
    required this.cabecalho,
    required this.idGrupoDeAcesso,
    required this.nomesPorCodigo,
    required this.aoAplicar,
  });

  @override
  State<PermissoesPorFluxoView> createState() => PermissoesPorFluxoViewState();
}

class PermissoesPorFluxoViewState extends State<PermissoesPorFluxoView> {
  late final AcoesDoGrupoBloc _bloc;
  final Set<String> _fluxosAbertos = {};

  @override
  void initState() {
    super.initState();
    _bloc = sl<AcoesDoGrupoBloc>();
    final id = widget.idGrupoDeAcesso;
    if (id != null) _bloc.add(AcoesDoGrupoCarregou(id));
  }

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  /// true se pode sair/trocar de aba: sem pendências ou usuário confirmou
  /// descartar.
  Future<bool> confirmarSaida(BuildContext context) async {
    if (!_bloc.state.temPendencias) return true;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Descartar alterações?'),
        content: const Text('Há permissões alteradas que não foram salvas.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Continuar editando'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Descartar'),
          ),
        ],
      ),
    );
    return ok == true;
  }

  String _nome(String codigo) => widget.nomesPorCodigo[codigo] ?? codigo;

  @override
  Widget build(BuildContext context) {
    if (widget.idGrupoDeAcesso == null) {
      return ListView(
        children: [
          widget.cabecalho,
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Text(
              'Salve o grupo primeiro. Depois você libera os fluxos por aqui, '
              'ou marque as permissões na aba "Individuais".',
            ),
          ),
        ],
      );
    }

    return BlocProvider<AcoesDoGrupoBloc>.value(
      value: _bloc,
      child: BlocConsumer<AcoesDoGrupoBloc, AcoesDoGrupoState>(
        listenWhen: (a, b) =>
            a.aplicacoes != b.aplicacoes ||
            (b.status == AcoesDoGrupoStatus.falha && b.acoes != null),
        listener: (context, state) {
          if (state.status == AcoesDoGrupoStatus.falha) {
            SivAviso.mostrar(
              context,
              tipo: SivAvisoTipo.falha,
              mensagem: state.mensagemDeErro ?? 'Não foi possível salvar.',
            );
          } else {
            SivAviso.mostrar(context, mensagem: 'Permissões salvas');
            widget.aoAplicar();
          }
        },
        builder: (context, state) {
          final acoes = state.acoes;
          if (acoes == null) {
            return ListView(
              children: [
                widget.cabecalho,
                if (state.status == AcoesDoGrupoStatus.falha)
                  _falhaAoCarregar(state.mensagemDeErro)
                else
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: Center(child: CircularProgressIndicator.adaptive()),
                  ),
              ],
            );
          }
          final aplicando = state.status == AcoesDoGrupoStatus.aplicando;
          final pendencias = state.pendentes.length;
          return PopScope(
            canPop: pendencias == 0,
            onPopInvokedWithResult: (didPop, _) async {
              if (didPop) return;
              final nav = Navigator.of(context);
              if (await confirmarSaida(context)) nav.pop();
            },
            child: Stack(
              children: [
                ListView(
                  padding: EdgeInsets.only(bottom: pendencias > 0 ? 88 : 0),
                  children: [
                    widget.cabecalho,
                    if (aplicando) const LinearProgressIndicator(minHeight: 2),
                    if (pendencias > 0)
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton.icon(
                          onPressed: aplicando
                              ? null
                              : () => _bloc.add(AcoesDoGrupoDescartou()),
                          icon: const Icon(Icons.undo, size: 18),
                          label: const Text('Descartar alterações'),
                        ),
                      ),
                    const SizedBox(height: SivDimensoes.gapCards),
                    for (final fluxo in acoes.fluxos) ...[
                      _fluxoCard(context, fluxo, state, aplicando),
                      const SizedBox(height: 12),
                    ],
                    if (acoes.componentesAvulsos.isNotEmpty)
                      _avulsos(context, acoes.componentesAvulsos),
                  ],
                ),
                if (pendencias > 0)
                  Positioned(
                    right: 16,
                    bottom: 16,
                    child: FloatingActionButton.extended(
                      heroTag: null,
                      onPressed: aplicando ? null : () => _bloc.add(AcoesDoGrupoSalvou()),
                      icon: aplicando
                          ? const SizedBox.square(
                              dimension: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.check),
                      label: Text('Salvar alterações ($pendencias)'),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _falhaAoCarregar(String? mensagem) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        children: [
          Text(mensagem ?? 'Não foi possível carregar.'),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: () => _bloc.add(AcoesDoGrupoCarregou(widget.idGrupoDeAcesso!)),
            icon: const Icon(Icons.refresh),
            label: const Text('Tentar novamente'),
          ),
        ],
      ),
    );
  }

  Widget _fluxoCard(
    BuildContext context,
    FluxoDoGrupo fluxo,
    AcoesDoGrupoState state,
    bool aplicando,
  ) {
    final cores = context.sivColors;
    final textos = context.sivTextos;
    final aberto = _fluxosAbertos.contains(fluxo.id);
    final incompletas = fluxo.acoes
        .where((a) =>
            a.estado == EstadoAcaoDoGrupo.incompleta &&
            !state.pendentes.containsKey(a.id))
        .length;
    final ligadas = fluxo.acoes.where(state.ligada).length;

    return SivCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            onTap: () => setState(() {
              aberto ? _fluxosAbertos.remove(fluxo.id) : _fluxosAbertos.add(fluxo.id);
            }),
            child: Padding(
              padding: const EdgeInsets.all(SivDimensoes.paddingCard),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          fluxo.nome,
                          style: textos.corpo.copyWith(fontWeight: FontWeight.w700),
                        ),
                        Text(fluxo.descricao, style: textos.apoio),
                      ],
                    ),
                  ),
                  if (incompletas > 0) ...[
                    Icon(Icons.warning_amber_rounded, size: 18, color: cores.atencao),
                    const SizedBox(width: 4),
                    Text('$incompletas incompleta${incompletas > 1 ? 's' : ''}',
                        style: textos.apoio),
                    const SizedBox(width: 12),
                  ],
                  Text('$ligadas de ${fluxo.acoes.length} ações',
                      style: textos.apoio),
                  const SizedBox(width: 8),
                  Icon(aberto ? Icons.expand_less : Icons.expand_more, color: cores.textoApoio),
                ],
              ),
            ),
          ),
          if (aberto)
            for (final acao in fluxo.acoes) _acaoLinha(context, fluxo, acao, state, aplicando),
        ],
      ),
    );
  }

  Widget _acaoLinha(
    BuildContext context,
    FluxoDoGrupo fluxo,
    AcaoDoGrupo acao,
    AcoesDoGrupoState state,
    bool aplicando,
  ) {
    final textos = context.sivTextos;
    final cores = context.sivColors;
    final ligada = state.ligada(acao);
    final incompleta = acao.estado == EstadoAcaoDoGrupo.incompleta &&
        !state.pendentes.containsKey(acao.id);
    final nomesRequeridas = acao.requer
        .map((id) => fluxo.acoes.where((a) => a.id == id).map((a) => a.nome))
        .expand((n) => n)
        .toList();

    return Container(
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: cores.hairline)),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: SivDimensoes.paddingCard,
        vertical: 10,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Switch(
            value: ligada,
            onChanged: aplicando
                ? null
                : (v) => _bloc.add(AcoesDoGrupoAlternou(acao.id, ligar: v)),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(acao.nome, style: textos.corpo),
                Text(acao.descricao, style: textos.apoio),
                if (nomesRequeridas.isNotEmpty)
                  Text('Precisa de: ${nomesRequeridas.join(', ')}', style: textos.apoio),
                if (incompleta)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      'Faltam permissões: ${acao.faltando.map(_nome).join(', ')}',
                      style: textos.apoio.copyWith(color: cores.atencao),
                    ),
                  ),
                if (ligada || incompleta)
                  Tooltip(
                    message: acao.componentes.map(_nome).join('\n'),
                    child: Text(
                      '${acao.componentes.length} permissões incluídas',
                      style: textos.apoio.copyWith(decoration: TextDecoration.underline),
                    ),
                  ),
              ],
            ),
          ),
          if (incompleta)
            TextButton(
              onPressed: aplicando
                  ? null
                  : () => _bloc.add(AcoesDoGrupoCompletou(acao.id)),
              child: const Text('Completar'),
            ),
        ],
      ),
    );
  }

  Widget _avulsos(BuildContext context, List<String> codigos) {
    final textos = context.sivTextos;
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Tooltip(
        message: codigos.map(_nome).join('\n'),
        child: Text(
          '${codigos.length} permissão(ões) marcada(s) na aba "Individuais" que '
          'nenhuma ação cobre. Elas continuam valendo.',
          style: textos.apoio,
        ),
      ),
    );
  }
}
