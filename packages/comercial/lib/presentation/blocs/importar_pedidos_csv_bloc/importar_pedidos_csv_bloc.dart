import 'dart:async';

import 'package:comercial/domain/models/importacao_pedido_transferencia.dart';
import 'package:comercial/use_cases.dart';
import 'package:core/arquivos.dart';
import 'package:core/bloc.dart';
import 'package:core/equals.dart';
import 'package:core/injecoes.dart';
import 'package:core/remote_data_sourcers.dart';

part 'importar_pedidos_csv_event.dart';
part 'importar_pedidos_csv_state.dart';

class ImportarPedidosCsvBloc
    extends Bloc<ImportarPedidosCsvEvent, ImportarPedidosCsvState> {
  final BaixarTemplateImportacaoPedidos _baixarTemplateCsv;
  final ImportarPedidosCsv _importarCsv;
  final ConsultarImportacaoPedido _consultarImportacao;

  // ponytail: polling simples de status (a cada 2s por até 30s), mesmo
  // padrão do import de promoções -- upgrade pra push se o volume justificar.
  static const _intervaloPolling = Duration(seconds: 2);
  static const _maxTentativasPolling = 15;

  ImportarPedidosCsvBloc(
    this._baixarTemplateCsv,
    this._importarCsv,
    this._consultarImportacao,
  ) : super(const ImportarPedidosCsvState(step: ImportarPedidosCsvStep.editando)) {
    on<ImportarPedidosTabelaAlterada>(_onTabelaAlterada);
    on<ImportarPedidosArquivoSelecionado>(_onArquivoSelecionado);
    on<ImportarPedidosBaixouTemplate>(_onBaixouTemplate);
    on<ImportarPedidosEnviou>(_onEnviou);
  }

  FutureOr<void> _onTabelaAlterada(
    ImportarPedidosTabelaAlterada event,
    Emitter<ImportarPedidosCsvState> emit,
  ) {
    emit(
      state.copyWith(
        tabelaDePrecoId: event.tabelaDePrecoId,
        step: ImportarPedidosCsvStep.editando,
        erro: null,
      ),
    );
  }

  FutureOr<void> _onArquivoSelecionado(
    ImportarPedidosArquivoSelecionado event,
    Emitter<ImportarPedidosCsvState> emit,
  ) async {
    final path = await sl<ArquivoService>().selecionarArquivo(
      extensoes: ['csv'],
    );
    if (path == null) return;

    emit(
      state.copyWith(
        arquivoPath: path,
        arquivoNome: path.split(RegExp(r'[\\/]')).last,
        step: ImportarPedidosCsvStep.editando,
        erro: null,
      ),
    );
  }

  FutureOr<void> _onBaixouTemplate(
    ImportarPedidosBaixouTemplate event,
    Emitter<ImportarPedidosCsvState> emit,
  ) async {
    try {
      final bytes = await _baixarTemplateCsv.call();
      await sl<ArquivoService>().salvarBytes(
        bytes: bytes,
        nomeSugerido: 'modelo-pedidos-transferencia-entrada.csv',
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
    ImportarPedidosEnviou event,
    Emitter<ImportarPedidosCsvState> emit,
  ) async {
    final arquivoPath = state.arquivoPath;
    final tabelaDePrecoId = state.tabelaDePrecoId;
    if (arquivoPath == null || tabelaDePrecoId == null) {
      emit(
        state.copyWith(
          step: ImportarPedidosCsvStep.validacaoInvalida,
          erro: 'Selecione a tabela de preço e o arquivo CSV preenchido.',
        ),
      );
      return;
    }

    emit(state.copyWith(step: ImportarPedidosCsvStep.enviando, erro: null));

    try {
      var importacao = await _importarCsv.call(
        filePath: arquivoPath,
        tabelaDePrecoId: tabelaDePrecoId,
      );

      emit(
        state.copyWith(
          step: ImportarPedidosCsvStep.processando,
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
              ? ImportarPedidosCsvStep.concluido
              : ImportarPedidosCsvStep.processandoEmSegundoPlano,
          importacao: importacao,
        ),
      );
    } catch (e, s) {
      emit(
        state.copyWith(
          step: ImportarPedidosCsvStep.falha,
          erro: mensagemDeErroApi(e, 'Falha ao importar o arquivo.'),
        ),
      );
      addError(e, s);
    }
  }
}
