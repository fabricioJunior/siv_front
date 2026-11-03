import 'dart:async';

import 'package:comercial/domain/data/gateways/i_filtros_pedidos_contagem_gateway.dart';
import 'package:core/presentation.dart';
import 'package:core/tema.dart';
import 'package:flutter/material.dart';

/// Resultado do sheet: `valor` nulo = "Todas" (limpa); retorno nulo = fechou.
typedef EscolhaOpcao = ({OpcaoFiltro? valor});

/// Lista de opções com busca. Local (filtra [carregar] uma vez) ou no
/// servidor ([buscaNoServidor]: consulta a cada digitação, a partir de
/// [minimo] caracteres; vazio só se [permiteVazio]).
Future<EscolhaOpcao?> abrirOpcoesContagem(
  BuildContext context, {
  required String titulo,
  required Future<List<OpcaoFiltro>> Function(String busca) carregar,
  String rotuloTodas = 'Todas',
  bool buscaNoServidor = false,
  bool permiteVazio = true,
  int minimo = 2,
}) =>
    showModalBottomSheet<EscolhaOpcao>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _Opcoes(
        titulo: titulo,
        carregar: carregar,
        rotuloTodas: rotuloTodas,
        servidor: buscaNoServidor,
        permiteVazio: permiteVazio,
        minimo: minimo,
      ),
    );

class _Opcoes extends StatefulWidget {
  final String titulo;
  final Future<List<OpcaoFiltro>> Function(String) carregar;
  final String rotuloTodas;
  final bool servidor;
  final bool permiteVazio;
  final int minimo;

  const _Opcoes({
    required this.titulo,
    required this.carregar,
    required this.rotuloTodas,
    required this.servidor,
    required this.permiteVazio,
    required this.minimo,
  });

  @override
  State<_Opcoes> createState() => _OpcoesState();
}

class _OpcoesState extends State<_Opcoes> {
  final _debouncer = Debouncer(milliseconds: 350);
  List<OpcaoFiltro> _todas = const [];
  String _busca = '';
  bool _carregando = false;
  bool _falhou = false;

  @override
  void initState() {
    super.initState();
    if (!widget.servidor || widget.permiteVazio) _carregar('');
  }

  @override
  void dispose() {
    _debouncer.cancel();
    super.dispose();
  }

  Future<void> _carregar(String busca) async {
    setState(() {
      _carregando = true;
      _falhou = false;
    });
    try {
      final r = await widget.carregar(busca);
      if (mounted && busca == _busca) setState(() => _todas = r);
    } catch (_) {
      if (mounted) setState(() => _falhou = true);
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  void _digitou(String v) {
    setState(() => _busca = v.trim());
    if (!widget.servidor) return;
    _debouncer.run(() {
      if (_busca.isEmpty
          ? widget.permiteVazio
          : _busca.length >= widget.minimo) {
        _carregar(_busca);
      } else if (mounted) {
        setState(() => _todas = const []);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final c = context.sivColors;
    final t = context.sivTextos;
    final q = _busca.toLowerCase();
    final lista = widget.servidor
        ? _todas
        : _todas.where((o) => o.nome.toLowerCase().contains(q)).toList();
    final aguardando = widget.servidor &&
        (_busca.isEmpty ? !widget.permiteVazio : _busca.length < widget.minimo);
    final altura = MediaQuery.sizeOf(context).height * 0.7;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: SizedBox(
          height: altura,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Row(
                  children: [
                    Expanded(child: Text(widget.titulo, style: t.secao)),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  autofocus: true,
                  onChanged: _digitou,
                  decoration: const InputDecoration(
                    isDense: true,
                    hintText: 'Buscar',
                    prefixIcon: Icon(Icons.search, size: 18),
                  ),
                ),
              ),
              if (_carregando) const LinearProgressIndicator(minHeight: 2),
              Expanded(
                child: aguardando
                    ? Center(
                        child: Text(
                          'Digite ao menos ${widget.minimo} caracteres.',
                          style: t.apoio.copyWith(color: c.textoApoio),
                        ),
                      )
                    : _falhou
                        ? Center(
                            child: TextButton(
                              onPressed: () => _carregar(_busca),
                              child: const Text(
                                  'Falha ao carregar. Tentar de novo'),
                            ),
                          )
                        : ListView(
                            children: [
                              ListTile(
                                title: Text(widget.rotuloTodas),
                                onTap: () => Navigator.pop<EscolhaOpcao>(
                                    context, (valor: null)),
                              ),
                              for (final o in lista)
                                ListTile(
                                  title: Text(o.nome),
                                  onTap: () => Navigator.pop<EscolhaOpcao>(
                                    context,
                                    (valor: o),
                                  ),
                                ),
                              if (!_carregando && lista.isEmpty)
                                Padding(
                                  padding: const EdgeInsets.all(24),
                                  child: Center(
                                    child: Text(
                                      'Nada encontrado.',
                                      style:
                                          t.apoio.copyWith(color: c.textoApoio),
                                    ),
                                  ),
                                ),
                            ],
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
