import 'dart:async';
import 'dart:convert';

import 'package:core/arquivos.dart';
import 'package:core/bloc.dart';
import 'package:core/equals.dart';
import 'package:core/injecoes.dart';
import 'package:core/remote_data_sourcers.dart';
import 'package:core/sessao.dart';
import 'package:estoque/domain/usecases/importar_estoque_csv.dart';

part 'importar_estoque_csv_event.dart';
part 'importar_estoque_csv_state.dart';

class ImportarEstoqueCsvBloc
    extends Bloc<ImportarEstoqueCsvEvent, ImportarEstoqueCsvState> {
  final ImportarEstoqueCsv _importarCsv;

  static const _cabecalhoModelo = 'produtoIdExterno;quantidade';
  static const _linhaExemploModelo = '12345;10';

  ImportarEstoqueCsvBloc(this._importarCsv)
      : super(const ImportarEstoqueCsvState(step: ImportarEstoqueCsvStep.editando)) {
    on<ImportarEstoqueArquivoSelecionado>(_onArquivoSelecionado);
    on<ImportarEstoqueBaixouTemplate>(_onBaixouTemplate);
    on<ImportarEstoqueEnviou>(_onEnviou);
  }

  FutureOr<void> _onArquivoSelecionado(
    ImportarEstoqueArquivoSelecionado event,
    Emitter<ImportarEstoqueCsvState> emit,
  ) async {
    final path = await sl<ArquivoService>().selecionarArquivo(
      extensoes: ['csv'],
    );
    if (path == null) return;

    emit(
      state.copyWith(
        arquivoPath: path,
        arquivoNome: path.split(RegExp(r'[\\/]')).last,
        step: ImportarEstoqueCsvStep.editando,
        erro: null,
      ),
    );
  }

  FutureOr<void> _onBaixouTemplate(
    ImportarEstoqueBaixouTemplate event,
    Emitter<ImportarEstoqueCsvState> emit,
  ) async {
    // ponytail: modelo estático local -- não existe endpoint de template pra
    // esse import no backend (decisão consciente, fluxo simples demais pra
    // justificar).
    final bytes = utf8.encode('$_cabecalhoModelo\n$_linhaExemploModelo\n');
    await sl<ArquivoService>().salvarBytes(
      bytes: bytes,
      nomeSugerido: 'modelo-estoque.csv',
    );
  }

  FutureOr<void> _onEnviou(
    ImportarEstoqueEnviou event,
    Emitter<ImportarEstoqueCsvState> emit,
  ) async {
    final arquivoPath = state.arquivoPath;
    if (arquivoPath == null) {
      emit(
        state.copyWith(
          step: ImportarEstoqueCsvStep.validacaoInvalida,
          erro: 'Selecione o arquivo CSV preenchido.',
        ),
      );
      return;
    }

    final empresaId = sl<IAcessoGlobalSessao>().empresaIdDaSessao;
    if (empresaId == null) {
      emit(
        state.copyWith(
          step: ImportarEstoqueCsvStep.falha,
          erro: 'Nenhuma empresa selecionada na sessão.',
        ),
      );
      return;
    }

    emit(state.copyWith(step: ImportarEstoqueCsvStep.enviando, erro: null));

    try {
      final linhasEnviadas = await _importarCsv.call(
        filePath: arquivoPath,
        empresaId: empresaId,
      );
      emit(
        state.copyWith(
          step: ImportarEstoqueCsvStep.concluido,
          linhasEnviadas: linhasEnviadas,
        ),
      );
    } catch (e, s) {
      emit(
        state.copyWith(
          step: ImportarEstoqueCsvStep.falha,
          erro: mensagemDeErroApi(e, 'Falha ao importar o arquivo.'),
        ),
      );
      addError(e, s);
    }
  }
}
