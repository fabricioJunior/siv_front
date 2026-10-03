import 'package:flutter_test/flutter_test.dart';
import 'package:produtos/domain/referencias_filtro.dart';
import 'package:produtos/models.dart';

Referencia ref({
  int id = 1,
  String? externo,
  String? ncm = '61091000',
  int? peso = 200,
}) => Referencia.create(
  id: id,
  nome: 'X',
  idExterno: externo,
  ncm: ncm,
  pesoGramas: peso,
);

void main() {
  group('ReferenciasFiltro (valor do filtro; quem filtra é o servidor)', () {
    test('"ativo" só é verdadeiro quando há algum filtro', () {
      expect(const ReferenciasFiltro().ativo, isFalse);
      expect(const ReferenciasFiltro(busca: '   ').ativo, isFalse);
      expect(const ReferenciasFiltro(busca: 'x').ativo, isTrue);
      expect(const ReferenciasFiltro(categoriaId: 1).ativo, isTrue);
      expect(const ReferenciasFiltro(semNcm: true).ativo, isTrue);
      expect(const ReferenciasFiltro(semPeso: true).ativo, isTrue);
    });

    test('copyWith mantém o resto e limpa a categoria com null', () {
      const base = ReferenciasFiltro(busca: 'a', categoriaId: 3, semPeso: true);

      expect(base.copyWith(busca: 'b').categoriaId, 3);
      expect(base.copyWith(categoriaId: null).categoriaId, isNull);
      expect(base.copyWith(semNcm: true).semPeso, isTrue);
    });

    test(
      'dois filtros iguais são iguais (o bloc só emite quando algo muda)',
      () {
        expect(
          const ReferenciasFiltro(busca: 'a', categoriaId: 1),
          const ReferenciasFiltro(busca: 'a', categoriaId: 1),
        );
        expect(
          const ReferenciasFiltro(busca: 'a'),
          isNot(const ReferenciasFiltro(busca: 'b')),
        );
      },
    );
  });

  group('regras das etiquetas (as mesmas do servidor)', () {
    test('sem NCM: nulo, vazio ou fora do padrão de 8 dígitos', () {
      expect(ReferenciasFiltro.semNcmDe(ref(ncm: null)), isTrue);
      expect(ReferenciasFiltro.semNcmDe(ref(ncm: '  ')), isTrue);
      expect(ReferenciasFiltro.semNcmDe(ref(ncm: '6109.10.00')), isTrue);
      expect(ReferenciasFiltro.semNcmDe(ref(ncm: '1234567')), isTrue);
      expect(ReferenciasFiltro.semNcmDe(ref(ncm: '61091000')), isFalse);
    });

    test('sem peso: nulo ou zero', () {
      expect(ReferenciasFiltro.semPesoDe(ref(peso: null)), isTrue);
      expect(ReferenciasFiltro.semPesoDe(ref(peso: 0)), isTrue);
      expect(ReferenciasFiltro.semPesoDe(ref(peso: 1)), isFalse);
    });

    test('número exibido: ID externo, senão o ID interno', () {
      expect(ReferenciasFiltro.numeroDe(ref(id: 7, externo: '1001')), '1001');
      expect(ReferenciasFiltro.numeroDe(ref(id: 7, externo: '  ')), '7');
      expect(ReferenciasFiltro.numeroDe(ref(id: 7)), '7');
    });
  });
}
