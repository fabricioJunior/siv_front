import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:core/bloc.dart';
import 'package:core/leitor/data_source/i_leitor_busca_data_datasource.dart';
import 'package:core/leitor/leitor_data.dart';

part 'leitor_busca_event.dart';
part 'leitor_busca_state.dart';

class LeitorBuscaBloc extends Bloc<LeitorBuscaEvent, LeitorBuscaState> {
  final ILeitorBuscaDataDatasource _dataSource;
  final int? _tabelaDePrecoId;

  LeitorBuscaBloc({
    required ILeitorBuscaDataDatasource dataSource,
    int? tabelaDePrecoId,
  })  : _dataSource = dataSource,
        _tabelaDePrecoId = tabelaDePrecoId,
        super(LeitorBuscaState.initial()) {
    on<LeitorBuscaTextoBuscado>(
      _onTextoBuscado,
      transformer: restartable(),
    );
    on<LeitorBuscaTamanhoFiltrado>(_onTamanhoFiltrado);
    on<LeitorBuscaCorFiltrada>(_onCorFiltrada);
  }

  Future<void> _onTextoBuscado(
    LeitorBuscaTextoBuscado event,
    Emitter<LeitorBuscaState> emit,
  ) async {
    final texto = event.texto.trim();
    if (texto.isEmpty) {
      emit(LeitorBuscaState.initial());
      return;
    }

    emit(state.copyWith(processando: true, erro: null));

    try {
      final resultados = await _dataSource.buscarPorTexto(
        texto,
        tabelaDePrecoId: _tabelaDePrecoId,
      );

      final tamanhos = resultados
          .map((r) => r.tamanho.trim())
          .where((t) => t.isNotEmpty)
          .toSet()
          .toList()
        ..sort();
      final cores = resultados
          .map((r) => r.cor.trim())
          .where((c) => c.isNotEmpty)
          .toSet()
          .toList()
        ..sort();

      // Revalida filtros: descarta filtro se não existe mais nos resultados
      final tamanhoFiltro = tamanhos.contains(state.tamanhoFiltro)
          ? state.tamanhoFiltro
          : null;
      final corFiltro =
          cores.contains(state.corFiltro) ? state.corFiltro : null;

      emit(
        state.copyWith(
          processando: false,
          resultados: resultados,
          tamanhosDisponiveis: tamanhos,
          coresDisponiveis: cores,
          tamanhoFiltro: tamanhoFiltro,
          corFiltro: corFiltro,
          erro: null,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          processando: false,
          erro: 'Erro ao buscar produtos. Tente novamente.',
        ),
      );
    }
  }

  void _onTamanhoFiltrado(
    LeitorBuscaTamanhoFiltrado event,
    Emitter<LeitorBuscaState> emit,
  ) {
    emit(state.copyWith(tamanhoFiltro: event.tamanho));
  }

  void _onCorFiltrada(
    LeitorBuscaCorFiltrada event,
    Emitter<LeitorBuscaState> emit,
  ) {
    emit(state.copyWith(corFiltro: event.cor));
  }
}
