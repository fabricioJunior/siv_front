import 'dart:async';

import 'package:core/bloc.dart';
import 'package:core/equals.dart';
import 'package:core/arquivos.dart';
import 'package:core/injecoes.dart';
import 'package:core/remote_data_sourcers.dart';
import 'package:precos/domain/models/importacao_tabela_de_preco.dart';
import 'package:precos/domain/models/tabela_de_preco.dart';
import 'package:precos/use_cases.dart';

part 'importar_tabela_de_preco_csv_event.dart';
part 'importar_tabela_de_preco_csv_state.dart';

class ImportarTabelaDePrecoCsvBloc extends Bloc<ImportarTabelaDePrecoCsvEvent,
    ImportarTabelaDePrecoCsvState> {
  final RecuperarTabelasDePreco _recuperarTabelasDePreco;
  final BaixarTemplateImportacaoTabelaDePreco _baixarTemplateCsv;
  final ImportarTabelaDePrecoCsv _importarCsv;
  final ConsultarImportacaoTabelaDePreco _consultarImportacao;

  // ponytail: polling simples de status (a cada 2s por até 30s), mesmo
  // padrão do import de promoções -- upgrade pra push se o volume justificar.
  static const _intervaloPolling = Duration(seconds: 2);
  static const _maxTentativasPolling = 15;

  ImportarTabelaDePrecoCsvBloc(
    this._recuperarTabelasDePreco,
    this._baixarTemplateCsv,
    this._importarCsv,
    this._consultarImportacao,
  ) : super(const ImportarTabelaDePrecoCsvState(
          step: ImportarTabelaDePrecoCsvStep.editando,
        )) {
    on<ImportarTabelaDePrecoCarregouTabelas>(_onCarregouTabelas);
    on<ImportarTabelaDePrecoTabelaAlterada>(_onTabelaAlterada);
    on<ImportarTabelaDePrecoArquivoSelecionado>(_onArquivoSelecionado);
    on<ImportarTabelaDePrecoBaixouTemplate>(_onBaixouTemplate);
    on<ImportarTabelaDePrecoEnviou>(_onEnviou);

    add(ImportarTabelaDePrecoCarregouTabelas());
  }

  FutureOr<void> _onCarregouTabelas(
    ImportarTabelaDePrecoCarregouTabelas event,
    Emitter<ImportarTabelaDePrecoCsvState> emit,
  ) async {
    try {
      final tabelas = await _recuperarTabelasDePreco.call(inativa: false);
      emit(state.copyWith(tabelas: tabelas));
    } catch (e, s) {
      emit(state.copyWith(erro: mensagemDeErroApi(e, 'Falha ao carregar as tabelas de preço.')));
      addError(e, s);
    }
  }

  FutureOr<void> _onTabelaAlterada(
    ImportarTabelaDePrecoTabelaAlterada event,
    Emitter<ImportarTabelaDePrecoCsvState> emit,
  ) {
    emit(
      state.copyWith(
        tabelaDePrecoId: event.tabelaDePrecoId,
        step: ImportarTabelaDePrecoCsvStep.editando,
        erro: null,
      ),
    );
  }

  FutureOr<void> _onArquivoSelecionado(
    ImportarTabelaDePrecoArquivoSelecionado event,
    Emitter<ImportarTabelaDePrecoCsvState> emit,
  ) async {
    final path = await sl<ArquivoService>().selecionarArquivo(
      extensoes: ['csv'],
    );
    if (path == null) return;

    emit(
      state.copyWith(
        arquivoPath: path,
        arquivoNome: path.split(RegExp(r'[\\/]')).last,
        step: ImportarTabelaDePrecoCsvStep.editando,
        erro: null,
      ),
    );
  }

  FutureOr<void> _onBaixouTemplate(
    ImportarTabelaDePrecoBaixouTemplate event,
    Emitter<ImportarTabelaDePrecoCsvState> emit,
  ) async {
    final tabelaDePrecoId = state.tabelaDePrecoId;
    if (tabelaDePrecoId == null) {
      emit(state.copyWith(erro: 'Selecione a tabela de preço.'));
      return;
    }

    try {
      final bytes = await _baixarTemplateCsv.call(
        tabelaDePrecoId: tabelaDePrecoId,
      );
      await sl<ArquivoService>().salvarBytes(
        bytes: bytes,
        nomeSugerido: 'modelo-precos-tabela-$tabelaDePrecoId.csv',
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
    ImportarTabelaDePrecoEnviou event,
    Emitter<ImportarTabelaDePrecoCsvState> emit,
  ) async {
    final arquivoPath = state.arquivoPath;
    if (state.tabelaDePrecoId == null || arquivoPath == null) {
      emit(
        state.copyWith(
          step: ImportarTabelaDePrecoCsvStep.validacaoInvalida,
          erro: 'Selecione a tabela de preço e o arquivo CSV preenchido.',
        ),
      );
      return;
    }

    emit(
      state.copyWith(step: ImportarTabelaDePrecoCsvStep.enviando, erro: null),
    );

    try {
      var importacao = await _importarCsv.call(filePath: arquivoPath);

      emit(
        state.copyWith(
          step: ImportarTabelaDePrecoCsvStep.processando,
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
              ? ImportarTabelaDePrecoCsvStep.concluido
              : ImportarTabelaDePrecoCsvStep.processandoEmSegundoPlano,
          importacao: importacao,
        ),
      );
    } catch (e, s) {
      emit(
        state.copyWith(
          step: ImportarTabelaDePrecoCsvStep.falha,
          erro: mensagemDeErroApi(e, 'Falha ao importar o arquivo.'),
        ),
      );
      addError(e, s);
    }
  }
}
