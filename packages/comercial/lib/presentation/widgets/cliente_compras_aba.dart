import 'package:comercial/domain/models/relatorios.dart';
import 'package:comercial/presentation/blocs/compras_do_cliente_bloc/compras_do_cliente_bloc.dart';
import 'package:comercial/presentation/widgets/transferir_credito_dialogo.dart'
    show formatarMoedaBr;
import 'package:core/bloc.dart';
import 'package:core/injecoes.dart';
import 'package:core/presentation.dart';
import 'package:core/tema.dart';
import 'package:flutter/material.dart';

String _fmtData(String iso) {
  if (iso.isEmpty) return '-';
  final p = iso.split('T').first.split('-');
  return p.length == 3 ? '${p[2]}/${p[1]}/${p[0]}' : iso;
}

/// Aba Compras da tela do cliente (sem Scaffold; vai dentro da aba).
class ClienteComprasAba extends StatefulWidget {
  final int pessoaId;

  const ClienteComprasAba({super.key, required this.pessoaId});

  @override
  State<ClienteComprasAba> createState() => _ClienteComprasAbaState();
}

class _ClienteComprasAbaState extends State<ClienteComprasAba> {
  late final ComprasDoClienteBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = sl<ComprasDoClienteBloc>()
      ..add(ComprasDoClienteCarregar(pessoaId: widget.pessoaId));
  }

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  void _abrirRomaneio(int id) => Navigator.of(context).pushNamed(
        '/romaneio',
        arguments: {'idRomaneio': id, 'permitirEdicao': false},
      );

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ComprasDoClienteBloc, ComprasDoClienteState>(
      bloc: _bloc,
      builder: (context, state) {
        switch (state.step) {
          case ComprasDoClienteStep.carregando:
          case ComprasDoClienteStep.inicial:
            return const Center(child: CircularProgressIndicator.adaptive());
          case ComprasDoClienteStep.falha:
            return _Mensagem(
              texto: state.erro ?? 'Falha ao carregar',
              aoTentar: () => _bloc
                  .add(ComprasDoClienteCarregar(pessoaId: widget.pessoaId)),
            );
          case ComprasDoClienteStep.sucesso:
            final itens = state.dados!.items;
            if (itens.isEmpty) {
              return const _Mensagem(
                texto: 'Este cliente ainda não possui compras.',
              );
            }
            return _Tabela(itens: itens, aoAbrir: _abrirRomaneio);
        }
      },
    );
  }
}

class _Tabela extends StatelessWidget {
  final List<RelatorioClienteCompraItem> itens;
  final void Function(int romaneioId) aoAbrir;

  const _Tabela({required this.itens, required this.aoAbrir});

  @override
  Widget build(BuildContext context) {
    final cores = context.sivColors;
    final textos = context.sivTextos;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        SivTabela(
          colunas: const [
            SivTabelaColuna(titulo: 'ROMANEIO'),
            SivTabelaColuna(titulo: 'DATA'),
            SivTabelaColuna(titulo: 'LOJA', flex: 2),
            SivTabelaColuna.numerica(titulo: 'VALOR LÍQUIDO'),
          ],
          quantidadeLinhas: itens.length,
          onLinhaTap: (i) => aoAbrir(itens[i].romaneioId),
          rodape: '${itens.length} compra(s)',
          linhaBuilder: (_, i) {
            final item = itens[i];
            return [
              Text(
                '#${item.romaneioId}',
                style: textos.codigo.copyWith(color: cores.aco),
              ),
              Text(_fmtData(item.data), style: textos.corpo),
              Text(item.empresaNome,
                  style: textos.corpo, overflow: TextOverflow.ellipsis),
              Text(
                formatarMoedaBr(item.valorLiquido),
                style: textos.corpo.copyWith(fontWeight: FontWeight.w600),
              ),
            ];
          },
        ),
      ],
    );
  }
}

class _Mensagem extends StatelessWidget {
  final String texto;
  final VoidCallback? aoTentar;

  const _Mensagem({required this.texto, this.aoTentar});

  @override
  Widget build(BuildContext context) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(texto,
                textAlign: TextAlign.center,
                style: context.sivTextos.apoio
                    .copyWith(color: context.sivColors.textoApoio)),
            if (aoTentar != null)
              TextButton.icon(
                icon: const Icon(Icons.refresh),
                label: const Text('Tentar novamente'),
                onPressed: aoTentar,
              ),
          ],
        ),
      );
}
