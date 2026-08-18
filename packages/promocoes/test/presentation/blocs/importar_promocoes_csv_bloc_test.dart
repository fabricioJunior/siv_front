import 'dart:typed_data';

import 'package:core/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:promocoes/domain/data/repositories/i_importacao_promocoes_repository.dart';
import 'package:promocoes/models.dart';
import 'package:promocoes/presentation.dart';
import 'package:promocoes/use_cases.dart';

class StubImportacaoPromocoesRepository
    implements IImportacaoPromocoesRepository {
  final Future<ImportacaoPromocao> Function()? onImportar;

  StubImportacaoPromocoesRepository({this.onImportar});

  @override
  Future<Uint8List> baixarTemplateCsv() async => Uint8List(0);

  @override
  Future<ImportacaoPromocao> consultarImportacao(int id) async {
    throw UnimplementedError();
  }

  @override
  Future<ImportacaoPromocao> importarCsv({
    required String filePath,
    required String nome,
    required DateTime dataInicio,
    required DateTime dataFim,
    PromocaoCanal? canal,
  }) {
    return onImportar?.call() ??
        Future.value(
          const ImportacaoPromocao(
            id: 1,
            situacao: ImportacaoSituacao.concluida,
            totalRegistros: 0,
            processados: 0,
            importados: 0,
            rejeitados: 0,
          ),
        );
  }
}

void main() {
  ImportarPromocoesCsvBloc criarBloc({
    StubImportacaoPromocoesRepository? repository,
  }) {
    final repo = repository ?? StubImportacaoPromocoesRepository();
    return ImportarPromocoesCsvBloc(
      BaixarTemplatePromocoesCsv(repository: repo),
      ImportarPromocoesCsv(repository: repo),
      ConsultarImportacaoPromocao(repository: repo),
    );
  }

  blocTest<ImportarPromocoesCsvBloc, ImportarPromocoesCsvState>(
    'bloqueia envio quando faltam campos obrigatórios',
    build: () => criarBloc(),
    act: (bloc) => bloc.add(ImportarPromocoesEnviou()),
    expect: () => [
      isA<ImportarPromocoesCsvState>().having(
        (s) => s.step,
        'step',
        ImportarPromocoesCsvStep.validacaoInvalida,
      ),
    ],
  );

  blocTest<ImportarPromocoesCsvBloc, ImportarPromocoesCsvState>(
    'bloqueia envio quando dataFim é anterior à dataInicio',
    build: () => criarBloc(),
    act: (bloc) {
      bloc.add(
        ImportarPromocoesCampoAlterado(
          nome: 'Liquidação',
          dataInicio: DateTime(2026, 2, 1),
          dataFim: DateTime(2026, 1, 1),
          arquivoPath: '/tmp/promocoes.csv',
        ),
      );
      bloc.add(ImportarPromocoesEnviou());
    },
    skip: 1,
    expect: () => [
      isA<ImportarPromocoesCsvState>().having(
        (s) => s.step,
        'step',
        ImportarPromocoesCsvStep.validacaoInvalida,
      ),
    ],
  );

  blocTest<ImportarPromocoesCsvBloc, ImportarPromocoesCsvState>(
    'importa com sucesso quando a importação já vem concluída (sem polling)',
    build: () => criarBloc(),
    act: (bloc) {
      bloc.add(
        ImportarPromocoesCampoAlterado(
          nome: 'Liquidação',
          dataInicio: DateTime(2026, 1, 1),
          dataFim: DateTime(2026, 1, 31),
          arquivoPath: '/tmp/promocoes.csv',
        ),
      );
      bloc.add(ImportarPromocoesEnviou());
    },
    skip: 1,
    expect: () => [
      isA<ImportarPromocoesCsvState>().having(
        (s) => s.step,
        'step',
        ImportarPromocoesCsvStep.enviando,
      ),
      isA<ImportarPromocoesCsvState>().having(
        (s) => s.step,
        'step',
        ImportarPromocoesCsvStep.processando,
      ),
      isA<ImportarPromocoesCsvState>().having(
        (s) => s.step,
        'step',
        ImportarPromocoesCsvStep.concluido,
      ),
    ],
  );
}
