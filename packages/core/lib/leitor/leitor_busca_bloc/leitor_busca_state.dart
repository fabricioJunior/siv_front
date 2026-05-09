part of 'leitor_busca_bloc.dart';

class LeitorBuscaState {
  final bool processando;
  final List<LeitorData> resultados;
  final List<String> tamanhosDisponiveis;
  final List<String> coresDisponiveis;
  final String? tamanhoFiltro;
  final String? corFiltro;
  final String? erro;

  const LeitorBuscaState({
    required this.processando,
    required this.resultados,
    required this.tamanhosDisponiveis,
    required this.coresDisponiveis,
    required this.tamanhoFiltro,
    required this.corFiltro,
    required this.erro,
  });

  factory LeitorBuscaState.initial() {
    return const LeitorBuscaState(
      processando: false,
      resultados: [],
      tamanhosDisponiveis: [],
      coresDisponiveis: [],
      tamanhoFiltro: null,
      corFiltro: null,
      erro: null,
    );
  }

  List<LeitorData> get resultadosFiltrados {
    return resultados.where((r) {
      if (tamanhoFiltro != null && r.tamanho.trim() != tamanhoFiltro) {
        return false;
      }
      if (corFiltro != null && r.cor.trim() != corFiltro) {
        return false;
      }
      return true;
    }).toList();
  }

  LeitorBuscaState copyWith({
    bool? processando,
    List<LeitorData>? resultados,
    List<String>? tamanhosDisponiveis,
    List<String>? coresDisponiveis,
    Object? tamanhoFiltro = _naoInformado,
    Object? corFiltro = _naoInformado,
    Object? erro = _naoInformado,
  }) {
    return LeitorBuscaState(
      processando: processando ?? this.processando,
      resultados: resultados ?? this.resultados,
      tamanhosDisponiveis: tamanhosDisponiveis ?? this.tamanhosDisponiveis,
      coresDisponiveis: coresDisponiveis ?? this.coresDisponiveis,
      tamanhoFiltro: tamanhoFiltro == _naoInformado
          ? this.tamanhoFiltro
          : tamanhoFiltro as String?,
      corFiltro: corFiltro == _naoInformado
          ? this.corFiltro
          : corFiltro as String?,
      erro: erro == _naoInformado ? this.erro : erro as String?,
    );
  }
}

const Object _naoInformado = Object();
