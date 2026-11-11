import 'dart:async';

import 'package:comercial/data.dart';
import 'package:comercial/models.dart';
import 'package:comercial/presentation.dart';
import 'package:comercial/use_cases.dart';
import 'package:core/bloc.dart';
import 'package:flutter/widgets.dart';

class VariacoesGatewayFake implements IVariacoesProdutoGateway {
  List<VariacaoOpcao> coresLista;
  List<VariacaoOpcao> estampasLista;
  List<TamanhoOpcao> tamanhosLista;

  /// Quando definido, as leituras só respondem depois de completar.
  Completer<void>? atraso;

  /// Quando verdadeiro, as leituras lançam.
  bool falha = false;

  int chamadasCores = 0, chamadasEstampas = 0, chamadasTamanhos = 0;

  VariacoesGatewayFake({
    this.coresLista = const [],
    this.estampasLista = const [],
    this.tamanhosLista = const [],
  });

  Future<T> _ler<T>(T valor) async {
    if (atraso != null) await atraso!.future;
    if (falha) throw Exception('rede');
    return valor;
  }

  @override
  Future<List<VariacaoOpcao>> cores() {
    chamadasCores++;
    return _ler(coresLista);
  }

  @override
  Future<List<VariacaoOpcao>> estampas() {
    chamadasEstampas++;
    return _ler(estampasLista);
  }

  @override
  Future<List<TamanhoOpcao>> tamanhos() {
    chamadasTamanhos++;
    return _ler(tamanhosLista);
  }

  @override
  Future<VariacaoOpcao> criarCor(String nome) async =>
      VariacaoOpcao(id: 100 + coresLista.length, nome: nome);

  @override
  Future<VariacaoOpcao> criarEstampa(String nome) async =>
      VariacaoOpcao(id: 200 + estampasLista.length, nome: nome);
}

VariacoesProdutoBloc criarVariacoesBloc(VariacoesGatewayFake g) {
  final cores = RecuperarCoresDeProdutos(g);
  final estampas = RecuperarEstampasDeProdutos(g);
  return VariacoesProdutoBloc(
    cores,
    estampas,
    RecuperarTamanhosDeProdutos(g),
    CriarCorDeProdutos(g, cores),
    CriarEstampaDeProdutos(g, estampas),
  );
}

/// Provê um bloc de variações (já pré-carregado, como a página faz) ao [filho].
Widget comVariacoes(VariacoesProdutoBloc bloc, Widget filho) =>
    BlocProvider<VariacoesProdutoBloc>.value(value: bloc, child: filho);
