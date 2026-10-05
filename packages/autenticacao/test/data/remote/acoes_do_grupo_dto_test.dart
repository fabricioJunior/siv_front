import 'package:autenticacao/data/remote/dtos/acoes_do_grupo_dto.dart';
import 'package:autenticacao/domain/models/acoes_do_grupo.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('converte fluxos, ações e estados da resposta de /acoes', () {
    final resultado = acoesDoGrupoFromJson({
      'grupoId': 3,
      'componentesAvulsos': ['RELFC001'],
      'fluxos': [
        {
          'id': 'venda',
          'nome': 'Venda',
          'descricao': 'Montar a venda',
          'acoes': [
            {
              'id': 'venda.vender',
              'nome': 'Fazer venda',
              'descricao': 'Abre a venda',
              'requer': <String>[],
              'componentes': ['ROMFP001', 'PESFC001'],
              'estado': 'incompleta',
              'faltando': ['PESFC001'],
            },
            {
              'id': 'venda.frete',
              'nome': 'Lançar frete',
              'descricao': '',
              'requer': ['venda.vender'],
              'componentes': ['ROMFP003'],
              'estado': 'desligada',
              'faltando': <String>[],
            },
          ],
        },
      ],
    });

    expect(resultado.grupoId, 3);
    expect(resultado.componentesAvulsos, ['RELFC001']);
    final venda = resultado.fluxos.single;
    expect(venda.acoes.map((a) => a.estado), [
      EstadoAcaoDoGrupo.incompleta,
      EstadoAcaoDoGrupo.desligada,
    ]);
    expect(venda.acoes.first.faltando, ['PESFC001']);
    expect(venda.acoes.last.requer, ['venda.vender']);
    expect(venda.acoesLigadas, 1);
  });

  test('estado desconhecido vira desligada (servidor mais novo que o app)', () {
    final resultado = acoesDoGrupoFromJson({
      'grupoId': 1,
      'componentesAvulsos': <String>[],
      'fluxos': [
        {
          'id': 'f',
          'nome': 'F',
          'descricao': '',
          'acoes': [
            {
              'id': 'f.a',
              'nome': 'A',
              'descricao': '',
              'requer': <String>[],
              'componentes': <String>[],
              'estado': 'novo_estado',
              'faltando': <String>[],
            },
          ],
        },
      ],
    });
    expect(resultado.fluxos.single.acoes.single.estado, EstadoAcaoDoGrupo.desligada);
  });
}
