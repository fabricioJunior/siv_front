import 'package:flutter_test/flutter_test.dart';
import 'package:produtos/data/remote/dtos/categoria_dto.dart';
import 'package:produtos/domain/referencias_filtro.dart';
import 'package:produtos/models.dart';

Referencia ref(
  int id,
  String nome, {
  String? externo,
  int? categoriaId,
  String? categoria,
  String? ncm = '61091000',
  int? peso = 200,
}) => Referencia.create(
  id: id,
  nome: nome,
  idExterno: externo,
  categoriaId: categoriaId,
  categoria: categoriaId == null
      ? null
      : CategoriaDto(
          id: categoriaId,
          nome: categoria ?? 'Cat $categoriaId',
          inativa: false,
        ),
  ncm: ncm,
  pesoGramas: peso,
);

void main() {
  final todas = [
    ref(
      1,
      'Camisa Básica',
      externo: '1001',
      categoriaId: 10,
      categoria: 'Camisas',
    ),
    ref(
      2,
      'CAMISÁ Polo',
      externo: '1002',
      categoriaId: 10,
      categoria: 'Camisas',
      ncm: null,
    ),
    ref(
      3,
      'Calça Jeans',
      externo: '2001',
      categoriaId: 20,
      categoria: 'Calças',
      peso: null,
    ),
    ref(
      4,
      'Vestido Longo',
      categoriaId: 30,
      categoria: 'Vestidos',
      ncm: '  ',
      peso: 0,
    ),
    ref(5, 'Sem categoria'),
  ];
  const vazio = ReferenciasFiltro();

  group('busca', () {
    test('ignora maiúsculas e acentos ("camisa" acha "CAMISÁ")', () {
      final r = const ReferenciasFiltro(busca: 'camisa').aplicar(todas);

      expect(r.map((e) => e.id), [1, 2]);
    });

    test(
      'acha pelo nº da referência (ID externo) e, se não houver, pelo ID interno',
      () {
        expect(
          const ReferenciasFiltro(
            busca: '2001',
          ).aplicar(todas).map((e) => e.id),
          [3],
        );
        expect(
          const ReferenciasFiltro(busca: '4').aplicar(todas).map((e) => e.id),
          [4],
        );
      },
    );

    test('espaços nas pontas são ignorados e busca vazia não filtra', () {
      expect(
        const ReferenciasFiltro(
          busca: '  jeans ',
        ).aplicar(todas).map((e) => e.id),
        [3],
      );
      expect(vazio.aplicar(todas), todas);
    });

    test('número exibido: ID externo, senão ID interno', () {
      expect(ReferenciasFiltro.numeroDe(todas[0]), '1001');
      expect(ReferenciasFiltro.numeroDe(todas[3]), '4');
    });
  });

  group('categoria e pendências', () {
    test('filtra por categoria (pelo objeto ou só pelo id)', () {
      expect(
        const ReferenciasFiltro(
          categoriaId: 10,
        ).aplicar(todas).map((e) => e.id),
        [1, 2],
      );
      final soId = Referencia.create(id: 9, nome: 'X', categoriaId: 20);
      expect(
        const ReferenciasFiltro(categoriaId: 20).aplicar([soId]).single.id,
        9,
      );
    });

    test('"Sem NCM" pega nulo e só espaços; "Sem peso" pega nulo e zero', () {
      expect(
        const ReferenciasFiltro(semNcm: true).aplicar(todas).map((e) => e.id),
        [2, 4],
      );
      expect(
        const ReferenciasFiltro(semPeso: true).aplicar(todas).map((e) => e.id),
        [3, 4],
      );
    });

    test('as duas pendências juntas exigem as duas (E)', () {
      final r = const ReferenciasFiltro(
        semNcm: true,
        semPeso: true,
      ).aplicar(todas);

      expect(r.map((e) => e.id), [4]);
    });

    test('combina busca, categoria e pendência', () {
      final r = const ReferenciasFiltro(
        busca: 'camisa',
        categoriaId: 10,
        semNcm: true,
      ).aplicar(todas);

      expect(r.map((e) => e.id), [2]);
    });
  });

  group('contagens', () {
    test(
      'pendências contam sobre busca + categoria, não sobre elas mesmas',
      () {
        final c = const ReferenciasFiltro(semNcm: true).contar(todas);

        expect(c.semNcm, 2); // 2 (nulo) e 4 (só espaços)
        expect(c.semPeso, 2); // 3 (nulo) e 4 (zero)
      },
    );

    test('contagem respeita a categoria escolhida', () {
      final c = const ReferenciasFiltro(categoriaId: 10).contar(todas);

      expect(c.semNcm, 1);
      expect(c.semPeso, 0);
    });

    test(
      'contagem por categoria ignora a categoria escolhida mas respeita busca e pendências',
      () {
        expect(
          const ReferenciasFiltro(categoriaId: 10).contarPorCategoria(todas),
          {10: 2, 20: 1, 30: 1},
        );
        expect(
          const ReferenciasFiltro(semPeso: true).contarPorCategoria(todas),
          {20: 1, 30: 1},
        );
        expect(
          const ReferenciasFiltro(busca: 'camisa').contarPorCategoria(todas),
          {10: 2},
        );
      },
    );

    test(
      'categorias presentes em ordem alfabética sem acento, só as que têm nome',
      () {
        expect(ReferenciasFiltro.categoriasDe(todas).map((c) => c.nome), [
          'Calças',
          'Camisas',
          'Vestidos',
        ]);
      },
    );
  });

  test(
    '"ativo" só é verdadeiro quando há algum filtro e copyWith limpa a categoria com null',
    () {
      expect(vazio.ativo, isFalse);
      expect(const ReferenciasFiltro(busca: '  ').ativo, isFalse);
      expect(const ReferenciasFiltro(categoriaId: 1).ativo, isTrue);
      expect(const ReferenciasFiltro(semPeso: true).ativo, isTrue);
      expect(
        const ReferenciasFiltro(
          categoriaId: 1,
        ).copyWith(categoriaId: null).categoriaId,
        isNull,
      );
      expect(
        const ReferenciasFiltro(
          categoriaId: 1,
        ).copyWith(busca: 'x').categoriaId,
        1,
      );
    },
  );
}
