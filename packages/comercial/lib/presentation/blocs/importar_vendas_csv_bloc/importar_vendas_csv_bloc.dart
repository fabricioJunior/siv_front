import 'dart:async';

import 'package:comercial/domain/models/importacao_venda.dart';
import 'package:comercial/use_cases.dart';
import 'package:core/arquivos.dart';
import 'package:core/bloc.dart';
import 'package:core/equals.dart';
import 'package:core/injecoes.dart';
import 'package:core/remote_data_sourcers.dart';

part 'importar_vendas_csv_event.dart';
part 'importar_vendas_csv_state.dart';

class ImportarVendasCsvBloc
    extends Bloc<ImportarVendasCsvEvent, ImportarVendasCsvState> {
  final BaixarTemplateImportacaoVendas _baixarTemplateCsv;
  final ImportarVendasCsv _importarCsv;
  final ConsultarImportacaoVenda _consultarImportacao;

  // ponytail: polling simples de status (a cada 2s por até 30s), mesmo
  // padrão do import de pedidos/promoções -- arquivo grande passa pra
  // "processando em segundo plano"; upgrade pra push se o volume justificar.
  static const _intervaloPolling = Duration(seconds: 2);
  static const _maxTentativasPolling = 15;

  ImportarVendasCsvBloc(
    this._baixarTemplateCsv,
    this._importarCsv,
    this._consultarImportacao,
  ) : super(const ImportarVendasCsvState(step: ImportarVendasCsvStep.editando)) {
    on<ImportarVendasTabelaAlterada>(_onTabelaAlterada);
    on<ImportarVendasFuncionarioAlterado>(_onFuncionarioAlterado);
    on<ImportarVendasArquivoSelecionado>(_onArquivoSelecionado);
    on<ImportarVendasBaixouTemplate>(_onBaixouTemplate);
    on<ImportarVendasEnviou>(_onEnviou);
  }

  FutureOr<void> _onTabelaAlterada(
    ImportarVendasTabelaAlterada event,
    Emitter<ImportarVendasCsvState> emit,
  ) {
    emit(
      state.copyWith(
        tabelaDePrecoId: event.tabelaDePrecoId,
        step: ImportarVendasCsvStep.editando,
        erro: null,
      ),
    );
  }

  FutureOr<void> _onFuncionarioAlterado(
    ImportarVendasFuncionarioAlterado event,
    Emitter<ImportarVendasCsvState> emit,
  ) {
    emit(
      state.copyWith(
        funcionarioId: event.funcionarioId,
        step: ImportarVendasCsvStep.editando,
        erro: null,
      ),
    );
  }

  FutureOr<void> _onArquivoSelecionado(
    ImportarVendasArquivoSelecionado event,
    Emitter<ImportarVendasCsvState> emit,
  ) async {
    final path = await sl<ArquivoService>().selecionarArquivo(
      extensoes: ['csv'],
    );
    if (path == null) return;

    emit(
      state.copyWith(
        arquivoPath: path,
        arquivoNome: path.split(RegExp(r'[\\/]')).last,
        step: ImportarVendasCsvStep.editando,
        erro: null,
      ),
    );
  }

  FutureOr<void> _onBaixouTemplate(
    ImportarVendasBaixouTemplate event,
    Emitter<ImportarVendasCsvState> emit,
  ) async {
    try {
      final bytes = await _baixarTemplateCsv.call();
      await sl<ArquivoService>().salvarBytes(
        bytes: bytes,
        nomeSugerido: 'modelo-importacao-vendas.csv',
      );
    } catch (e, s) {
      emit(
        state.copyWith(
          erro: mensagemDeErroApi(e, 'Falha ao baixar o modelo.'),
        ),
      );
      addError(e, s);
    }
  }

  FutureOr<void> _onEnviou(
    ImportarVendasEnviou event,
    Emitter<ImportarVendasCsvState> emit,
  ) async {
    final arquivoPath = state.arquivoPath;
    final tabelaDePrecoId = state.tabelaDePrecoId;
    final funcionarioId = state.funcionarioId;
    if (arquivoPath == null || tabelaDePrecoId == null || funcionarioId == null) {
      emit(
        state.copyWith(
          step: ImportarVendasCsvStep.validacaoInvalida,
          erro: 'Selecione a tabela de preço, o funcionário e o arquivo CSV '
              'preenchido.',
        ),
      );
      return;
    }

    emit(state.copyWith(step: ImportarVendasCsvStep.enviando, erro: null));

    try {
      var importacao = await _importarCsv.call(
        filePath: arquivoPath,
        tabelaDePrecoId: tabelaDePrecoId,
        funcionarioId: funcionarioId,
      );

      emit(
        state.copyWith(
          step: ImportarVendasCsvStep.processando,
          importacao: importacao,
        ),
      );

      var tentativas = 0;
      while (!importacao.situacao.finalizada &&
          tentativas < _maxTentativasPolling) {
        await Future.delayed(_intervaloPolling);
        importacao = await _consultarImportacao.call(importacao.id);
        tentativas++;
      }

      emit(
        state.copyWith(
          step: importacao.situacao.finalizada
              ? ImportarVendasCsvStep.concluido
              : ImportarVendasCsvStep.processandoEmSegundoPlano,
          importacao: importacao,
        ),
      );
    } catch (e, s) {
      emit(
        state.copyWith(
          step: ImportarVendasCsvStep.falha,
          erro: mensagemDeErroApi(e, 'Falha ao importar o arquivo.'),
        ),
      );
      addError(e, s);
    }
  }
}
