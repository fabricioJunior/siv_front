import 'dart:async';

import 'package:core/bloc.dart';
import 'package:core/equals.dart';
import 'package:core/arquivos.dart';
import 'package:core/injecoes.dart';
import 'package:core/remote_data_sourcers.dart';
import 'package:produtos/domain/models/importacao_produto.dart';
import 'package:produtos/use_cases.dart';

part 'importar_produtos_csv_event.dart';
part 'importar_produtos_csv_state.dart';

class ImportarProdutosCsvBloc
    extends Bloc<ImportarProdutosCsvEvent, ImportarProdutosCsvState> {
  final BaixarTemplateImportacaoProdutos _baixarTemplateCsv;
  final ImportarProdutosCsv _importarCsv;
  final ConsultarImportacaoProduto _consultarImportacao;

  // ponytail: polling simples de status (a cada 2s por até 30s), mesmo
  // padrão do import de promoções -- upgrade pra push se o volume justificar.
  static const _intervaloPolling = Duration(seconds: 2);
  static const _maxTentativasPolling = 15;

  ImportarProdutosCsvBloc(
    this._baixarTemplateCsv,
    this._importarCsv,
    this._consultarImportacao,
  ) : super(const ImportarProdutosCsvState(step: ImportarProdutosCsvStep.editando)) {
    on<ImportarProdutosVarianteAlterada>(_onVarianteAlterada);
    on<ImportarProdutosArquivoSelecionado>(_onArquivoSelecionado);
    on<ImportarProdutosBaixouTemplate>(_onBaixouTemplate);
    on<ImportarProdutosEnviou>(_onEnviou);
  }

  FutureOr<void> _onVarianteAlterada(
    ImportarProdutosVarianteAlterada event,
    Emitter<ImportarProdutosCsvState> emit,
  ) {
    // Trocar a variante muda o modelo esperado (colunas diferentes) -- o
    // arquivo já selecionado não serve mais, limpa pra evitar upload errado.
    emit(
      state.copyWith(
        variante: event.variante,
        limparArquivo: true,
        step: ImportarProdutosCsvStep.editando,
        erro: null,
      ),
    );
  }

  FutureOr<void> _onArquivoSelecionado(
    ImportarProdutosArquivoSelecionado event,
    Emitter<ImportarProdutosCsvState> emit,
  ) async {
    final path = await sl<ArquivoService>().selecionarArquivo(
      extensoes: ['csv'],
    );
    if (path == null) return;

    emit(
      state.copyWith(
        arquivoPath: path,
        arquivoNome: path.split(RegExp(r'[\\/]')).last,
        step: ImportarProdutosCsvStep.editando,
        erro: null,
      ),
    );
  }

  FutureOr<void> _onBaixouTemplate(
    ImportarProdutosBaixouTemplate event,
    Emitter<ImportarProdutosCsvState> emit,
  ) async {
    try {
      final bytes = await _baixarTemplateCsv.call(variante: state.variante);
      await sl<ArquivoService>().salvarBytes(
        bytes: bytes,
        nomeSugerido: state.variante == ImportacaoProdutoVariante.somente
            ? 'modelo-produtos-somente.csv'
            : 'modelo-produtos-completo.csv',
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
    ImportarProdutosEnviou event,
    Emitter<ImportarProdutosCsvState> emit,
  ) async {
    final arquivoPath = state.arquivoPath;
    if (arquivoPath == null) {
      emit(
        state.copyWith(
          step: ImportarProdutosCsvStep.validacaoInvalida,
          erro: 'Selecione o arquivo CSV preenchido.',
        ),
      );
      return;
    }

    emit(state.copyWith(step: ImportarProdutosCsvStep.enviando, erro: null));

    try {
      var importacao = await _importarCsv.call(
        filePath: arquivoPath,
        variante: state.variante,
      );

      emit(
        state.copyWith(
          step: ImportarProdutosCsvStep.processando,
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
              ? ImportarProdutosCsvStep.concluido
              : ImportarProdutosCsvStep.processandoEmSegundoPlano,
          importacao: importacao,
        ),
      );
    } catch (e, s) {
      emit(
        state.copyWith(
          step: ImportarProdutosCsvStep.falha,
          erro: mensagemDeErroApi(e, 'Falha ao importar o arquivo.'),
        ),
      );
      addError(e, s);
    }
  }
}
