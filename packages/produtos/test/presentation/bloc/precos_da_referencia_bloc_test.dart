import 'package:core/bloc_test.dart';
import 'package:core/precos_portas.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:produtos/presentation.dart';
import 'package:produtos/use_cases.dart';

class _FakePortaListar implements PortaListarPrecosDaReferenciaPorTabela {
  final List<PrecoDaReferenciaPorTabela> tabelas;
  _FakePortaListar(this.tabelas);
  @override
  Future<List<PrecoDaReferenciaPorTabela>> call({required int referenciaId}) async =>
      tabelas;
}

class _FakePortaSalvar implements PortaSalvarPrecoDaReferencia {
  bool? precoJaExisteRecebido;

  @override
  Future<PrecoDaReferenciaPorTabela> call({
    required int tabelaDePrecoId,
    required int referenciaId,
    required double valor,
    required bool precoJaExiste,
  }) async {
    precoJaExisteRecebido = precoJaExiste;
    return PrecoDaReferenciaPorTabela(
      tabelaDePrecoId: tabelaDePrecoId,
      tabelaNome: 'Varejo',
      tabelaInativa: false,
      tabelaPadrao: false,
      terminador: 0.90,
      valor: valor,
      atualizadoEm: DateTime(2026, 1, 1),
      operadorId: 7,
    );
  }
}

void main() {
  final tabelaVarejo = const PrecoDaReferenciaPorTabela(
    tabelaDePrecoId: 1,
    tabelaNome: 'Varejo',
    tabelaInativa: false,
    tabelaPadrao: true,
    terminador: 0.90,
    valor: null,
  );

  group('validarValor -', () {
    test('vazio exige informar o valor', () {
      expect(validarValor(''), 'Informe o valor');
    });

    test('mais de 2 casas decimais é rejeitado', () {
      expect(validarValor('45,321'), 'Use no máximo 2 casas decimais');
    });

    test('1 ou 2 casas decimais são aceitas', () {
      expect(validarValor('45,3'), isNull);
      expect(validarValor('45,32'), isNull);
      expect(validarValor('45'), isNull);
    });
  });

  group('calcularValorComTerminador -', () {
    test('substitui as casas decimais pelo terminador da tabela', () {
      expect(calcularValorComTerminador(45.32, 0.90), 45.90);
      expect(calcularValorComTerminador(45.00, 0.90), 45.90);
    });

    test('sem terminador retorna o valor digitado', () {
      expect(calcularValorComTerminador(45.32, null), 45.32);
    });
  });

  group('PrecosDaReferenciaBloc -', () {
    blocTest<PrecosDaReferenciaBloc, PrecosDaReferenciaState>(
      'mostra prévia do valor final com o terminador da tabela ao editar',
      build: () => PrecosDaReferenciaBloc(
        ListarPrecosDaReferenciaPorTabela(_FakePortaListar([tabelaVarejo])),
        SalvarPrecoDaReferencia(_FakePortaSalvar()),
      ),
      act: (bloc) async {
        bloc.add(PrecosDaReferenciaIniciou(referenciaId: 1));
        await Future<void>.delayed(Duration.zero);
        bloc.add(PrecosDaReferenciaEditouLinha(tabelaDePrecoId: 1));
        bloc.add(PrecosDaReferenciaValorAlterou(texto: '45,32'));
      },
      verify: (bloc) {
        expect(bloc.state.previaValorComTerminador, 45.90);
      },
    );

    late _FakePortaSalvar portaSalvarFake;

    blocTest<PrecosDaReferenciaBloc, PrecosDaReferenciaState>(
      'salva e atualiza a linha, saindo do modo de edição',
      build: () {
        portaSalvarFake = _FakePortaSalvar();
        return PrecosDaReferenciaBloc(
          ListarPrecosDaReferenciaPorTabela(_FakePortaListar([tabelaVarejo])),
          SalvarPrecoDaReferencia(portaSalvarFake),
        );
      },
      act: (bloc) async {
        bloc.add(PrecosDaReferenciaIniciou(referenciaId: 1));
        await Future<void>.delayed(Duration.zero);
        bloc.add(PrecosDaReferenciaEditouLinha(tabelaDePrecoId: 1));
        bloc.add(PrecosDaReferenciaValorAlterou(texto: '45,32'));
        bloc.add(PrecosDaReferenciaSalvou());
      },
      wait: const Duration(milliseconds: 10),
      verify: (bloc) {
        expect(bloc.state.tabelaEmEdicaoId, isNull);
        expect(bloc.state.tabelas.first.valor, 45.32);
        expect(bloc.state.totalComPreco, 1);
        // tabelaVarejo começa com valor: null (sem preço) -- tem que ir
        // pelo endpoint de criar, não de atualizar (que falha se não existir
        // ainda um preço pra essa tabela).
        expect(portaSalvarFake.precoJaExisteRecebido, isFalse);
      },
    );

    blocTest<PrecosDaReferenciaBloc, PrecosDaReferenciaState>(
      'salva atualizando quando a tabela já tinha preço',
      build: () {
        portaSalvarFake = _FakePortaSalvar();
        final tabelaComPreco = PrecoDaReferenciaPorTabela(
          tabelaDePrecoId: tabelaVarejo.tabelaDePrecoId,
          tabelaNome: tabelaVarejo.tabelaNome,
          tabelaInativa: tabelaVarejo.tabelaInativa,
          tabelaPadrao: tabelaVarejo.tabelaPadrao,
          terminador: tabelaVarejo.terminador,
          valor: 30.90,
        );
        return PrecosDaReferenciaBloc(
          ListarPrecosDaReferenciaPorTabela(
            _FakePortaListar([tabelaComPreco]),
          ),
          SalvarPrecoDaReferencia(portaSalvarFake),
        );
      },
      act: (bloc) async {
        bloc.add(PrecosDaReferenciaIniciou(referenciaId: 1));
        await Future<void>.delayed(Duration.zero);
        bloc.add(PrecosDaReferenciaEditouLinha(tabelaDePrecoId: 1));
        bloc.add(PrecosDaReferenciaValorAlterou(texto: '45,32'));
        bloc.add(PrecosDaReferenciaSalvou());
      },
      wait: const Duration(milliseconds: 10),
      verify: (bloc) {
        expect(portaSalvarFake.precoJaExisteRecebido, isTrue);
      },
    );

    blocTest<PrecosDaReferenciaBloc, PrecosDaReferenciaState>(
      'não salva com valor vazio e mostra erro de validação',
      build: () => PrecosDaReferenciaBloc(
        ListarPrecosDaReferenciaPorTabela(_FakePortaListar([tabelaVarejo])),
        SalvarPrecoDaReferencia(_FakePortaSalvar()),
      ),
      act: (bloc) async {
        bloc.add(PrecosDaReferenciaIniciou(referenciaId: 1));
        await Future<void>.delayed(Duration.zero);
        bloc.add(PrecosDaReferenciaEditouLinha(tabelaDePrecoId: 1));
        bloc.add(PrecosDaReferenciaSalvou());
      },
      verify: (bloc) {
        expect(bloc.state.erroValidacao, 'Informe o valor');
        expect(bloc.state.tabelaEmEdicaoId, 1);
      },
    );
  });
}
