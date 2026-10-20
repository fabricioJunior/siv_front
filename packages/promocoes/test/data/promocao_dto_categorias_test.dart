import 'package:flutter_test/flutter_test.dart';
import 'package:promocoes/data.dart';
import 'package:promocoes/models.dart';

void main() {
  Map<String, dynamic> jsonBase() => {
        'id': 7,
        'nome': 'Promo calças',
        'dataInicio': '2026-01-01',
        'dataFim': '2026-01-31',
        'tipoDesconto': 'percentual',
        'valorPercentual': 10,
        'tipoEscopo': 'categorias',
      };

  test('le categorias, excecoes e referenciaIds resolvidos', () {
    final dto = PromocaoDto.fromJson({
      ...jsonBase(),
      'categorias': [
        {'categoriaId': 1},
        {'categoriaId': 2, 'subCategoriaId': 30},
      ],
      'excecaoReferenciaIds': [100, 101],
      'referenciaIds': [500, 501, 502],
    });

    expect(dto.tipoEscopo, TipoEscopo.categorias);
    expect(dto.categorias, const [
      PromocaoCategoria(categoriaId: 1),
      PromocaoCategoria(categoriaId: 2, subCategoriaId: 30),
    ]);
    expect(dto.excecaoReferenciaIds, [100, 101]);
    expect(dto.referenciaIds, [500, 501, 502]);
  });

  test('API sem os campos novos = escopo inexistente, sem quebrar', () {
    final dto = PromocaoDto.fromJson({
      ...jsonBase(),
      'tipoEscopo': 'referencias',
      'referenciaIds': [1],
    });

    expect(dto.categorias, isNull);
    expect(dto.excecaoReferenciaIds, isNull);
    expect(dto.toCreateJson().containsKey('categorias'), isFalse);
    expect(dto.toCreateJson().containsKey('excecaoReferenciaIds'), isFalse);
  });

  test('payload envia categorias e excecoes, mas nao referenciaIds resolvidos',
      () {
    final json = PromocaoDto.fromJson({
      ...jsonBase(),
      'categorias': [
        {'categoriaId': 2, 'subCategoriaId': 30},
      ],
      'excecaoReferenciaIds': [100],
      'referenciaIds': [500, 501],
    }).toCreateJson();

    expect(json['tipoEscopo'], 'categorias');
    expect(json['categorias'], [
      {'categoriaId': 2, 'subCategoriaId': 30},
    ]);
    expect(json['excecaoReferenciaIds'], [100]);
    expect(json.containsKey('referenciaIds'), isFalse);
  });

  test('fromModel preserva categorias e excecoes', () {
    final promocao = Promocao.create(
      nome: 'Promo',
      dataInicio: DateTime(2026, 1, 1),
      dataFim: DateTime(2026, 1, 31),
      tipoDesconto: TipoDesconto.percentual,
      valorPercentual: 10,
      tipoEscopo: TipoEscopo.categorias,
      categorias: const [PromocaoCategoria(categoriaId: 3)],
      excecaoReferenciaIds: const [9],
      unidadesVendidas: 0,
      somenteAniversariante: false,
      canal: PromocaoCanal.ambos,
      ativa: true,
      restringirFormasPagamento: false,
      formasPagamento: const [],
    );

    final dto = PromocaoDto.fromModel(promocao);

    expect(dto.categorias, const [PromocaoCategoria(categoriaId: 3)]);
    expect(dto.excecaoReferenciaIds, const [9]);
  });
}
