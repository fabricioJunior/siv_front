import 'package:flutter_test/flutter_test.dart';
import 'package:produtos/data/remote/dtos/referencia_dto.dart';
import 'package:produtos/data/remote/dtos/referencia_midia_dto.dart';
import 'package:produtos/domain/data/repositorios/i_referencia_midias_repository.dart';
import 'package:produtos/models.dart';
import 'package:produtos/use_cases.dart';

class _RepoMidias implements IReferenciaMidiasRepository {
  _RepoMidias(this.midias);
  final List<ReferenciaMidia> midias;

  @override
  Future<List<ReferenciaMidia>> recuperarReferenciasMidias(int referenciaId) async =>
      midias;

  @override
  dynamic noSuchMethod(Invocation i) => throw UnimplementedError();
}

ReferenciaMidia _midia(int id, {String origem = 'site', bool principal = false}) =>
    ReferenciaMidia.create(
      id: id,
      url: 'u$id',
      referenciaId: 1,
      ePrincipal: principal,
      ePublica: origem == 'site',
      origem: origem,
    );

void main() {
  group('ReferenciaDto: referência esperada', () {
    test('lê fornecedor, reposição, previsão, quantidade e status calculado', () {
      final dto = ReferenciaDto.fromJson({
        'id': 1,
        'nome': 'Aurora',
        'fornecedorId': 7,
        'fornecedorNome': 'Duloren',
        'aguardandoReposicao': false,
        'previsaoChegada': '2026-12-01',
        'quantidadeEsperada': 24,
        'status': {'nova': true, 'aguardandoPrimeiraEntrada': true, 'aguardandoReposicao': false},
      });

      expect(dto.fornecedorId, 7);
      expect(dto.fornecedorNome, 'Duloren');
      expect(dto.previsaoChegada, DateTime(2026, 12, 1));
      expect(dto.quantidadeEsperada, 24);
      expect(dto.status!.nova, isTrue);
      expect(dto.status!.esperada, isTrue);
    });

    test('toJson devolve a previsão só com a data e nunca manda status nem nome do fornecedor', () {
      final json = ReferenciaDto(
        id: 1,
        nome: 'Aurora',
        fornecedorId: 7,
        fornecedorNome: 'Duloren',
        previsaoChegada: DateTime(2026, 12, 1, 15, 30),
        status: const ReferenciaStatusEntrada(nova: true),
      ).toJson();

      expect(json['previsaoChegada'], '2026-12-01');
      expect(json.containsKey('status'), isFalse);
      expect(json.containsKey('fornecedorNome'), isFalse);
    });

    test('resposta sem os campos novos continua válida', () {
      final dto = ReferenciaDto.fromJson({'id': 1, 'nome': 'Velha'});
      expect(dto.status, isNull);
      expect(dto.aguardandoReposicao, isNull);
    });

    test('EsperaReferencia: nulo limpa fornecedor/previsão/qtd; reposição só vai se informada', () {
      expect(const EsperaReferencia().toJson(), {
        'fornecedorId': null,
        'previsaoChegada': null,
        'quantidadeEsperada': null,
      });
      expect(
        EsperaReferencia(
          fornecedorId: 7,
          aguardandoReposicao: true,
          previsaoChegada: DateTime(2026, 12, 1),
          quantidadeEsperada: 10,
        ).toJson(),
        {
          'fornecedorId': 7,
          'aguardandoReposicao': true,
          'previsaoChegada': '2026-12-01',
          'quantidadeEsperada': 10,
        },
      );
    });
  });

  group('ReferenciaStatusEntrada', () {
    test('esperada = 1ª entrada ou reposição; Nova sozinha não é esperada', () {
      expect(const ReferenciaStatusEntrada(nova: true).esperada, isFalse);
      expect(const ReferenciaStatusEntrada(aguardandoPrimeiraEntrada: true).esperada, isTrue);
      expect(const ReferenciaStatusEntrada(aguardandoReposicao: true).esperada, isTrue);
      expect(const ReferenciaStatusEntrada().semStatus, isTrue);
    });
  });

  group('foto do fornecedor fica fora da galeria do site', () {
    test('mídia sem origem na resposta é do site', () {
      final dto = ReferenciaMidiaDto.fromJson({
        'id': 1,
        'url': 'u',
        'isDefault': false,
        'isPublic': true,
        'referenciaId': 1,
      });
      expect(dto.origem, 'site');
      expect(dto.doFornecedor, isFalse);
    });

    test('RecuperarReferenciaMidias devolve só as do site por padrão', () async {
      final caso = RecuperarReferenciaMidias(
        referenciaMidiasRepository: _RepoMidias([
          _midia(1, origem: 'fornecedor'),
          _midia(2, principal: true),
          _midia(3),
        ]),
      );

      final site = await caso.call(1);
      expect(site.map((m) => m.id), [2, 3]);

      final fornecedor = await caso.call(1, doFornecedor: true);
      expect(fornecedor.map((m) => m.id), [1]);
    });
  });
}
