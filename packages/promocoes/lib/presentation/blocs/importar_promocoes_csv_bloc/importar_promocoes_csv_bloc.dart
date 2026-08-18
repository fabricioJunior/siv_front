import 'dart:async';

import 'package:core/bloc.dart';
import 'package:core/equals.dart';
import 'package:core/arquivos.dart';
import 'package:core/injecoes.dart';
import 'package:core/remote_data_sourcers.dart';
import 'package:promocoes/domain/models/importacao_promocao.dart';
import 'package:promocoes/domain/models/promocao.dart';
import 'package:promocoes/use_cases.dart';

part 'importar_promocoes_csv_event.dart';
part 'importar_promocoes_csv_state.dart';

class ImportarPromocoesCsvBloc
    extends Bloc<ImportarPromocoesCsvEvent, ImportarPromocoesCsvState> {
  final BaixarTemplatePromocoesCsv _baixarTemplateCsv;
  final ImportarPromocoesCsv _importarCsv;
  final ConsultarImportacaoPromocao _consultarImportacao;

  // ponytail: polling simples de status (a cada 2s por até 30s) em vez de
  // WebSocket/push -- processamento roda em fila no backend, upgrade pra
  // notificação em tempo real se o volume de importações justificar.
  static const _intervaloPolling = Duration(seconds: 2);
  static const _maxTentativasPolling = 15;

  ImportarPromocoesCsvBloc(
    this._baixarTemplateCsv,
    this._importarCsv,
    this._consultarImportacao,
  ) : super(const ImportarPromocoesCsvState(step: ImportarPromocoesCsvStep.editando)) {
    on<ImportarPromocoesCampoAlterado>(_onCampoAlterado);
    on<ImportarPromocoesArquivoSelecionado>(_onArquivoSelecionado);
    on<ImportarPromocoesBaixouTemplate>(_onBaixouTemplate);
    on<ImportarPromocoesEnviou>(_onEnviou);
  }

  FutureOr<void> _onCampoAlterado(
    ImportarPromocoesCampoAlterado event,
    Emitter<ImportarPromocoesCsvState> emit,
  ) {
    emit(
      state.copyWith(
        nome: event.nome,
        dataInicio: event.dataInicio,
        dataFim: event.dataFim,
        canal: event.canal,
        arquivoPath: event.arquivoPath,
        arquivoNome: event.arquivoNome,
        step: ImportarPromocoesCsvStep.editando,
        erro: null,
      ),
    );
  }

  FutureOr<void> _onArquivoSelecionado(
    ImportarPromocoesArquivoSelecionado event,
    Emitter<ImportarPromocoesCsvState> emit,
  ) async {
    final path = await sl<ArquivoService>().selecionarArquivo(
      extensoes: ['csv'],
    );
    if (path == null) return;

    emit(
      state.copyWith(
        arquivoPath: path,
        arquivoNome: path.split(RegExp(r'[\\/]')).last,
        step: ImportarPromocoesCsvStep.editando,
        erro: null,
      ),
    );
  }

  FutureOr<void> _onBaixouTemplate(
    ImportarPromocoesBaixouTemplate event,
    Emitter<ImportarPromocoesCsvState> emit,
  ) async {
    try {
      final bytes = await _baixarTemplateCsv.call();
      await sl<ArquivoService>().salvarBytes(
        bytes: bytes,
        nomeSugerido: 'modelo-promocoes.csv',
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
    ImportarPromocoesEnviou event,
    Emitter<ImportarPromocoesCsvState> emit,
  ) async {
    final nome = state.nome?.trim() ?? '';
    final dataInicio = state.dataInicio;
    final dataFim = state.dataFim;
    final arquivoPath = state.arquivoPath;

    if (nome.isEmpty ||
        dataInicio == null ||
        dataFim == null ||
        arquivoPath == null) {
      emit(
        state.copyWith(
          step: ImportarPromocoesCsvStep.validacaoInvalida,
          erro: 'Preencha nome, data de início, data de fim e selecione o arquivo.',
        ),
      );
      return;
    }

    if (dataFim.isBefore(dataInicio)) {
      emit(
        state.copyWith(
          step: ImportarPromocoesCsvStep.validacaoInvalida,
          erro: 'A data de fim não pode ser anterior à data de início.',
        ),
      );
      return;
    }

    emit(state.copyWith(step: ImportarPromocoesCsvStep.enviando, erro: null));

    try {
      var importacao = await _importarCsv.call(
        filePath: arquivoPath,
        nome: nome,
        dataInicio: dataInicio,
        dataFim: dataFim,
        canal: state.canal,
      );

      emit(
        state.copyWith(
          step: ImportarPromocoesCsvStep.processando,
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
              ? ImportarPromocoesCsvStep.concluido
              : ImportarPromocoesCsvStep.processandoEmSegundoPlano,
          importacao: importacao,
        ),
      );
    } catch (e, s) {
      emit(
        state.copyWith(
          step: ImportarPromocoesCsvStep.falha,
          erro: mensagemDeErroApi(e, 'Falha ao importar o arquivo.'),
        ),
      );
      addError(e, s);
    }
  }
}
