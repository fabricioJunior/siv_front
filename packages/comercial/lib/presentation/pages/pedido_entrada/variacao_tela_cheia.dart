import 'package:comercial/domain/models/variacao_opcao.dart';
import 'package:comercial/presentation/blocs/variacoes_produto_bloc/variacoes_produto_bloc.dart';
import 'package:comercial/presentation/pages/pedido_entrada/tamanhos_tela_cheia.dart';
import 'package:core/bloc.dart';
import 'package:core/seletores.dart';
import 'package:flutter/material.dart';

SelectData _sd(VariacaoOpcao o) =>
    SelectData(id: o.id, nome: o.nome, data: const {});

/// Alimenta o [SeletorTelaCheia] (core, sem bloc) com o estado do
/// [VariacoesProdutoBloc]: abre na hora, spinner enquanto carrega.
class VariacaoTelaCheia extends StatelessWidget {
  final String titulo;
  final String? subtitulo;
  final VariacaoLista<VariacaoOpcao> Function(VariacoesProdutoState) lista;
  final VariacoesProdutoEvent Function(String nome) cadastrar;
  final String singular;
  final String plural;
  final SeletorGenericoModo modo;
  final List<SelectData> selecionados;

  /// Ids que não aparecem (já escolhidos) e ids "já usados nesta referência".
  final Set<int> ocultos;
  final Set<int> usados;

  const VariacaoTelaCheia({
    super.key,
    required this.titulo,
    required this.lista,
    required this.cadastrar,
    required this.singular,
    required this.plural,
    this.subtitulo,
    this.modo = SeletorGenericoModo.multipla,
    this.selecionados = const [],
    this.ocultos = const {},
    this.usados = const {},
  });

  static Future<List<SelectData>?> abrir(
    BuildContext context,
    VariacoesProdutoBloc bloc,
    VariacaoTelaCheia tela,
  ) =>
      Navigator.of(context).push<List<SelectData>>(
        MaterialPageRoute(
          fullscreenDialog: true,
          builder: (_) => BlocProvider.value(value: bloc, child: tela),
        ),
      );

  Future<SelectData?> _cadastrar(BuildContext context, String nome) async {
    final bloc = context.read<VariacoesProdutoBloc>();
    bloc.add(cadastrar(nome));
    final s = await bloc.stream.firstWhere((s) {
      final l = lista(s);
      return l.ultimoCadastrado != null || l.erro != null;
    });
    final l = lista(s);
    if (l.erro != null && context.mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l.erro!)));
    }
    return l.ultimoCadastrado == null ? null : _sd(l.ultimoCadastrado!);
  }

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<VariacoesProdutoBloc, VariacoesProdutoState>(
        builder: (context, s) {
          final l = lista(s);
          final todas = [
            for (final o in l.itens)
              if (!ocultos.contains(o.id)) _sd(o),
          ];
          return SeletorTelaCheia<SelectData>(
            titulo: titulo,
            subtitulo: subtitulo,
            itens: todas,
            itemLabel: (s) => s.nome,
            itemKey: (s) => s.id,
            modo: modo,
            selecionadosIniciais: selecionados,
            jaUsados: todas.where((c) => usados.contains(c.id)).toList(),
            nomeSingular: singular,
            nomePlural: plural,
            hintText: 'Buscar $singular',
            onCadastrar: (n) => _cadastrar(context, n),
            carregando: l.status == VariacaoStatus.carregando,
            erro: l.status == VariacaoStatus.falha ? l.erro : null,
            onTentarNovamente: () => context
                .read<VariacoesProdutoBloc>()
                .add(const VariacoesCarregadas()),
          );
        },
      );
}

/// [TamanhosTelaCheia] alimentada pelo estado do [VariacoesProdutoBloc].
class TamanhosVariacaoTelaCheia extends StatelessWidget {
  final String? subtitulo;
  final Set<int> selecionados;

  const TamanhosVariacaoTelaCheia({
    super.key,
    required this.selecionados,
    this.subtitulo,
  });

  static Future<Set<int>?> abrir(
    BuildContext context,
    VariacoesProdutoBloc bloc,
    TamanhosVariacaoTelaCheia tela,
  ) =>
      Navigator.of(context).push<Set<int>>(
        MaterialPageRoute(
          fullscreenDialog: true,
          builder: (_) => BlocProvider.value(value: bloc, child: tela),
        ),
      );

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<VariacoesProdutoBloc, VariacoesProdutoState>(
        builder: (context, s) => TamanhosTelaCheia(
          subtitulo: subtitulo,
          opcoes: s.tamanhos.itens,
          selecionados: selecionados,
          carregando: s.tamanhos.status == VariacaoStatus.carregando,
          erro: s.tamanhos.status == VariacaoStatus.falha
              ? s.tamanhos.erro
              : null,
          onTentarNovamente: () => context
              .read<VariacoesProdutoBloc>()
              .add(const VariacoesCarregadas()),
        ),
      );
}
