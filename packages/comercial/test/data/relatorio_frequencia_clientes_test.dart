import 'package:comercial/data/fake/relatorio_frequencia_clientes_repository_fake.dart';
import 'package:comercial/data/remote/dtos/relatorio_dto.dart';
import 'package:comercial/data/remote/dtos/relatorio_frequencia_clientes_dto.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parse F1', () {
    final r = frequenciaClientesFromJson({
      'resumo': {
        'clientes': 843,
        'valorTotal': 296153.61,
        'visitasPorCliente': 1.7,
        'intervaloMedioDias': 43.9,
        'ticketMedio': 201.19,
        'atrasados': 124,
        'percentualUmaVisita': 65.6,
        'vendasSemCliente': {'valor': 41493.88, 'percentualFaturamento': 12.3},
        'classes': [
          {'classe': 'A', 'clientes': 389, 'percentualClientes': 46.1, 'valor': 237108.83, 'percentualFaturamento': 80.1},
        ],
        'curva': [
          {'percentualClientes': 0, 'percentualFaturamento': 0},
          {'percentualClientes': 2.5, 'percentualFaturamento': 18.3},
        ],
        'distribuicaoVisitas': [
          {'faixa': '1', 'A': 145, 'B': 217, 'C': 191},
        ],
        'parametros': {'corteA': 80, 'corteB': 95, 'fatorAtraso': 2, 'minimoVisitasAtraso': 3},
      },
      'items': [
        {
          'rank': 1, 'clienteId': 53, 'nome': 'MARCIA A. B.', 'telefone': '(86) 9****-3933',
          'documento': '***.316.423-**', 'classe': 'A', 'visitas': 13,
          'primeiraCompra': '2025-10-01', 'ultimaCompra': '2026-03-31', 'diasDesdeUltima': 201,
          'intervaloMedioDias': 15.1, 'valor': 5283.4, 'ticketMedio': 406.42,
          'percentualAcumulado': 1.8, 'atrasado': true, 'proximaCompraEsperada': '2026-04-15',
          'categoriaPreferida': 'BLUSA', 'pagamentoPreferido': null,
        },
        {'rank': 2, 'clienteId': 9, 'nome': 'X', 'classe': 'C', 'visitas': 1, 'intervaloMedioDias': null, 'proximaCompraEsperada': null},
      ],
      'meta': {'totalItems': 843, 'itemCount': 2, 'itemsPerPage': 2, 'totalPages': 422, 'currentPage': 1},
    });
    expect(r.resumo.clientes, 843);
    expect(r.resumo.vendasSemCliente.percentualFaturamento, 12.3);
    expect(r.resumo.distribuicaoVisitas.single.b, 217);
    expect(r.resumo.curva.last.percentualFaturamento, 18.3);
    expect(r.items.first.atrasado, isTrue);
    expect(r.items.first.pagamentoPreferido, isNull);
    expect(r.items.last.intervaloMedioDias, isNull);
    expect(r.items.last.proximaCompraEsperada, isNull);
    expect(r.meta.totalPages, 422);
  });

  test('parse F2 com e sem campos novos', () {
    final novo = RelatorioClienteComprasDto.fromJson({
      'clienteId': 53,
      'totalNoPeriodo': 19,
      'items': [
        {'romaneioId': 9705, 'empresaId': 1, 'empresaNome': 'V', 'data': '2026-03-31', 'valorLiquido': 69, 'numeroCupom': '9705', 'quantidadeItens': 1, 'formaPagamento': null},
      ],
    });
    expect(novo.totalNoPeriodo, 19);
    expect(novo.items.single.numeroCupom, '9705');
    expect(novo.items.single.quantidadeItens, 1);
    expect(novo.items.single.formaPagamento, isNull);
    final velho = RelatorioClienteComprasDto.fromJson({
      'items': [
        {'romaneioId': 1, 'empresaId': 1, 'empresaNome': 'V', 'data': '2026-03-31', 'valorLiquido': 5.5},
      ],
    });
    expect(velho.totalNoPeriodo, isNull);
    expect(velho.items.single.numeroCupom, isNull);
  });

  test('fake: filtro por classe, atrasados e paginação', () async {
    final repo = FrequenciaClientesRepositoryFake();
    final r = await repo.frequenciaClientes(
        empresaIds: [1], dataInicial: '2026-01-01', dataFinal: '2026-03-31',
        classe: 'B', limit: 5, page: 2);
    expect(r.items.length, 5);
    expect(r.items.every((e) => e.classe == 'B'), isTrue);
    expect(r.meta.totalItems, 16);
    expect(r.meta.totalPages, 4);
    final d = await repo.frequenciaClientes(
        empresaIds: [1], dataInicial: 'a', dataFinal: 'b',
        atrasados: true, ordenarPor: 'valor', ordem: 'desc');
    expect(d.items.every((e) => e.atrasado), isTrue);
    expect(d.items.first.valor >= d.items.last.valor, isTrue);
  });
}
