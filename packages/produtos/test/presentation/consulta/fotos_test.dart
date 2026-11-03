import 'dart:typed_data';

import 'package:core/imagens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:produtos/data/remote/dtos/referencia_midia_dto.dart';
import 'package:produtos/presentantion/modals/referencia_midia_metadados_modal.dart';
import 'package:produtos/presentantion/widgets/consulta/fotos_ordem.dart';

import 'package:produtos/presentantion/bloc/referencia_midias_bloc/referencia_midias_bloc.dart' hide ReferenciasIniciou;
import 'package:produtos/presentantion/bloc/referencia_midias_bloc/referencia_midias_bloc.dart' as m show ReferenciasIniciou;
import 'consulta_fakes.dart';
import 'fotos_fakes.dart';

const _grade = [
  ProdutoDaGrade(produtoId: 1, corId: 1, corNome: 'Azul', tamanhoId: 1, tamanhoNome: 'P', codigosBarras: [], saldo: 1),
  ProdutoDaGrade(produtoId: 2, corId: 1, corNome: 'Azul', tamanhoId: 2, tamanhoNome: 'M', estampaId: 7, estampaNome: 'Floral', codigosBarras: [], saldo: 1),
  ProdutoDaGrade(produtoId: 3, corId: 2, corNome: 'Preto', tamanhoId: 1, tamanhoNome: 'P', codigosBarras: [], saldo: 1),
];

void main() {
  const opcoes = OpcoesAssociacaoFoto(_grade);

  group('validação da associação', () {
    test('cor, estampa e tamanho são obrigatórios', () {
      expect(const AssociacaoFoto().faltas, ['cor', 'estampa', 'tamanho']);
      expect(const AssociacaoFoto(cor: 'Azul').avisoFalta, 'Falta estampa, tamanho');
      expect(opcoes.valida(const AssociacaoFoto(cor: 'Azul')), isFalse);
    });

    test('estampa filtrada pela cor; liso rotulado como Liso', () {
      expect(opcoes.estampasDaCor('Azul'), ['Liso', 'Floral']);
      expect(opcoes.estampasDaCor('Preto'), ['Liso']);
    });

    test('opção única é preenchida; troca de cor invalida estampa', () {
      final a = opcoes.preencher(const AssociacaoFoto(cor: 'Preto'));
      expect(a.estampa, 'Liso');
      final b = const AssociacaoFoto(cor: 'Azul', estampa: 'Floral', tamanho: 'M').comCor('Preto', opcoes);
      expect(b.cor, 'Preto');
      expect(b.estampa, 'Liso');
    });

    test('tamanho aceita * e rejeita combinação fora da grade', () {
      expect(opcoes.valida(const AssociacaoFoto(cor: 'Azul', estampa: 'Liso', tamanho: '*')), isTrue);
      expect(opcoes.valida(const AssociacaoFoto(cor: 'Preto', estampa: 'Floral', tamanho: 'P')), isFalse);
      expect(opcoes.valida(const AssociacaoFoto(cor: 'Azul', estampa: 'Liso', tamanho: 'GG')), isFalse);
    });

    test('nome de arquivo para download', () {
      expect(
        nomeArquivoFoto('Calça Jeans', const AssociacaoFoto(cor: 'Azul Marinho', estampa: 'Liso'), 2),
        'calca-jeans-azul-marinho-liso-2.jpg',
      );
    });
  });

  test('DTO de mídia carrega e envia estampa', () {
    final dto = ReferenciaMidiaDto.fromJson({
      'id': 1, 'url': 'u', 'isDefault': true, 'isPublic': true, 'referenciaId': 5,
      'cor': 'Azul', 'tamanho': '*', 'estampa': 'Liso',
    });
    expect(dto.estampa, 'Liso');
    expect(dto.toJson()['estampa'], 'Liso');
    expect(dto.associacao.completa, isTrue);
  });

  test('reordenarIds move e a primeira vira capa', () {
    expect(reordenarIds([1, 2, 3], 2, 0), [3, 1, 2]);
    expect(reordenarIds([1, 2, 3], 0, 1), [2, 1, 3]);
  });

  group('ReferenciaMidiasBloc', () {
    test('reordenar grava PUT ordem e recarrega com nova capa', () async {
      final repo = FakeMidiasRepo([midia(1, capa: true), midia(2), midia(3)]);
      final bloc = novoMidiasBloc(repo)..add(m.ReferenciasIniciou(100));
      await Future.delayed(const Duration(milliseconds: 20));
      bloc.add(ReferenciaMidiasReordenou(100, [3, 1, 2]));
      await Future.delayed(const Duration(milliseconds: 20));
      expect(repo.reordenacoes.single, [3, 1, 2]);
      expect(bloc.state.midias.map((m) => m.id), [3, 1, 2]);
      expect(bloc.state.midias.first.ePrincipal, isTrue);
    });

    test('falha ao reordenar mostra erro e mantém a ordem do servidor', () async {
      final repo = FakeMidiasRepo([midia(1, capa: true), midia(2)])..falha = Exception('ordem inválida');
      final bloc = novoMidiasBloc(repo)..add(m.ReferenciasIniciou(100));
      await Future.delayed(const Duration(milliseconds: 20));
      bloc.add(ReferenciaMidiasReordenou(100, [2, 1]));
      await Future.delayed(const Duration(milliseconds: 20));
      expect(bloc.state, isA<ReferenciaMidiasErro>());
      expect((bloc.state as ReferenciaMidiasErro).mensagem, 'ordem inválida');
      expect(bloc.state.midias.map((m) => m.id), [1, 2]);
    });

    test('upload da consulta envia estampa e validarAssociacao', () async {
      final repo = FakeMidiasRepo([]);
      final bloc = novoMidiasBloc(repo);
      bloc.add(ReferenciasMidiaAdicinou(
        100,
        [Imagem(bytes: Uint8List.fromList([1, 2, 3]), cor: 'Azul', estampa: 'Liso', tamanho: '*')],
        validarAssociacao: true,
      ));
      await Future.delayed(const Duration(milliseconds: 50));
      expect(repo.criadas.single, {'estampa': 'Liso', 'validar': true, 'cor': 'Azul', 'tamanho': '*'});
    });

    test('cadastro (sem validar) não envia validarAssociacao', () async {
      final repo = FakeMidiasRepo([]);
      final bloc = novoMidiasBloc(repo);
      bloc.add(ReferenciasMidiaAdicinou(100, [Imagem(bytes: Uint8List.fromList([1]))]));
      await Future.delayed(const Duration(milliseconds: 50));
      expect(repo.criadas.single['validar'], isFalse);
    });
  });

  group('modal de metadados', () {
    Future<ReferenciaMidiaMetadados?> abrir(WidgetTester t, List<Imagem> imagens) async {
      t.view.physicalSize = const Size(800, 1400);
      t.view.devicePixelRatio = 1;
      addTearDown(t.view.reset);
      ReferenciaMidiaMetadados? resultado;
      var fechou = false;
      await t.pumpWidget(MaterialApp(
        home: Builder(
          builder: (c) => TextButton(
            onPressed: () async {
              resultado = await ReferenciaMidiaMetadadosModal.show(c, imagens: imagens, opcoes: opcoes);
              fechou = true;
            },
            child: const Text('abrir'),
          ),
        ),
      ));
      await t.tap(find.text('abrir'));
      await t.pumpAndSettle();
      addTearDown(() => fechou);
      return resultado;
    }

    testWidgets('confirmar sem cor/estampa/tamanho não envia e mostra Obrigatório', (t) async {
      await abrir(t, [Imagem(path: 'a.jpg')]);
      await t.tap(find.text('Confirmar envio'));
      await t.pumpAndSettle();
      expect(find.text('Obrigatório'), findsWidgets);
      expect(find.text('Confirmar envio'), findsOneWidget);
    });

    testWidgets('"Aplicar a todas" aparece com várias fotos', (t) async {
      await abrir(t, [Imagem(path: 'a.jpg'), Imagem(path: 'b.jpg')]);
      expect(find.textContaining('Aplicar a todas'), findsOneWidget);
    });
  });
}
