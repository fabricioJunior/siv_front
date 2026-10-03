import 'package:core/sync.dart' show ImportacaoProgressoEvent;
import 'package:flutter_test/flutter_test.dart';
import 'package:importacao/domain/models/importacao_guiada.dart';

void main() {
  group('ImportacaoGuiada.fromJson', () {
    test(
      'lê a entidade do backend (situação em minúsculas, como vem do banco)',
      () {
        final importacao = ImportacaoGuiada.fromJson({
          'id': 7,
          'tipo': 'Estoque',
          'situacao': 'concluida',
          'totalRegistros': 4000,
          'processados': 4000,
          'importados': 3970,
          'rejeitados': 30,
          'erro': null,
        });

        expect(importacao.id, 7);
        expect(importacao.tipo, 'estoque');
        expect(importacao.situacao, ImportacaoSituacao.concluida);
        expect([importacao.importados, importacao.rejeitados], [3970, 30]);
        expect(importacao.problemas, isEmpty);
      },
    );

    test(
      'rejeições por linha e por venda viram problemas com título e motivo',
      () {
        final importacao = ImportacaoGuiada.fromJson({
          'id': 1,
          'tipo': 'cliente',
          'situacao': 'concluida',
          'resultado': {
            'rejeitados': [
              {'linha': 9, 'motivo': 'CPF inválido', 'conteudo': 'Ana;123'},
              {'numeroVendaExterno': 5001, 'motivo': 'Venda já importada'},
              {'motivo': 'sem identificação'},
            ],
          },
        });

        expect(importacao.problemas, const [
          ImportacaoProblema(
            titulo: 'Linha 9',
            motivo: 'CPF inválido',
            conteudo: 'Ana;123',
          ),
          ImportacaoProblema(
            titulo: 'Venda 5001',
            motivo: 'Venda já importada',
          ),
          ImportacaoProblema(titulo: 'Registro', motivo: 'sem identificação'),
        ]);
      },
    );

    test('vendas com CPF sem cadastro geram um aviso', () {
      final importacao = ImportacaoGuiada.fromJson({
        'id': 2,
        'tipo': 'VendaRomaneio',
        'situacao': 'concluida',
        'resultado': {'semClienteCadastrado': 3},
      });

      expect(importacao.avisos.single, contains('3 venda(s)'));
      expect(importacao.avisos.single, contains('Cliente não cadastrado'));
    });

    test('situação desconhecida cai em pendente', () {
      expect(ImportacaoSituacao.fromString('???'), ImportacaoSituacao.pendente);
      expect(ImportacaoSituacao.fromString(null), ImportacaoSituacao.pendente);
      expect(
        ImportacaoSituacao.fromString('Concluida'),
        ImportacaoSituacao.concluida,
      );
    });
  });

  group('andamento', () {
    test(
      'fração só existe quando o total é conhecido e nunca passa de 100%',
      () {
        const sem = ImportacaoGuiada(
          id: 1,
          tipo: 'cliente',
          situacao: ImportacaoSituacao.processando,
        );
        expect(sem.fracao, isNull);
        expect(
          const ImportacaoGuiada(
            id: 1,
            tipo: 'x',
            situacao: ImportacaoSituacao.processando,
            totalRegistros: 200,
            processados: 50,
          ).fracao,
          0.25,
        );
        expect(
          const ImportacaoGuiada(
            id: 1,
            tipo: 'x',
            situacao: ImportacaoSituacao.processando,
            totalRegistros: 10,
            processados: 12,
          ).fracao,
          1.0,
        );
      },
    );

    test(
      'comProgresso atualiza os números e preserva as rejeições já carregadas',
      () {
        const antes = ImportacaoGuiada(
          id: 4,
          tipo: 'estoque',
          situacao: ImportacaoSituacao.processando,
          problemas: [ImportacaoProblema(titulo: 'Linha 2', motivo: 'x')],
        );

        final depois = antes.comProgresso(
          const ImportacaoProgressoEvent(
            id: 4,
            tipo: 'estoque',
            situacao: 'concluida',
            totalRegistros: 10,
            processados: 10,
            importados: 9,
            rejeitados: 1,
          ),
        );

        expect(depois.situacao, ImportacaoSituacao.concluida);
        expect(
          [depois.totalRegistros, depois.importados, depois.rejeitados],
          [10, 9, 1],
        );
        expect(depois.problemas, antes.problemas);
      },
    );

    test(
      'deEvento cria a importação quando ela nasceu em outro lugar (ex.: outro aparelho)',
      () {
        final importacao = ImportacaoGuiada.deEvento(
          const ImportacaoProgressoEvent(
            id: 12,
            tipo: 'cliente',
            situacao: 'processando',
            totalRegistros: 100,
            processados: 5,
          ),
        );

        expect(importacao.id, 12);
        expect(importacao.situacao, ImportacaoSituacao.processando);
        expect(importacao.processados, 5);
      },
    );
  });

  group('ImportacaoEtapa', () {
    test(
      'ordem do assistente: clientes, referencias, precos, produtos, estoque, vendas',
      () {
        expect(ImportacaoEtapa.values.map((e) => e.name), [
          'clientes',
          'referencias',
          'precos',
          'produtos',
          'estoque',
          'vendas',
        ]);
        expect(ImportacaoEtapa.clientes.anterior, isNull);
        expect(ImportacaoEtapa.precos.anterior, ImportacaoEtapa.referencias);
        expect(ImportacaoEtapa.produtos.anterior, ImportacaoEtapa.precos);
        expect(ImportacaoEtapa.vendas.anterior, ImportacaoEtapa.estoque);
      },
    );

    test(
      'deTipo ignora maiúsculas e devolve null para tipos fora do assistente',
      () {
        expect(ImportacaoEtapa.deTipo('VendaRomaneio'), ImportacaoEtapa.vendas);
        expect(ImportacaoEtapa.deTipo('ESTOQUE'), ImportacaoEtapa.estoque);
        expect(
          ImportacaoEtapa.deTipo('Referencia'),
          ImportacaoEtapa.referencias,
        );
        expect(
          ImportacaoEtapa.deTipo('ReferenciaPreco'),
          ImportacaoEtapa.precos,
        );
      },
    );

    test('toda etapa tem permissão própria e o conjunto cobre as 6', () {
      expect(ImportacaoEtapa.todasPermissoes, [
        'IMPFP006',
        'IMPFP004',
        'IMPFP002',
        'IMPFP005',
        'IMPFP009',
        'IMPFP008',
      ]);
    });
  });
}
