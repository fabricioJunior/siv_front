import 'dart:typed_data';

import 'package:comercial/domain/data/repositories/i_importacao_venda_repository.dart';
import 'package:comercial/models.dart';
import 'package:comercial/presentation.dart';
import 'package:comercial/use_cases.dart';
import 'package:core/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';

class _RepositorioFake implements IImportacaoVendaRepository {
  final List<ImportacaoVenda> respostas;
  final consultas = <int>[];
  ({String filePath, int tabelaDePrecoId, int funcionarioId})? enviado;

  _RepositorioFake(this.respostas);

  @override
  Future<Uint8List> baixarTemplateCsv() async => Uint8List(0);

  @override
  Future<ImportacaoVenda> importarCsv({
    required String filePath,
    required int tabelaDePrecoId,
    required int funcionarioId,
  }) async {
    enviado = (filePath: filePath, tabelaDePrecoId: tabelaDePrecoId, funcionarioId: funcionarioId);
    return respostas.first;
  }

  @override
  Future<ImportacaoVenda> consultarImportacao(int id) async {
    consultas.add(id);
    return respostas.last;
  }
}

ImportarVendasCsvBloc _bloc(_RepositorioFake repo) => ImportarVendasCsvBloc(
      BaixarTemplateImportacaoVendas(repository: repo),
      ImportarVendasCsv(repository: repo),
      ConsultarImportacaoVenda(repository: repo),
    );

const _pronto = ImportarVendasCsvState(
  tabelaDePrecoId: 4,
  funcionarioId: 9,
  arquivoPath: '/tmp/vendas.csv',
  arquivoNome: 'vendas.csv',
  step: ImportarVendasCsvStep.editando,
);

void main() {
  test('só pode enviar com tabela, funcionário e arquivo', () {
    const sem = ImportarVendasCsvState(step: ImportarVendasCsvStep.editando);

    expect(sem.podeEnviar, isFalse);
    expect(sem.copyWith(tabelaDePrecoId: 1, arquivoPath: 'a.csv').podeEnviar, isFalse);
    expect(_pronto.podeEnviar, isTrue);
  });

  blocTest<ImportarVendasCsvBloc, ImportarVendasCsvState>(
    'enviar sem funcionário avisa e não chama a API',
    build: () => _bloc(_RepositorioFake([const ImportacaoVenda(id: 1, situacao: ImportacaoSituacao.pendente)])),
    seed: () => const ImportarVendasCsvState(
      tabelaDePrecoId: 4,
      arquivoPath: '/tmp/vendas.csv',
      step: ImportarVendasCsvStep.editando,
    ),
    act: (bloc) => bloc.add(ImportarVendasEnviou()),
    expect: () => [
      isA<ImportarVendasCsvState>()
          .having((s) => s.step, 'step', ImportarVendasCsvStep.validacaoInvalida)
          .having((s) => s.erro, 'erro', contains('funcionário')),
    ],
  );

  blocTest<ImportarVendasCsvBloc, ImportarVendasCsvState>(
    'envia com os três parâmetros e conclui quando a importação já volta finalizada',
    build: () {
      final concluida = ImportacaoVenda(
        id: 5,
        situacao: ImportacaoSituacao.concluida,
        resultado: const ImportacaoVendaResultado(totalRecebidos: 2, importados: 2, itensImportados: 3),
      );
      return _bloc(_RepositorioFake([concluida]));
    },
    seed: () => _pronto,
    act: (bloc) => bloc.add(ImportarVendasEnviou()),
    expect: () => [
      isA<ImportarVendasCsvState>().having((s) => s.step, 'step', ImportarVendasCsvStep.enviando),
      isA<ImportarVendasCsvState>().having((s) => s.step, 'step', ImportarVendasCsvStep.processando),
      isA<ImportarVendasCsvState>()
          .having((s) => s.step, 'step', ImportarVendasCsvStep.concluido)
          .having((s) => s.importacao?.resultado?.importados, 'importados', 2),
    ],
  );

  blocTest<ImportarVendasCsvBloc, ImportarVendasCsvState>(
    'consulta o status (polling) até a importação finalizar',
    build: () => _bloc(
      _RepositorioFake([
        const ImportacaoVenda(id: 6, situacao: ImportacaoSituacao.pendente),
        const ImportacaoVenda(id: 6, situacao: ImportacaoSituacao.concluida, resultado: ImportacaoVendaResultado(totalRecebidos: 1, importados: 1)),
      ]),
    ),
    seed: () => _pronto,
    act: (bloc) => bloc.add(ImportarVendasEnviou()),
    wait: const Duration(seconds: 3),
    verify: (bloc) {
      expect(bloc.state.step, ImportarVendasCsvStep.concluido);
      expect(bloc.state.importacao?.id, 6);
    },
  );
}
